describe 'Singool: utils/validator', ->
  
  Validator = require 'singool/utils/validator'
  validator = new Validator()
  
  it 'expects Validator to be a Function', ->
    expect(Validator).to.be.a 'function'

  it 'expects validator to be an object', ->
    expect(validator).to.be.an 'object'
  
  it 'checks validator has rules', ->
    expect(validator).to.have.property 'rules'
  
  it 'checks rule: notEmpty', ->
    result = validator.checkRule 'notEmpty', 'text here'
    expect(result).to.be true
    
    result = validator.checkRule 'notEmpty', ''
    expect(result).to.be false

