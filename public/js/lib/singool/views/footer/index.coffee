class Footer extends require('view')
  
  template: require 'singool/templates/footer'
  
  render: =>
    $(@el).html @template
    @
  
module.exports = Footer