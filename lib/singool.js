(function() {
  var Singool, cs, express, findit, fs, less, stitch, uglify, util, _;

  _ = require('underscore');

  stitch = require('stitch-extra');

  uglify = require('uglify-js');

  less = require('less');

  fs = require('fs');

  util = require('util');

  cs = require('coffee-script/lib/coffee-script/coffee-script');

  express = require('express');

  findit = require('findit');

  Singool = (function() {

    Singool.prototype.config = {};

    Singool.prototype.jsPackage = null;

    Singool.prototype.cssPackage = null;

    Singool.prototype.defaults = {
      theme: null,
      publicPath: null,
      cssPath: null,
      jsPath: null,
      themesPath: null,
      pluginsPath: null,
      paths: [],
      compress: false,
      plugins: [],
      vendors: [],
      ignore: [],
      compilers: {},
      test: false,
      init: true,
      cssFile: 'app.css',
      jsFile: 'app.js'
    };

    function Singool(config) {
      this.config = _.defaults(config, this.defaults);
      this.prepare();
    }

    Singool.prototype.prepare = function() {
      this.ignore();
      this.dependencies();
      return this.compilers();
    };

    Singool.prototype.ignore = function() {
      var availablePlugin, availablePlugins, k, regex, _results;
      this.config.ignore.push(/\/vendors\//);
      if (!this.config.test) this.config.ignore.push(/\/tests\//);
      availablePlugins = fs.readdirSync(this.config.pluginsPath);
      _results = [];
      for (k in availablePlugins) {
        availablePlugin = availablePlugins[k];
        if (_.indexOf(this.config.plugins, availablePlugin) === -1) {
          regex = new RegExp('/' + this.config.pluginsPath + '/' + availablePlugin + '/', 'i');
          _results.push(this.config.ignore.push(regex));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Singool.prototype.dependencies = function() {
      var filename, k, l, path, plugin, v, vendorsByFilename, _ref, _ref2, _ref3;
      _ref = this.config.paths;
      for (k in _ref) {
        path = _ref[k];
        this.config.vendors = _.extend(this.getVendorsByPath(path), this.config.vendors);
        _ref2 = this.config.plugins;
        for (l in _ref2) {
          plugin = _ref2[l];
          this.config.vendors = _.extend(this.getVendorsByPath(path + '/' + plugin), this.config.vendors);
        }
      }
      this.config.vendors = _.extend(this.getVendorsByPath(this.config.themesPath + '/' + this.config.theme), this.config.vendors);
      vendorsByFilename = {};
      _ref3 = this.config.vendors;
      for (k in _ref3) {
        v = _ref3[k];
        filename = _.last(v.split('/'));
        vendorsByFilename[filename] = v;
      }
      if (!this.config.init && _.has(vendorsByFilename, 'init.js')) {
        delete vendorsByFilename['init.js'];
      }
      return this.config.vendors = _.values(vendorsByFilename);
    };

    Singool.prototype.getVendorsByPath = function(path) {
      var k, pathVendor, pathVendors, vendors;
      vendors = {};
      if (require('path').existsSync(path + '/config/vendors.json')) {
        pathVendors = JSON.parse(fs.readFileSync(path + '/config/vendors.json', 'utf8'));
        for (k in pathVendors) {
          pathVendor = pathVendors[k];
          vendors[pathVendor] = path + '/vendors/' + pathVendor;
        }
      }
      return vendors;
    };

    Singool.prototype.defaultCompilers = function() {
      var compilers,
        _this = this;
      compilers = {
        singool: function(module, filename) {
          var content, source;
          source = '';
          if (filename.indexOf('singool/config/index.singool' > -1)) {
            content = {
              theme: _this.config.theme,
              plugins: _this.config.plugins,
              test: _this.config.test
            };
            if (_this.config.test) content.testCases = _this.testCases();
            source = 'module.exports = ' + JSON.stringify(content) + ';';
          }
          return module._compile(source, filename);
        },
        coffee: function(module, filename) {
          var source;
          source = fs.readFileSync(filename, 'utf8');
          return module._compile(cs.compile(source, filename));
        },
        underscore: function(module, filename) {
          var source;
          source = fs.readFileSync(filename, 'utf8');
          source = 'module.exports = _.template(' + util.inspect(source) + ');';
          return module._compile(source, filename);
        }
      };
      return compilers;
    };

    Singool.prototype.testCases = function() {
      var cases, extension, file, filename, files, i, j, path, testCase, _ref;
      cases = [];
      _ref = this.config.paths;
      for (i in _ref) {
        path = _ref[i];
        files = findit.sync(path);
        for (j in files) {
          file = files[j];
          if (/\/tests\/cases\//.test(file)) {
            testCase = file.replace(path + '/', '');
            filename = _.last(testCase.split('/'));
            if (filename.indexOf('.') !== -1 || filename.indexOf('.') > 0) {
              extension = filename.substr(filename.lastIndexOf('.') + 1);
              cases.push(testCase.replace('.' + extension, ''));
            }
          }
        }
      }
      return cases;
    };

    Singool.prototype.compilers = function() {
      var compilerNames, k, v, _ref, _results;
      compilerNames = _.keys(this.config.compilers);
      _ref = this.defaultCompilers();
      _results = [];
      for (k in _ref) {
        v = _ref[k];
        if (_.indexOf(compilerNames, k === -1)) {
          _results.push(this.config.compilers[k] = v);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Singool.prototype.js = function(callback) {
      var _this = this;
      this.createJsPackage();
      return this.jsPackage.compile(function(err, source) {
        var ast, jsp, pro;
        if (err) throw err;
        if (_this.config.compress) {
          jsp = uglify.parser;
          pro = uglify.uglify;
          ast = jsp.parse(source);
          ast = pro.ast_mangle(ast);
          ast = pro.ast_squeeze(ast);
          source = pro.gen_code(ast);
        }
        return callback(source);
      });
    };

    Singool.prototype.createJsPackage = function() {
      return this.jsPackage = stitch.createPackage({
        dependencies: this.config.vendors,
        paths: this.config.paths,
        compilers: this.config.compilers,
        ignore: this.config.ignore
      });
    };

    Singool.prototype.css = function(callback) {
      var k, pluginLessPath, pluginsLess, themeLess, themeLessPath, v, _ref,
        _this = this;
      this.createCssPackage();
      pluginsLess = '';
      _ref = this.config.plugins;
      for (k in _ref) {
        v = _ref[k];
        pluginLessPath = this.config.pluginsPath + '/' + v + '/vendors/plugin.less';
        if (require('path').existsSync(pluginLessPath)) {
          pluginsLess += fs.readFileSync(pluginLessPath, 'utf8');
        }
      }
      themeLessPath = this.config.themesPath + '/' + this.config.theme + '/css/theme.less';
      themeLess = fs.readFileSync(themeLessPath, 'utf8');
      return this.cssPackage.parse(themeLess + pluginsLess, function(e, tree) {
        var source;
        source = tree.toCSS({
          compress: _this.config.compress
        });
        return callback(source);
      });
    };

    Singool.prototype.createCssPackage = function() {
      var lessParser;
      lessParser = less.Parser;
      return this.cssPackage = new lessParser({
        paths: [this.config.themesPath, this.config.cssPath]
      });
    };

    Singool.prototype.readLayout = function() {
      return fs.readFileSync(this.config.themesPath + '/' + this.config.theme + '/layouts/index.html', 'utf8');
    };

    Singool.prototype.readTestLayout = function() {
      return fs.readFileSync(this.config.jsPath + '/lib/singool/tests/test.html', 'utf8');
    };

    Singool.prototype.build = function(callback) {
      var indexFilePath, themeIndex,
        _this = this;
      if (callback == null) callback = false;
      this.css(function(source) {
        var cssFilePath;
        cssFilePath = _this.config.cssPath + '/' + _this.config.cssFile;
        fs.writeFileSync(cssFilePath, source);
        return console.log('CSS file written at: ' + cssFilePath);
      });
      this.js(function(source) {
        var jsFilePath;
        jsFilePath = _this.config.jsPath + '/' + _this.config.jsFile;
        fs.writeFileSync(jsFilePath, source);
        return console.log('JS file writen at: ' + jsFilePath);
      });
      themeIndex = this.readLayout();
      indexFilePath = this.config.publicPath + '/index.html';
      fs.writeFileSync(indexFilePath, themeIndex);
      console.log('Theme layout file written at: ' + indexFilePath);
      if (typeof callback === 'function') return callback();
    };

    Singool.prototype.createServer = function(static) {
      var app,
        _this = this;
      if (static == null) static = false;
      app = express.createServer();
      app.configure(function() {
        return app.use(express.static(_this.config.publicPath));
      });
      app.get('/', function(req, res) {
        if (_this.config.test) {
          return res.send(_this.readTestLayout());
        } else {
          return res.send(_this.readLayout());
        }
      });
      if (!static) {
        app.get('/css/app.css', function(req, res) {
          return _this.css(function(source) {
            res.header('Content-Type', 'text/css');
            return res.send(source);
          });
        });
        app.get('/js/app.js', function(req, res) {
          return _this.js(function(source) {
            res.header('Content-Type', 'application/x-javascript');
            return res.send(source);
          });
        });
      }
      return app;
    };

    Singool.prototype.clear = function() {
      var file;
      file = this.config.publicPath + '/index.html';
      if (require('path').existsSync(file)) {
        fs.unlinkSync(file);
        console.log('index.html deleted');
      }
      file = this.config.jsPath + '/' + this.config.jsFile;
      if (require('path').existsSync(file)) {
        fs.unlinkSync(file);
        console.log(this.config.jsFile + ' deleted');
      }
      file = this.config.cssPath + '/' + this.config.cssFile;
      if (require('path').existsSync(file)) {
        fs.unlinkSync(file);
        return console.log(this.config.cssFile + ' deleted');
      }
    };

    return Singool;

  })();

  module.exports = Singool;

}).call(this);
