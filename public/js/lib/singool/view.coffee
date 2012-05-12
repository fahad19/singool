class View extends Backbone.View

  defaultSettings: 
    breadcrumbs: []
  
  settings: {}

  coreHelpers:
    html: require 'singool/helpers/html'
    form: require 'singool/helpers/form'
    
  helpers: {}
  
  events: {}
  
  constructor: (options = {}) ->
    super
    @settings = _.defaults options, @defaultSettings
    
    @helpers = _.extend @helpers, @coreHelpers
    for k, v of @helpers
      @[k] = new v(@)

module.exports = View