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
    this.linkpoints = 0
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
      weight: 2
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
      weight: 3
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
      weight: 7
      stun:
        hit: 40
        block: 26
        value: 200
  }
  # Player parameters: Name, HP, LinkLimit, Sprite (image name), Normals (object)
  window.p1 = new Player "Ryu", 1000, 6, "ryu-p1.gif", p1normals

  # Initialize player 2!
  p2normals = {
    a:
      range: 1
      damage: 30
      startup: 3 # normally 4, change it back later
      active: 4
      recovery: 9
      weight: 2
      stun:
        hit: 16
        block: 10
        value: 50
    b:
      range: 1
      damage: 60
      startup: 10
      active: 3
      recovery: 14
      weight: 3
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
      weight: 7
      stun:
        hit: 20
        block: 15
        value: 140
  }
  # Player parameters: Name, HP, LinkLimit, Sprite (image name), Normals (object)
  window.p2 = new Player "Dhalsim", 1000, 6, "dhalsim-p2.gif", p2normals

  # Initialize the attack storage record
  # Currently doesn't function as a stack but I think it will be when the game is finished
  window.atkStack =
    p1:
      action: null
    p2:
      action: null
    exchange: null

  # Initialize the status helpers on the page
  $(".one .status .frameStatus .label").text(p1.framestatus)
  $(".one .status .linkLimit .label").text(p1.linklimit)
  $(".one .status .linkPoints .label").text(p1.linkpoints)

  $(".two .status .frameStatus .label").text(p2.framestatus)
  $(".two .status .linkLimit .label").text(p2.linklimit)
  $(".two .status .linkPoints .label").text(p2.linkpoints)

  ##########################################################################################
  # Helper functions

  # Frame Advantage, invoked by the Play button click event
  # Determines the player who has frame advantage and returns the player(s) who should be hit (aka sent to hit())
  window.frameAdv = ->
    # 1. Did player 1 block?
    #   Y.
    #     A. Did player 2 block?
    #       Y. Both blocked: frame reset, return
    #       N. Player 2 has frame advantage
    #         - Player 1 gets block stun
    #         - Player 2 wins the exchange
    #         - Player 2 get total frames
    #         - Return Player 1 (as hit) with 0 damage
    #   N.
    #     A. Did player 2 block?
    #       Y. Player 1 has frame advantaae
    #         - Player 2 gets block stun
    #         - Player 1 wins the exchange
    #         - Player 1 gets total frames
    #         - Return Player 2 (as hit) with 0 damage
    #       N. Determine frame advantage and who will get hit

    if atkStack.p1.action == "block"
      if atkStack.p2.action == "block"
        # Both players blocked, the frames are reset
        return
      else
        # p1 blocked, p2 did not, p2 has frame advantage
        # Add lp of this normal to p2, even if blocked, the pushback amount is the same
        p2.linkpoints += p2.normals[atkStack.p2.action].weight
        # Check for pushback
        if isPushback()
          # Frame reset for both players
          setFrameStatus(p1, 0)
          setFrameStatus(p2, 0)
        else
          # Set p1 block stun
          setFrameStatus(p1, p2.normals[atkStack.p2.action].stun.block)
          # p2 wins the exchange
          atkStack.exchange = p2
          # Set P2 total frames
          setFrameStatus(p2, p2.normals[atkStack.p2.action].startup + 
                             p2.normals[atkStack.p2.action].active + 
                             p2.normals[atkStack.p2.action].recovery)
        # Return P1 to hit(): Damage is 0 because p1 blocked
        return [p1, 0, "one"]
    else
      if atkStack.p2.action == "block"
        # P1 did not block, P2 did, P1 has frame advantage
        # Add lp of this normal to p1
        p1.linkpoints += p1.normals[atkStack.p1.action].weight
        # Check for pushback
        if isPushback()
          # Frame reset for both players
          setFrameStatus(p1, 0)
          setFrameStatus(p2, 0)
        else
          # Set P2 block stun
          setFrameStatus(p2, p1.normal[atkStack.p1.action].stun.block)
          # p1 wins the exchange
          atkStack.exchange = p1
          # Set P1 total frames
          setFrameStatus(p1, p1.normals[atkStack.p1.action].startup + 
                             p1.normals[atkStack.p1.action].active + 
                             p1.normals[atkStack.p1.action].recovery)
        # Return P2 to hit(): Damage is 0 because p2 blocked
        return [p2, 0, "two"]
      else
        # Determine frame advantage as lowest sum of frame disadvantage and startup frames of each players normal
        p1Startup = p1.framestatus + p1.normals[atkStack.p1.action].startup
        p2Startup = p2.framestatus + p2.normals[atkStack.p2.action].startup
        if p1Startup < p2Startup
          # Add lp of this normal to p1
          p1.linkpoints += p1.normals[atkStack.p1.action].weight
          # Check for pushback
          # TODO: If pushback is made, isPushback should be resetting lp of the exchange winner
          if isPushback()
            # p1 lands the attack, now reset the exchange winner
            atkStack.exchange = null
            # Frame reset for both players
            setFrameStatus(p1, 0)
            setFrameStatus(p2, 0)
          else
            # p1 lands the attack but hasn't broken the link limit
            atkStack.exchange = p1
            # Set p1 frame status to the total frames of their attack
            setFrameStatus(p1, p1.normals[atkStack.p1.action].startup + 
                               p1.normals[atkStack.p1.action].active +
                               p1.normals[atkStack.p1.action].recovery)
            # p2 receives the hit stun from the attack
            setFrameStatus(p2, p1.normals[atkStack.p1.action].stun.hit)
          # Return the player who will be hit and the damage amount
          return [p2, p1.normals[atkStack.p1.action].damage, "two"];
        else if p2Startup < p1Startup
          # Add lp of this normal to p2
          p2.linkpoints += p2.normals[atkStack.p2.action].weight
          if isPushback()
            # p2 lands the attack, now reset the exchange winner
            atkStack.exchange = null
            # Frame reset for both players
            setFrameStatus(p1, 0)
            setFrameStatus(p2, 0)
          else
            # p2 lands the attack but hasn't broken the link limit
            atkStack.exchange = p2
            # Set p2 frame status to the total frames of the attack
            setFrameStatus(p2, p2.normals[atkStack.p2.action].startup +
                               p2.normals[atkStack.p2.action].active +
                               p2.normals[atkStack.p2.action].recovery)
            # p1 receives the hit stun from the attack
            setFrameStatus(p1, p2.normals[atkStack.p2.action].stun.hit)
          # Return the player who will be hit
          return [p1, p2.normals[atkStack.p2.action].damage, "one"]
        else if p1Startup == p2Startup
          # Trade! Nobody won the exchange
          atkStack.exchange = null
          # A trade resets anyone's possible combo string, so return to 0
          p1.linkpoints = 0
          p2.linkpoints = 0
          #Both players are hit, send both to the hit function
          return [[p1, p2.normals[atkStack.p2.action].damage, "one"], [p2, p1.normals[atkStack.p1.action].damage, "two"]]

  # Set the frame status property of the player sent to this function
  # TODO: This should be scoped within frameAdv() because only that function should be setting frames
  # Leaving it like this for now to test
  window.setFrameStatus = (player, frames) ->
    player.framestatus = frames

  # Process Hit, invoked by the Play button click event
  # result[0] is the Player instance (object)
  # result[1] is the amount of damage this player is taking
  # result[2] is the string id of the player, used for CSS
  window.hit = (result) ->
    if typeof result != "undefined"
      # Look at the first item of the result array, if it's [object Array], it's a trade, both players are hit
      if Object.prototype.toString.call(result[0]) == "[object Object]"
        # Hit impacts opponent hp, if opponent hp is below 0, set it to 0, otherwise set it to the value
        if result[0].hp - result[1] < 0
          result[0].hp = 0
          result[0].percenthealth = 0
        else
          result[0].hp -= result[1]
          result[0].percenthealth = (result[0].hp/result[0].maxhealth)*100

        # Reduce target health meter
        $("."+result[2]+" .bar .meter-full").attr("style", "width: "+result[0].percenthealth+"%")
        # Check target health bar color
        colorCheck = result[0].healthColor()
        if colorCheck != result[0].metercolor
          result[0].metercolor = colorCheck
          $("."+result[2]+" .bar .meter-full").addClass(colorCheck)
          colorCheck = ""
          $("."+result[2]+" .hp").text(result[0].hp)
      else
        console.log "trade!!"
        # In the event of a trade, let's run hit on each item in the array
        # TODO: Modify result damage from both players to dmg * 0.75 (on trade only), since full dmg shouldn't be possible
        _.each(result, hit)

  # Pushback: If attacker has hit the opponent too many times, the opponent gets pushed back.
  # This prevents 1-combo-kills. Pushed back opponent is out of range for another hit and they incur a penalty of 
  # pushback frames that is equal to half of the total frames that sent them into pushback status. Frames added to
  # the startup of opponent's next move, as they need additional time to get their body back into position to fight
  window.isPushback = ->
    if atkStack.exchange != null && atkStack.exchange.linkpoints >= atkStack.exchange.linklimit
      console.log "Pushback!"
      # On Pushback, perform a frame and link reset
      p1.linklimit = 0
      p1.linkpoints = 0
      p1.framestatus = 0

      p2.linklimit = 0
      p2.linkpoints = 0
      p2.framestatus = 0
      return true
    else
      return false

  # Populate the character dom elements
  $(".one .name").append(p1.name)
  $(".one .p1sprite").prop("src", "/assets/sprites/fighter/"+p1.sprite)
  $(".one .hp").append(p1.hp)

  $(".two .name").append(p2.name)
  $(".two .p2sprite").prop("src", "/assets/sprites/fighter/"+p2.sprite)
  $(".two .hp").append(p2.hp)

  # Attack Button event bindings
  $(".controls button").on("click", ->
    console.log $(this).prop("class")
    parentElement = $($(this).parent()[0]).parent()[0]
    player = $(parentElement).prop("class").replace("controls ", "")
    # Assign the button input to attack
    attack = $(this).text()
    ###
    # TODO: all d-pad buttons resolve as blocks.
    # Implement neutral/forward/back jumps and crouches which link with attacks
    # Player should be able to input one movement and one action per turn
    # One action should not be limited to a single button, consider specials, command throws, command normals, etc.
    ###
    # If a non-attack button was hit...
    if ($(this).prop("class").indexOf("block") > 0)
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
      # Hit the player without frame advantage
      hit(frameAdv())
      # Anybody knocked out?
      if p1.isKO() && p2.isKO()
        # Double KO! It does exist!!
        $(".ko").text("Double K.O.")
        $("#koModal").modal("show")
      else if p1.isKO()
        # P1 KO'd!
        $(".ko").text("K.O.")
        $("#koModal").modal("show")
      else if p2.isKO()
        # P2 KO'd!
        $(".ko").text("K.O.")
        $("#koModal").modal("show")
      else
        # The fight continues!

      # Reset the player action descriptions
      $(".one .action").text("")
      $(".two .action").text("")

      # Reset the atkStack
      atkStack.p1.action = null
      atkStack.p2.action = null

      # Update the status display
      $(".one .status .frameStatus .label").text(p1.framestatus)
      $(".one .status .linkLimit .label").text(p1.linklimit)
      $(".one .status .linkPoints .label").text(p1.linkpoints)

      $(".two .status .frameStatus .label").text(p2.framestatus)
      $(".two .status .linkLimit .label").text(p2.linklimit)
      $(".two .status .linkPoints .label").text(p2.linkpoints)
    else
      console.log "Both players must submit attacks to play"
  )


