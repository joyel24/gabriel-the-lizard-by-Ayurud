extends KinematicBody2D

#hitbox (can be collected if enabled)
onready var cHitBox := $HitBox/CollisionShape2D

#speed variable with some randomness
var mFallingSpeed : int = 0

#Direction variable
var mDirection := Vector2.ZERO

#Shadow sprite
onready var cShadow := $Shadow

#Sounds
onready var cFallingSound := $FallingSound
onready var cPickupSound := $PickupSound

#pickable
var mPickable : bool = true


##########################
## PHYSIC PROCESS       ##
##########################
# warning-ignore:unused_argument
func _physics_process(delta) -> void:
	#movement execution with sliding option on colisions
	#if the direction vector is null, there is no movement
	var l_movement = mFallingSpeed * mDirection
	# warning-ignore:return_value_discarded
	move_and_slide(l_movement)


#################
## READY       ##
#################
func _ready() -> void:
	#set a random speed and make the apple fall from it spawning position
	randomize()
	mFallingSpeed = randi() %21 +70
	RiseAndFall()


############################
## RISE AND FALL FUNCTION ##
############################
func RiseAndFall() -> void:
	#play the falling sound
	cFallingSound.play()
	
	#Apple is rising
	var l_tween = create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	l_tween.tween_property(self, "scale", Vector2(3.0, 3.0), 0.3)
	l_tween.parallel().tween_property(cShadow, "position:x", -10.0, 0.3).from_current()
	l_tween.parallel().tween_property(cShadow, "position:y", 5.0, 0.3).from_current()
	l_tween.parallel().tween_property(cShadow, "modulate:a", 0.5, 0.3).from_current()
	yield(l_tween, "finished")
	
	#at the top reduce the speed
	var l_float_speed : float = mFallingSpeed
	mFallingSpeed = int(round(l_float_speed / 2))
	
	#Apple is falling
	l_tween = create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
	l_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.5)
	l_tween.parallel().tween_property(cShadow, "position:x", -2.0, 0.5).from_current()
	l_tween.parallel().tween_property(cShadow, "position:y", 1.0, 0.5).from_current()
	l_tween.parallel().tween_property(cShadow, "modulate:a", 1.0, 0.5).from_current()
	l_tween.parallel().tween_property(self, "mFallingSpeed", 0, 0.7).from_current()
	yield(l_tween, "finished")
	
	#the apple can now be collected
	cHitBox.disabled = false


########################
## PICKED UP FUNCTION ##
########################
func PickedUp() -> void:
	#called by other areas when collision occur
	if mPickable == true:
		mPickable = false
		LzEngine.gAppleAmount += 1
		
		#disable the HitBox and make the apple disapear
		set_deferred("cHitBox.disabled", true)
		self.visible = false
		
		#play the pickup sound, wait untill it's finished, then queue free
		cPickupSound.play()
		yield(cPickupSound, "finished")
		queue_free()

