describe "DinoFighter", ->
	it "should evaluate", ->
    expect(123).toEqual(123)
  it "should have created a Player1 and Player2 object from the base class", ->
    expect(p1).toEqual(jasmine.any(Object))
    expect(p2).toEqual(jasmine.any(Object))
  it "should have have an isKO function", ->
    expect(p1.isKO).toEqual(jasmine.any(Function))
