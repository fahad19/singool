class Build

  constructor: (@singool) ->

  description: 'Build Layout, JS and CSS'

  run: =>
    @singool.build()

module.exports = Build