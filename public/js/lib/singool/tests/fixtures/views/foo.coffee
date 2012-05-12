class Foo extends require('singool/view')
  
  template: require 'singool/tests/fixtures/templates/foo'
  
  helpers:
    foo: require 'singool/tests/fixtures/helpers/foo'
    
  render: =>
    $(@el).html @template
    @

module.exports = Foo