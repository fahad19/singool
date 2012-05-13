config  = require './config'
Singool = require 'singool'

server = (serveStatic = false) ->
  singool = new Singool config
  server  = singool.createServer(serveStatic)
  port    = process.env.PORT || 3000
  server.listen port
  console.log 'Server running at http://localhost:' + port

task 'server', 'Real time server', ->
  server()

task 'build', 'Build layout, js and css', ->
  singool = new Singool config
  singool.build()

task 'static', 'Build and serve static files', ->
  singool = new Singool config
  singool.build ->
    server true

task 'clear', 'Delete build files', ->
  singool = new Singool config
  singool.clear()

task 'test', 'Run tests', ->
  config.test = true
  config.init = false
  singool     = new Singool config
  server      = singool.createServer()
  port        = process.env.PORT || 3000
  server.listen port
  console.log 'Test server running at http://localhost:' + port
