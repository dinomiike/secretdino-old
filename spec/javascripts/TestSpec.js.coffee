describe "DinoFighter", ->
  describe "Player Object", ->
    it "should create a Player1 and Player2 object", ->
      expect(p1).toEqual(jasmine.any(Object))
      expect(p2).toEqual(jasmine.any(Object))
    it "should start with a full life meter bar", ->
      expect(p1.metercolor).toEqual "meter-full"
      expect(p2.metercolor).toEqual "meter-full"
    it "should have normals", ->
      expect(p1.normals).toEqual(jasmine.any(Object))
      expect(p2.normals).toEqual(jasmine.any(Object))

    describe "Player functions", ->
      beforeEach ->
        # Change player attributes to test functionality
        p1.hp = 0
        p2.hp = 50
        p1.percenthealth = 0
        p2.percenthealth = 50
      it "should have have an isKO function", ->
        expect(p1.isKO).toEqual(jasmine.any(Function))
        expect(p2.isKO).toEqual(jasmine.any(Function))
      it "should have a healthColor function", ->
        expect(p1.healthColor).toEqual(jasmine.any(Function))
        expect(p2.healthColor).toEqual(jasmine.any(Function))
      it "should return p1 as KO'd", ->
        expect(p1.isKO()).toBe(true)
      it "should return 'meter-50' as p2 healthcolor", ->
        expect(p2.healthColor()).toEqual("meter-50")

  describe "Helper functions", ->
    beforeEach ->
      # Simulate some button presses, p1 has faster startup frames, frameAdv will return p2
      atkStack.p1.action = "c"
      atkStack.p2.action = "c"
      @result = frameAdv()
    it "should hit p2", ->
      expect(@result[0]).toBe(p2)
    it "should set framestatus of both players", ->
      expect(p1.framestatus).toBe(38)
      expect(p2.framestatus).toBe(40)

  describe "Trade handling", ->
    beforeEach ->
      p1.hp = 100
      p2.hp = 100
      p1.percenthealth = 100
      p2.percenthealth = 100
      p1.framestatus = 0
      p2.framestatus = 0
      atkStack.p1.action = "a"
      atkStack.p2.action = "a"
      @trade = frameAdv()
    it "should trade when the frame advantage is even", ->
      expect(@trade[0]).toEqual(jasmine.any(Array))

