class Dashboard extends require('view')
  
  template: require 'templates/dashboard/index'
  
  render: =>
    $(@el).html @template()  
    @

module.exports = Dashboard