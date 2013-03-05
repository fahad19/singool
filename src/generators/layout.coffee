fs = require 'fs'

class Layout

  config: null

  constructor: (@singool) ->
    @config = @singool.config

  read: ->
    fs.readFileSync @config.themesPath + '/' + @config.theme + '/layouts/index.html', 'utf8'

  readTest: ->
    fs.readFileSync @config.jsPath + '/lib/singool/tests/test.html', 'utf8'

  generate: (callback = false) ->
    if @config.test
      source = @readTest()
    else
      source = @read()

    if callback
      callback source
    else
      source

  write: (path = null) ->
    if !path
      path = @config.publicPath + '/index.html'
    @generate (source) =>
      fs.writeFileSync path, source
      console.log 'Theme layout file written at: ' + path

  clear: ->
    file = @config.publicPath + '/index.html'
    if fs.existsSync(file)
      fs.unlinkSync(file)
      console.log 'index.html deleted'

module.exports = Layout