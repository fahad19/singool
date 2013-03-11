_    = require 'underscore'
exec = require('child_process').exec

class Test

  constructor: (@singool) ->

  description: 'Run tests'

  url: null

  _server: null

  server: =>
    @singool.config.test = true
    @singool.config.init = false
    @singool.config.ignore = []

    @_server = @singool.createServer()
    port = process.env.PORT || 3000
    @_server.listen port
    @url = 'http://localhost:' + port
    console.log 'Test server running at ' + @url

  mochaPhantom: =>
    rootPath = @singool.rootPath()
    cmd      = rootPath + '/node_modules/.bin/mocha-phantomjs ' + @url
    
    console.log 'Running command: ' + cmd
    exec cmd, (error, stdout, stderr) =>
      if error then throw error

      if stdout
        console.log stdout
      else
        console.log stderr

      @_server.close()

  run: =>
    @server()
    @mochaPhantom()

module.exports = Test