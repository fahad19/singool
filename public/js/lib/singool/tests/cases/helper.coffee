describe 'Singool: helper', ->
  
  Helper = require 'singool/helper'
  helper = new Helper
  
  FooView = require 'singool/tests/fixtures/views/foo'
  fooView = new FooView
  fooView.render()
  
  it 'expects Helper to be a Function', ->
    expect(Helper).to.be.a 'function'
  
  it 'expects helper to be an object', ->
    expect(helper).to.be.an 'object'
  
  it 'should have a view property', ->
    expect(helper).to.have.property 'view'
  
  it 'should have a reference to View in view property', ->
    expect(fooView).to.be.an 'object'
    expect(fooView.foo).to.be.an 'object'
    expect(fooView.foo.view).to.be.an 'object'
    expect(fooView.foo.view).to.eql fooView

  it 'should fire beforeRender callback', ->
    expect(fooView.setByHelperBeforeRender).to.eql true

  it 'should fire afterRender callback', ->
    expect(fooView.$('span').hasClass('helper-after-render')).to.eql true