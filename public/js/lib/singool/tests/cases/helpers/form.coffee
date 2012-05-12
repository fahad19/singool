describe 'Singool: helpers/form', ->
  
  Form = require 'singool/helpers/form'
  form = new Form()
  
  it 'expects Form to be a Function', ->
    expect(Form).to.be.a 'function'
  
  it 'expects form to be an object', ->
    expect(form).to.be.an 'object'
