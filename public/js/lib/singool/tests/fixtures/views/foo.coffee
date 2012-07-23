class Foo extends require('singool/view')
  
  template: require 'singool/tests/fixtures/templates/foo'
  
  helpers:
    foo: require 'singool/tests/fixtures/helpers/foo'

  setByBeforeRender: false

  setByHelperBeforeRender: false
  
  beforeRender: =>
    @setByBeforeRender = true

  render: =>
    $(@el).html @template
    @

  afterRender: =>
    @$('span').addClass 'after-render'

module.exports = Foo