class Foo extends require('singool/helper')

  beforeRender: ->
    @view.setByHelperBeforeRender = true

  afterRender: ->
    @view.$('span').addClass 'helper-after-render'

module.exports = Foo