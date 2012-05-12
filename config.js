/**
 * Configuration
 */
var compress = false;
var plugins = [];
var theme = 'default';

var publicPath = __dirname + '/public';
var pluginsPath = publicPath + '/js/plugins';

var config = {
  compress: compress,
  plugins: plugins,
  theme: theme,

  publicPath: publicPath,
  cssPath: publicPath + '/css',
  jsPath: publicPath + '/js',
  pluginsPath: pluginsPath,
  themesPath: publicPath + '/themes',
  paths: [
    publicPath + '/js/app',
    publicPath + '/js/lib',
    pluginsPath
  ],
  vendors: [
    publicPath + '/js/vendors/jquery.min.js',
    publicPath + '/js/vendors/underscore-min.js',
    publicPath + '/js/vendors/backbone-min.js',
    publicPath + '/js/init.js'
  ]
}

module.exports = config;
