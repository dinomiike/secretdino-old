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
      damage: 5
    b:
      range: 1
      damage: 8
    c:
      range: 1
      damage: 12
  }
  window.p1 = new Player "Ryu", 100, "ryu-p1.gif", p1normals

  # Initialize player 2!
  p2normals = {
    a:
      range: 1
      damage: 3
    b:
      range: 2
      damage: 6
    c:
      range: 3
      damage: 12
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
    parentElement = $(this).parent()[0]
    player = $(parentElement).attr("class").replace("controls ", "")
    attack = $(this).text()
    atkStack[player].action = attack
    console.log attack
    console.log player
    $(".action."+player).html(player+" readies a standing <b>"+attack+"</b> attack")
  )

  # Play Button event binding
  $("#play").on("click", ->
    if atkStack.p1.action? && atkStack.p2.action?
      # Perform p2's attack on p1
      p1.hp -= p2.normals[atkStack.p2.action].damage
      if p1.isKO()
        # Always set the player hp to 0
        p1.hp = 0
        p1.percenthealth = 0
        console.log "K.O."
      else
        # Update percenthealth property
        p1.percenthealth = (p1.hp/p1.maxhealth)*100
      # Reduce p1's health meter
      $(".one .bar .meter-full").attr("style", "width: "+p1.percenthealth+"%")
      # Check p1's health bar color
      colorCheck = p1.healthColor()
      if colorCheck != p1.metercolor
        p1.metercolor = colorCheck
        $(".one .bar .meter-full").addClass(colorCheck)
        colorCheck = ""
      $(".one .hp").text(p1.hp)

      # Perform p1's attack on p2
      p2.hp -= p1.normals[atkStack.p1.action].damage
      if p2.isKO()
        # Always set the player hp to 0
        p2.hp = 0
        p2.percenthealth = 0
        console.log "K.O."
      else
        # Update percenthealth property
        p2.percenthealth = (p2.hp/p2.maxhealth)*100
      $(".two .bar .meter-full").attr("style", "width: "+p2.percenthealth+"%")
      # Check p2's health bar color
      colorCheck = p2.healthColor()
      if colorCheck != p2.metercolor
        p2.metercolor = colorCheck
        $(".two .bar .meter-full").addClass(colorCheck)
        colorCheck = ""
      $(".two .hp").text(p2.hp)

      # Reset the player action descriptions
      $(".one .action").text("")
      $(".two .action").text("")

      # Reset the atkStack
      atkStack.p1.action = null
      atkStack.p2.action = null
    else
      console.log "Both players must submit attacks to play"
  )

  # Helper functions
  #isKO = (player) ->
  #  if player.hp >= 0
  #    true
  #  else
  #    false


