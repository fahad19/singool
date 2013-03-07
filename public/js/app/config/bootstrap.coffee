if require('singool/config').test is false
  # Header
  Navbar = require 'singool/views/navbar'
  window.navbarView = new Navbar
    el: $ 'header'
  window.navbarView.render()


  # Footer
  Footer = require 'singool/views/footer'
  window.footerView = new Footer
    el: $ 'footer'
  window.footerView.render()


  # Router
  AppRouter = require 'config/router'
  window.appRouter = new AppRouter