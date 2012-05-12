class Navbar extends require('view')
  
  template: require 'singool/templates/navbar'
  
  defaultSettings:
    brand: 'Singool'
    links: []
  
  render: =>
    $(@el).html @template
      settings: @settings
    @

module.exports = Navbar