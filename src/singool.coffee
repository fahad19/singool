_       = require 'underscore'
stitch  = require 'stitch-extra'
uglify  = require 'uglify-js'
less    = require 'less'
fs      = require 'fs'
util    = require 'util'
cs      = require 'coffee-script/lib/coffee-script/coffee-script'
express = require 'express'
findit  = require 'findit'

class Singool
  
  config: {}
  
  jsPackage: null
  
  cssPackage: null
  
  defaults:
    theme: null
    publicPath: null
    cssPath: null
    jsPath: null
    themesPath: null
    pluginsPath: null
    paths: []
    
    compress: false
    plugins: []
    vendors: []
    ignore: []
    compilers: {}
    test: false
    init: true
    cssFile: 'app.css'
    jsFile: 'app.js'
  
  constructor: (config) ->
    @config = _.defaults config, @defaults
    @prepare()
  
  prepare: ->
    @ignore()
    @dependencies()
    @compilers()
  
  ignore: ->
    @config.ignore.push /\/vendors\//
    
    if !@config.test
      @config.ignore.push /\/tests\//
    
    availablePlugins = fs.readdirSync @config.pluginsPath
    for k, availablePlugin of availablePlugins
      if _.indexOf(@config.plugins, availablePlugin) == -1
        regex = new RegExp '/' + @config.pluginsPath + '/' + availablePlugin + '/', 'i'
        @config.ignore.push regex
  
  dependencies: ->
    for k, path of @config.paths
      @config.vendors = _.extend @getVendorsByPath(path), @config.vendors
      for l, plugin of @config.plugins
        @config.vendors = _.extend @getVendorsByPath(path + '/' + plugin), @config.vendors
    
    @config.vendors = _.extend @getVendorsByPath(@config.themesPath + '/' + @config.theme), @config.vendors
    
    vendorsByFilename = {};
    for k, v of @config.vendors
      filename = _.last v.split '/'
      vendorsByFilename[filename] = v
    
    if !@config.init and _.has(vendorsByFilename, 'init.js')
      delete vendorsByFilename['init.js']
    
    @config.vendors = _.values vendorsByFilename
    
  getVendorsByPath: (path) ->
    vendors = {}
    if require('path').existsSync path + '/config/vendors.json'
      pathVendors = JSON.parse fs.readFileSync path + '/config/vendors.json', 'utf8'
      for k, pathVendor of pathVendors
        vendors[pathVendor] = path + '/vendors/' + pathVendor
    
    vendors
  
  defaultCompilers: ->
    compilers =
      singool: (module, filename) =>
        source = ''
        if filename.indexOf 'singool/config/index.singool' > -1
          content =
            theme: @config.theme
            plugins: @config.plugins
            test: @config.test
          
          if @config.test
            content.testCases = @testCases()
          
          source = 'module.exports = ' + JSON.stringify(content) + ';'
        module._compile source, filename

      coffee: (module, filename) =>
        source = fs.readFileSync filename, 'utf8'
        module._compile cs.compile(source), filename

      underscore: (module, filename) =>
        source = fs.readFileSync(filename, 'utf8')
        source = 'module.exports = _.template(' + util.inspect(source) + ');'
        module._compile source, filename
    
    compilers
  
  testCases: ->
    cases = []
    
    for i, path of @config.paths
      files = findit.sync path
      for j, file of files
        if /\/tests\/cases\//.test(file)
          testCase = file.replace path + '/', ''
          filename = _.last testCase.split('/')
          if filename.indexOf('.') != -1 or filename.indexOf('.') > 0
            extension = filename.substr(filename.lastIndexOf('.') + 1)
            cases.push testCase.replace '.' + extension, ''
    
    cases
  
  compilers: ->
    compilerNames = _.keys @config.compilers
    for k, v of @defaultCompilers()
      if _.indexOf compilerNames, k == -1
        @config.compilers[k] = v
  
  js: (callback) ->
    @createJsPackage()
    @jsPackage.compile (err, source) =>
      if err
        throw err
      
      if @config.compress
        jsp = uglify.parser
        pro = uglify.uglify

        ast = jsp.parse source
        ast = pro.ast_mangle ast
        ast = pro.ast_squeeze ast
        source = pro.gen_code ast
      
      callback source

  createJsPackage: ->
    @jsPackage = stitch.createPackage
      dependencies: @config.vendors
      paths: @config.paths
      compilers: @config.compilers
      ignore: @config.ignore
  
  css: (callback) ->
    @createCssPackage()
    
    pluginsLess = ''
    for k, v of @config.plugins
      pluginLessPath = @config.pluginsPath + '/' + v + '/vendors/plugin.less'
      if require('path').existsSync pluginLessPath
        pluginsLess += fs.readFileSync pluginLessPath, 'utf8'
    
    themeLessPath = @config.themesPath + '/' + @config.theme + '/css/theme.less'
    themeLess = fs.readFileSync themeLessPath, 'utf8'
    @cssPackage.parse themeLess + pluginsLess, (e, tree) =>
      source = tree.toCSS
        compress: @config.compress
      
      callback source
    
  createCssPackage: ->
    lessParser = less.Parser
    @cssPackage = new lessParser
      paths: [@config.themesPath, @config.cssPath]
  
  readLayout: ->
    fs.readFileSync @config.themesPath + '/' + @config.theme + '/layouts/index.html', 'utf8'
  
  readTestLayout: ->
    fs.readFileSync @config.jsPath + '/lib/singool/tests/test.html', 'utf8'
  
  build: (callback = false) ->
    @css (source) =>
      cssFilePath = @config.cssPath + '/' + @config.cssFile
      fs.writeFileSync cssFilePath, source
      console.log 'CSS file written at: ' + cssFilePath
    
    @js (source) =>
      jsFilePath = @config.jsPath + '/' + @config.jsFile
      fs.writeFileSync jsFilePath, source
      console.log 'JS file writen at: ' + jsFilePath
    
    themeIndex = @readLayout()
    indexFilePath = @config.publicPath + '/index.html'
    fs.writeFileSync indexFilePath, themeIndex
    console.log 'Theme layout file written at: ' + indexFilePath
    
    if typeof callback == 'function'
      callback()
  
  createServer: (static = false) ->
    app = express.createServer()
    
    app.configure =>
      app.use express.static @config.publicPath
    
    app.get '/', (req, res) => 
      if @config.test
        res.send @readTestLayout()
      else
        res.send @readLayout()
    
    if !static
      app.get '/css/app.css', (req, res) =>
        @css (source) ->
          res.header 'Content-Type', 'text/css'
          res.send source
    
      app.get '/js/app.js', (req, res) =>
        @js (source) ->
          res.header 'Content-Type', 'application/x-javascript'
          res.send source
    
    app
  
  clear: ->
    file = @config.publicPath + '/index.html'
    if require('path').existsSync(file)
      fs.unlinkSync(file)
      console.log 'index.html deleted'
    
    file = @config.jsPath + '/' + @config.jsFile
    if require('path').existsSync(file)
      fs.unlinkSync(file)
      console.log @config.jsFile + ' deleted'
    
    file = @config.cssPath + '/' + @config.cssFile
    if require('path').existsSync(file)
      fs.unlinkSync(file)
      console.log @config.cssFile + ' deleted'

module.exports = Singool