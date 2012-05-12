describe 'Singool: collection', ->
  
  Collection = require 'singool/collection'
  collection = new Collection()
  
  it 'expects Collection to be a Function', ->
    expect(Collection).to.be.a 'function'
  
  it 'expects collection to be an object', ->
    expect(collection).to.be.an 'object'
  
  it 'should be same as Backbone.Collection', ->
    expect(collection).to.eql new Backbone.Collection
    