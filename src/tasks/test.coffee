class Test

  constructor: (@singool) ->

  description: 'Run tests'

  run: =>
    @singool.config.test = true
    @singool.config.init = false
    @singool.config.ignore = []
    @singool.prepare()

    server = @singool.createServer()
    port = process.env.PORT || 3000
    server.listen port
    console.log 'Test server running at http://localhost:' + port

module.exports = Test