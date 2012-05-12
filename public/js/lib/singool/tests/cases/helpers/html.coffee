describe 'Singool: helpers/html', ->
  
  Html = require 'singool/helpers/html'
  html = new Html()
  
  it 'expects Html to be a Function', ->
    expect(Html).to.be.a 'function'
  
  it 'expects html to be an object', ->
    expect(html).to.be.an 'object'
