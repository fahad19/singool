class AppRouter extends require('router')
  
  routes:
    '!/': 'dashboard'
  
  dashboard: ->
    Dashboard = require 'views/dashboard'
    window.dashboardView = new Dashboard
    $('#main').html window.dashboardView.render().el
  
module.exports = AppRouter