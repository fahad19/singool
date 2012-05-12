describe 'Singool: model', ->
  
  Model = require 'singool/model'
  model = new Model
  
  Validator = require 'singool/utils/validator'
  validator = new Validator
  
  Foo = require 'singool/tests/fixtures/models/foo'
  foo = new Foo
  
  formTemplate = require 'singool/tests/fixtures/templates/form'
  formWithValuesTemplate = require 'singool/tests/fixtures/templates/form_with_values'
  
  it 'expects Model to be a Function', ->
    expect(Model).to.be.a 'function'

  it 'expects model to be an object', ->
    expect(model).to.be.an 'object'

  it 'should have schema', ->
    expect(model).to.have.property 'schema'
    expect(model.schema).to.be.an 'object'

  it 'should have validator', ->
    expect(model).to.have.property 'validator'
    expect(model.validator).to.eql validator
  
  it 'should extract data from form element', ->
    formWithValues = $ formWithValuesTemplate()
    result = model.extract $(formWithValues)
    expected =
      title: 'title here...'
      description: 'description here...'
      priority: 'medium'
      done: 'on'
    expect(result).to.eql expected
    
  it 'should extract data from empty form element', ->
    form = $ formTemplate()
    result = model.extract form
    expected = 
      title: ''
      description: ''
      priority: ''
      done: false
    expect(result).to.eql expected
    
  
  it 'should validate attributes', ->
    attrs =
      title: ''
    expect(foo.validates(attrs)).to.be false
    expect(foo.validationErrors.title).to.be.an 'object'
    expect(foo.validationErrors.title.notEmpty).to.be.an 'string'

