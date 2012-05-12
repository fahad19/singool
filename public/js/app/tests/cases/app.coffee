describe 'App', ->
  
  foo = 'bar'
  
  it 'test foo', ->
    expect(foo).to.be.a 'string'
    expect(foo).to.eql('bar');
