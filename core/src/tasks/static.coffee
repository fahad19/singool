Server = require './Server'

class Static extends Server

  constructor: (@singool) ->
    @serveStatic = true

  description: 'Build and serve static files'

module.exports = Static