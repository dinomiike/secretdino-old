# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# Frame data counts at 60 frames per second
$ ->
  # Greetings!
  console.log "Hello, fighter!"

  # Define the player object
  window.Player = (name, hp, sprite, normals) ->
    this.name = name
    this.maxhealth = hp
    this.hp = hp
    this.percenthealth = 100
    this.metercolor = "meter-full"
    this.sprite = sprite
    this.normals = normals
    this.specials = {}
    this.isKO = ->
      if this.hp <= 0
        true
      else
        false
    this.healthColor = ->
      if this.percenthealth == 100
        "meter-full"
      else if (this.percenthealth >= 81 && this.percenthealth <= 99)
        "meter-99"
      else if (this.percenthealth >= 51 && this.percenthealth <= 80)
        "meter-80"
      else if (this.percenthealth >= 21 && this.percenthealth <= 50)
        "meter-50"
      else if (this.percenthealth >= 0 && this.percenthealth <= 20)
        "meter-20"
    return "Player created!"

  # Initialize player 1!
  p1normals = {
    a:
      range: 1
      damage: 30
      startup: 3
      active: 3
      recovery: 6
      stun:
        hit: 15
        block: 10
        value: 50
    b:
      range: 1
      damage: 70
      startup: 3
      active: 3
      recovery: 12 
      stun:
        hit: 18
        block: 13
        value: 100
    c:
      range: 1
      damage: 100
      startup: 5
      active: 7
      recovery: 26
      stun:
        hit: 20
        block: 15
        value: 200
  }
  window.p1 = new Player "Ryu", 100, "ryu-p1.gif", p1normals

  # Initialize player 2!
  p2normals = {
    a:
      range: 1
      damage: 30
      startup: 4
      active: 4
      recovery: 9
      stun:
        hit: 15
        block: 10
        value: 50
    b:
      range: 1
      damage: 60
      startup: 10
      active: 3
      recovery: 14
      stun:
        hit: 18
        block: 13
        value: 80
    c:
      range: 1
      damage: 75
      startup: 10
      active: 6
      recovery: 16
      stun:
        hit: 20
        block: 15
        value: 140
  }
  window.p2 = new Player "Dhalsim", 100, "dhalsim-p2.gif", p2normals

  # Initialize the attack storage record
  window.atkStack =
    p1:
      action: null
    p2:
      action: null

  # Populate the character dom elements
  $(".one .name").append(p1.name)
  $(".one .p1sprite").attr("src", "/assets/sprites/fighter/"+p1.sprite)
  $(".one .hp").append(p1.hp)

  $(".two .name").append(p2.name)
  $(".two .p2sprite").attr("src", "/assets/sprites/fighter/"+p2.sprite)
  $(".two .hp").append(p2.hp)

  # Attack Button event bindings
  $(".controls button").on("click", ->
    console.log $(this).attr("class")
    parentElement = $($(this).parent()[0]).parent()[0]
    player = $(parentElement).attr("class").replace("controls ", "")
    # Assign the button input to attack
    attack = $(this).text()
    # If a non-attack button was hit...
    if (!attack)
      # Such as block...
      if ($(this).attr("class").indexOf("block"))
        # Insert block action to the attack stack
        atkStack[player].action = "block"
        attack = "block"
      else
        # Otherwise this isn't a vaild button
        console.log "Invalid button input"
    else
      # In this case, an attack button was pressed so we add the attack to the stack
      atkStack[player].action = attack
    console.log attack
    console.log player
    $(".action."+player).html(player+" readies a standing <b>"+attack+"</b> attack")
  )

  # Play Button event binding
  $("#play").on("click", ->
    frameAdv = (atkStack) ->
      p1Startup = p1.normals[atkStack.p1.action].startup
      p2Startup = p2.normals[atkStack.p2.action].startup
      if p1Startup < p2Startup
        return {
          player: p1,
          opponent: p2,
          playerLabel: "p1",
          targetLabel: "two"
        }
      else if p2Startup < p1Startup
        return {
          player: p2,
          opponent: p1,
          playerLabel: "p2",
          targetLabel: "one"
        }
      else if p1Startup == p2Startup
        return "trade"

    hit = (result) ->
      console.log result
      # If the result is not an object then it's considered a trade
      if typeof result == "object"
        result.opponent.hp -= result.player.normals[atkStack[result.playerLabel].action].damage
        if result.opponent.isKO()
          # Always set the hp to 0 on KO
          result.opponent.hp = 0
          result.opponent.percenthealth = 0
          console.log "K.O."
        else
          # Update percenthealth property
          result.opponent.percenthealth = (result.opponent.hp/result.opponent.maxhealth)*100
        # Reduce target health meter
        $("."+result.targetLabel+" .bar .meter-full").attr("style", "width: "+result.opponent.percenthealth+"%")
        # Check target health bar color
        colorCheck = result.opponent.healthColor()
        if colorCheck != result.opponent.metercolor
          result.opponent.metercolor = colorCheck
          $("."+result.targetLabel+" .bar .meter-full").addClass(colorCheck)
          colorCheck = ""
        $("."+result.targetLabel+" .hp").text(result.opponent.hp)
      else
        console.log result
        console.log "trade!!"
      
    # Ensure both players have input actions
    if atkStack.p1.action? && atkStack.p2.action?
      if atkStack.p1.action != "block"
        if atkStack.p2.action != "block"
          hit(frameAdv(atkStack))
        else
          console.log "Nai"

      # # # # # # # # # # #
      # If p1 didn't block
      #if atkStack.p1.action != "block"
      #  # Did p2 block?
      #  if atkStack.p2.action != "block"
      #    # Perform p2's attack on p1
      #    p1.hp -= p2.normals[atkStack.p2.action].damage
      #    if p1.isKO()
      #      # Always set the player hp to 0
      #      p1.hp = 0
      #      p1.percenthealth = 0
      #      console.log "K.O."
      #    else
      #      # Update percenthealth property
      #      p1.percenthealth = (p1.hp/p1.maxhealth)*100
      #    # Reduce p1's health meter
      #    $(".one .bar .meter-full").attr("style", "width: "+p1.percenthealth+"%")
      #    # Check p1's health bar color
      #    colorCheck = p1.healthColor()
      #    if colorCheck != p1.metercolor
      #      p1.metercolor = colorCheck
      #      $(".one .bar .meter-full").addClass(colorCheck)
      #      colorCheck = ""
      #    $(".one .hp").text(p1.hp)
      #  else
      #    # Both blocked!
      #    console.log "...Nothing happens!"
      #else
      #  # p1 blocked
      #  console.log "p1 block!"

      # If p2 didn't block
      #if atkStack.p2.action != "block"
      #  # Did p1 block?
      #  if atkStack.p1.action != "block"
      #    # Perform p1's attack on p2
      #    p2.hp -= p1.normals[atkStack.p1.action].damage
      #    if p2.isKO()
      #      # Always set the player hp to 0
      #      p2.hp = 0
      #      p2.percenthealth = 0
      #      console.log "K.O."
      #    else
      #      # Update percenthealth property
      #      p2.percenthealth = (p2.hp/p2.maxhealth)*100
      #    $(".two .bar .meter-full").attr("style", "width: "+p2.percenthealth+"%")
      #    # Check p2's health bar color
      #    colorCheck = p2.healthColor()
      #    if colorCheck != p2.metercolor
      #      p2.metercolor = colorCheck
      #      $(".two .bar .meter-full").addClass(colorCheck)
      #      colorCheck = ""
      #    $(".two .hp").text(p2.hp)
      #  else
      #    # Both blocked!
      #    console.log "...Nothing happens"
      #else
      #  # p2 blocked
      #  console.log "p2 block!"

      # Reset the player action descriptions
      $(".one .action").text("")
      $(".two .action").text("")

      # Reset the atkStack
      atkStack.p1.action = null
      atkStack.p2.action = null
    else
      console.log "Both players must submit attacks to play"
  )



