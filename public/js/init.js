// init.js
$(document).ready(function() {
  // load Singool and the main App
  require('singool/config/bootstrap');
  require('config/bootstrap');

  // load other plugins
  _.each(require('singool/config').plugins, function(plugin) {
    require(plugin + '/config/bootstrap');
  });

  Backbone.history.start();

  // homepage
  if (window.location.href.indexOf('#!/') == -1) {
    window.location.href += '#!/';
  }
});