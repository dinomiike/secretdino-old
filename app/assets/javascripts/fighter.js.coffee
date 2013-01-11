# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# Frame data counts at 60 frames per second
$ ->
  # Greetings!
  console.log "Hello, fighter!"

  # Define the player object
  window.Player = (name, hp, linklimit, sprite, normals) ->
    this.name = name
    this.maxhealth = hp
    this.hp = hp
    this.percenthealth = 100
    this.metercolor = "meter-full"
    this.linklimit = linklimit
    this.framestatus = 0
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
        hit: 13
        block: 9
        value: 50
    b:
      range: 1
      damage: 70
      startup: 3
      active: 3
      recovery: 12 
      stun:
        hit: 19
        block: 13
        value: 100
    c:
      range: 1
      damage: 100
      startup: 5
      active: 7
      recovery: 26
      stun:
        hit: 38
        block: 20
        value: 200
  }
  # Player parameters: Name, HP, LinkLimit, Sprite (image name), Normals (object)
  window.p1 = new Player "Ryu", 100, 6, "ryu-p1.gif", p1normals

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
  # Player parameters: Name, HP, LinkLimit, Sprite (image name), Normals (object)
  window.p2 = new Player "Dhalsim", 100, 6, "dhalsim-p2.gif", p2normals

  # Initialize the attack storage record
  window.atkStack =
    p1:
      action: null
    p2:
      action: null

  # Helper functions
  # Frame Advantage, invoked by the Play button click event
  frameAdv = (atkStack) ->
    p1Startup = p1.framestatus + p1.normals[atkStack.p1.action].startup
    p2Startup = p2.framestatus + p2.normals[atkStack.p2.action].startup
    if p1Startup < p2Startup
      # Set p1 frame status to the total frames of their attack
      setFrameStatus(p1, p1.normals[atkStack.p1.action].startup + 
                         p1.normals[atkStack.p1.action].active +
                         p1.normals[atkStack.p1.action].recovery)
      # P2 receives the hit stun from the attack
      setFrameStatus(p2, p1.normals[atkStack.p1.action].stun.hit)
      #return {player: p1, opponent: p2, playerLabel: "p1", targetLabel: "two"}
      # Return the player who will be hit
      return p2;
    else if p2Startup < p1Startup
      #return {player: p2, opponent: p1, playerLabel: "p2", targetLabel: "one"}
      # Set P2 frame status to the total frames of the attack
      setFrameStatus(p2, p2.normals[atkStack.p2.action].startup +
                         p2.normals[atkStack.p2.action].active +
                         p2.normals[atkStack.p2.action].recovery)
      # P1 receives the hit stun from the attack
      setFrameStatus(p1, p2.normals[atkStack.p2.action].stun.hit)
      # Return the player who will be hit
      return p1;
    else if p1Startup == p2Startup
      return "trade"

  # Set the frame status property of the player sent to this function
  setFrameStatus = (player, frames) ->
    player.framestatus = frames

  # Process Hit, invoked by the Play button click event
  hit = (result) ->
    # If the result is not an object then it's considered a trade
    if typeof result == "object"
      # Hit impacts opponent hp
      result.opponent.hp -= result.player.normals[atkStack[result.playerLabel].action].damage
      # Inflict hit stun on opponent
      result.opponent.framestatus = result.player.normals[atkStack[result.playerLabel].action].stun.hit
      # Player frame status is frames of the attack
      result.player.framestatus = result.player.normals[atkStack[result.playerLabel].action].startup +
                                  result.player.normals[atkStack[result.playerLabel].action].active +
                                  result.player.normals[atkStack[result.playerLabel].action].recovery
      if result.opponent.isKO()
        # Always set the hp to 0 on KO
        result.opponent.hp = 0
        result.opponent.percenthealth = 0
        console.log "K.O."
      else
        # Otherwise just update percenthealth property
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
      console.log "trade!!"

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
    ###
    # TODO: all d-pad buttons resolve as blocks.
    # Implement neutral/forward/back jumps and crouches which link with attacks
    # Player should be able to input one movement and one action per turn
    # One action should not be limited to a single button, consider specials, command throws, command normals, etc.
    ###
    # If a non-attack button was hit...
    if ($(this).attr("class").indexOf("block") > 0)
      # Set action to block
      atkStack[player].action = "block"
      attack = "block"
    else
      # Otherwise an attack button was pressed, set the attack to the action button
      atkStack[player].action = attack
    console.log attack
    console.log player
    $(".action."+player).html(player+" readies a standing <b>"+attack+"</b> attack")
  )

  # Play Button event binding
  $("#play").on("click", ->
    # Ensure both players have input actions
    if atkStack.p1.action? && atkStack.p2.action?
      if atkStack.p1.action != "block"
        if atkStack.p2.action != "block"
          hit(frameAdv(atkStack))
        else
          console.log "Nai"

      # Reset the player action descriptions
      $(".one .action").text("")
      $(".two .action").text("")

      # Reset the atkStack
      atkStack.p1.action = null
      atkStack.p2.action = null
    else
      console.log "Both players must submit attacks to play"
  )


