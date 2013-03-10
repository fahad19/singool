class Server

  constructor: (@singool) ->

  description: 'Real time server'

  serveStatic: false

  run: =>
    server  = @singool.createServer(@serveStatic)
    port    = process.env.PORT || 3000
    server.listen port
    console.log 'Server running at http://localhost:' + port

module.exports = Server