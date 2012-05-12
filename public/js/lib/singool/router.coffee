class Router extends Backbone.Router
  
  defaultSettings: {}
  
  settings: {}
  
  constructor: (options) ->
    super
    @settings = _.extend(@defaultSettings, options)
  
  getCurrentHash: ->
    String(window.location.hash).replace('#', '')

module.exports = Router