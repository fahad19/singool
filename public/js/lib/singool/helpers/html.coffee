class HtmlHelper extends require('helper')
  
  templates:
    breadcrumbs: require('singool/templates/html/breadcrumbs')
  
  breadcrumbs: ->
    links = {}
    if @view.settings.breadcrumbs
      links = @view.settings.breadcrumbs
    
    out = @templates.breadcrumbs
      links: links
    out
  
  navLinks: (links, options = {}) ->
    out = '<ul class="nav">'

    for k, link of links
      out += '<li><a href="' + link.url + '">' + link.title + '</a></li>'
    
    out += '</ul>'
    out
  
  tag: (tag, content, attributes = null) ->
    out = "<#{tag}"
    
    if attributes
      for k, v of attributes
        out += " #{k}=\"#{v}\""
    
    out += ">#{content}</#{tag}>"
    out

module.exports = HtmlHelper