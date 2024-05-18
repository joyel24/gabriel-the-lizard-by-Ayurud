extends CanvasLayer

#childs
onready var cLife := $Control/Life
onready var cDash := $Control/Dash
onready var cDashReloadTimer := $Control/DashReloadTimer
onready var cAppleAmount := $Control/AppleAmount
onready var cGameOver := $Control/GameOver
onready var cAnimationP := $AnimationPlayer
onready var cOrbIcon := $Control/OrbIcon
onready var cOrbLabel := $Control/OrbLabel

onready var cGameTime := $Control/GameTime
onready var cLevelTime := $Control/LevelTime

onready var cGlobalScore := $Control/GlobalScore
onready var cLevelScore := $Control/LevelScore
onready var cMultiplier := $Control/Multiplier


###########
## READY ##
###########
func _ready() -> void:
	cGameOver.modulate.a = 0
	#connect to the game engine signals
	# warning-ignore:return_value_discarded
	LzEngine.connect("gLifeChanged", self, "_On_Life_Changed")
	# warning-ignore:return_value_discarded
	LzEngine.connect("gDashAmountChanged", self, "_On_Dash_Amount_Changed")
	# warning-ignore:return_value_discarded
	LzEngine.connect("gDashReload", self, "_On_Lunch_Reload_Dash_Timer")
	# warning-ignore:return_value_discarded
	LzEngine.connect("gAppleAmountChanged", self, "_On_Apple_Amount_Changed")
	# warning-ignore:return_value_discarded
	LzEngine.connect("gGotTheOrb", self, "_On_Orb_Picked_Up")
	
	#update the hearts and dash texture rects
	cLife.rect_size = Vector2(LzEngine.gLife * 18, 18)
	cDash.rect_size = Vector2(LzEngine.gDashAmount * 13, 16)
	cAppleAmount.text = "x" + str(LzEngine.gAppleAmount)
	_On_Apple_Amount_Changed()


##########################
## PROCESS              ##
##########################
# warning-ignore:unused_argument
func _process(delta) -> void:
	LzEngine.gGametime = LzEngine.gGametime + delta
	LzEngine.gLeveltime = LzEngine.gLeveltime + delta
	LzEngine.gMultiplier = LzEngine.gMultiplier - (0.08*delta)
	#var l_gtime : float = float(cGameTime.text)
	cGameTime.text = str(LzEngine.gGametime)
	cLevelTime.text = str(LzEngine.gLeveltime)
	cMultiplier.text = str(LzEngine.gMultiplier)



####################################################
## RECEIVING LIFE CHANGED SIGNAL FROM GAME ENGINE ##
####################################################
func _On_Life_Changed() -> void:
	#update the hearts texture rect
	cLife.rect_size = Vector2(LzEngine.gLife * 18, 18)


####################################################
## RECEIVING PICKEDUP ORB SIGNAL FROM GAME ENGINE ##
####################################################
func _On_Orb_Picked_Up() -> void:
	#show or hide the orb on UI
	if LzEngine.gOrb == true:
		cOrbIcon.visible = true
		cOrbLabel.visible = true
	else:
		cOrbIcon.visible = false
		cOrbLabel.visible = false


###########################################################
## RECEIVING DASH AMOUNT CHANGED SIGNAL FROM GAME ENGINE ##
###########################################################
func _On_Dash_Amount_Changed() -> void:
	#update the Dash texture rect
	cDash.rect_size = Vector2(LzEngine.gDashAmount * 13, 16)


###########################################################
## RECEIVING DASH AMOUNT CHANGED SIGNAL FROM GAME ENGINE ##
###########################################################
func _On_Apple_Amount_Changed() -> void:
	#update the apple amount
	cAppleAmount.text = "x" + str(LzEngine.gAppleAmount)
	#if we are at max apple capacity, the text gonna be red, else remove color override (back to white)
	if LzEngine.gAppleAmount == LzEngine.gMaxApple:
		cAppleAmount.add_color_override("font_color", Color(1,0,0))
	else:
		cAppleAmount.remove_color_override("font_color")


############################
## HANDLE GAMEPLAY INPUTS ##
############################
#func _unhandled_input(event : InputEvent) -> void:
	#if event.is_action_pressed("ui_quitter"):
	#	LzEngine.gotomenu()
	
	#if we are using this game, and this UI
	#if self.visible == true:
		#if event.is_action_pressed("ui_pause"):
			#if get_tree().paused == false:
			#	get_tree().paused = true
			#else:
			#	get_tree().paused = false


####################################################
## RECEIVING RELOAD TIMER SIGNAL FROM GAME ENGINE ##
####################################################
func _On_Lunch_Reload_Dash_Timer() -> void:
	#if the reload timer is not already running, start it
	if cDashReloadTimer.is_stopped():
		cDashReloadTimer.start(1.6-(LzEngine.gDashReducerAmount * LzEngine.gDashReducerQuantity))


############################
## DASH RELOAD TIMER ENDS ##
############################
func _on_DashReloadTimer_timeout():
	#add dash to the game's engine dash amount
	if LzEngine.gDashAmount < LzEngine.gMaxDash:
		LzEngine.gDashAmount += 1
	
	#still need to reload ?
	if LzEngine.gDashAmount == LzEngine.gMaxDash:
		cDashReloadTimer.stop()
	else:
		cDashReloadTimer.start(1.6-(LzEngine.gDashReducerAmount * LzEngine.gDashReducerQuantity))


func _on_AnimationPlayer_animation_finished(_anim_name):
	if cGameOver.text == "GAME OVER":
		LzEngine.emit_signal("gPlayerDeath")
	else:
		LzEngine.emit_signal("gPlayerWin")


func levelup() -> void:
	cGameOver.modulate.a = 0
	#if LzEngine.gDifficulty != 10:
	#	LzEngine.gDifficulty = LzEngine.gDifficulty+1
	#LzEngine.gMaxDash = LzEngine.gMaxDash + 1
	#LzEngine.gDashAmount = LzEngine.gMaxDash
	#LzEngine.gLife = LzEngine.gLife+1
	#LzEngine.gMaxApple = LzEngine.gMaxApple+1
	#LzEngine.gAppleAmount = LzEngine.gAppleAmount

