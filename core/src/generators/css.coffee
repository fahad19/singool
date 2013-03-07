less = require 'less'
fs   = require 'fs'

class Css
  
  config: null

  constructor: (@singool) ->
    @config = @singool.config

  generate: (callback = false) ->
    lessParser = less.Parser
    pkg = new lessParser
      paths: [@config.themesPath, @config.cssPath]

    pluginsLess = ''
    for k, v of @config.plugins
      pluginLessPath = @config.pluginsPath + '/' + v + '/vendors/plugin.less'
      if fs.existsSync pluginLessPath
        pluginsLess += fs.readFileSync pluginLessPath, 'utf8'
    
    themeLessPath = @config.themesPath + '/' + @config.theme + '/css/theme.less'
    themeLess = fs.readFileSync themeLessPath, 'utf8'
    pkg.parse themeLess + pluginsLess, (e, tree) =>
      source = tree.toCSS
        compress: @config.compress
      
      if callback then callback source

  write: (path = null) ->
    if !path
      path = @config.cssPath + '/' + @config.cssFile
    @generate (source) =>
      fs.writeFileSync path, source
      console.log 'CSS file written at: ' + path

  clear: ->
    file = @config.cssPath + '/' + @config.cssFile
    if fs.existsSync(file)
      fs.unlinkSync(file)
      console.log @config.cssFile + ' deleted'

module.exports = Css