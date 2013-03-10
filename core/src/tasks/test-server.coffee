class TestServer extends require('./test')

  constructor: (@singool) ->

  description: 'Run tests in the browser'

  run: =>
    @server()

module.exports = TestServer