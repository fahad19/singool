class Clear

  constructor: (@singool) ->

  description: 'Delete build files'

  run: =>
    @singool.clear()

module.exports = Clear