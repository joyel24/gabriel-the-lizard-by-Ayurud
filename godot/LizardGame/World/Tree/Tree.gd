extends AnimatedSprite

#variables
var mBodyCount : int = 0
var mCanBeHit : bool = true

#trunk animated sprite
onready var cTrunkSprite := $Trunk/TrunkSprite

#sounds
onready var cTunkHitSound := $TunkHitSound

#variables, childs an scene for the Apple
var mAppleMaxQuantity : int = 0
var mAppleStored : int = 0
export(PackedScene) var mApple
onready var cPivotPoint := $PivotPoint
onready var cAppleSpawnPoint := $PivotPoint/AppleSpawnPoint
onready var cReloadTimer := $ReloadTimer

var mAlpha : float = 1.0
onready var cLightParticles := $LeavesLightParticles
onready var cDarkParticles := $LeavesDarkParticles

###########
## READY ##
###########
func _ready() -> void:
	#if random number from 1 to 100 is greater than 20, double the tree size (big)
	randomize()
	if (randi() % 100) > 20:
		self.scale.x = 2
		self.scale.y = 2
	
	#set a random quantity of apple for this tree
	mAppleMaxQuantity = randi() %3 +1
	mAppleStored = mAppleMaxQuantity


##########################
## PROCESS              ##
##########################
# warning-ignore:unused_argument
func _process(delta) -> void:
	if mAppleStored <1 :
		self_modulate = Color(0.941176, 0.941176, 0, mAlpha)
		cLightParticles.self_modulate = Color(0.941176, 0.941176, 0)
		cDarkParticles.self_modulate = Color(0.941176, 0.941176, 0)
	else:
		self_modulate = Color(1, 1, 1, mAlpha)
		cLightParticles.self_modulate = Color(1, 1, 1)
		cDarkParticles.self_modulate = Color(1, 1, 1)

#1er choix Color(0.941176, 0.941176, 0)
#autre couleur : Color(0.623529, 0.407843, 0.098039)


#############################
## BODY ENTERING TREE AREA ##
#############################
# warning-ignore:unused_argument
func _on_TreeViewZone_body_entered(body) -> void:
	#add the entering body to body count
	mBodyCount = mBodyCount + 1
	
	#if there is at least one body and the sprite alpha value is still at 100%
	if mBodyCount >= 1:# && self.self_modulate == Color(1, 1, 1, 1):
		#alpha value is set to 50%
		mAlpha = 0.5
		#self.self_modulate.a = 0.5# = Color(1, 1, 1, 0.5)



############################
## BODY EXITING TREE AREA ##
############################
# warning-ignore:unused_argument
func _on_TreeViewZone_body_exited(body) -> void:
	#substract the exiting body to body count
	mBodyCount = mBodyCount - 1
	
	#if there is no more body and the sprite alpha value is still at 50%
	if mBodyCount == 0:# && self.self_modulate == Color(1, 1, 1, 0.5):
		#alpha value is set to 100%
		mAlpha = 1
		#self.self_modulate.a = 1# = Color(1, 1, 1, 1)


##################################
## TRUNK SPRITE ANIMATION's END ##
##################################
func _on_TrunkSprite_animation_finished() -> void:
	#if the finished animation is the HIT one, set the trunk hitable again and the IDLE animation
	if cTrunkSprite.animation == "HIT":
		mCanBeHit = true
		cTrunkSprite.play("IDLE")


##########################
## HURTBOX IS TRIGGERED ##
##########################
# warning-ignore:unused_argument
func _on_TrunkHurtBox_area_entered(area) -> void:
	#if the trunk can be hit, then set it to false, play the hit sound and animation
	if mCanBeHit == true:
		mCanBeHit = false
		cTrunkSprite.play("HIT")
		cTunkHitSound.play()
		
		#make an apple spawn if possible
		if mAppleStored > 0:
			#substract a stored apple
			mAppleStored -= 1
			
			#random angle around the tree
			var l_random_angle = randi() % 360 + 1
			cPivotPoint.rotation_degrees = l_random_angle
			
			#instance the apple and throw it on the opposite side of the trunk position
			var l_apple = mApple.instance()
			l_apple.global_position = cAppleSpawnPoint.global_position - get_parent().get_parent().global_position
			l_apple.mDirection = (l_apple.get_position() - self.get_position()).normalized()
			get_parent().call_deferred("add_child", l_apple)
		
		#start the reload timer if not running and at max apple capacity
		if cReloadTimer.is_stopped() && mAppleStored != mAppleMaxQuantity:
			var l_randomtime = randi() %11 +5
			cReloadTimer.start(l_randomtime)


############################
## APPLE RELOAD TIMER END ##
############################
func _on_ReloadTimer_timeout() -> void:
	#if the apple max capacity is not reached
	if mAppleStored < mAppleMaxQuantity:
		#add an apple
		mAppleStored += 1
		
		if mAppleStored < mAppleMaxQuantity:
			#restart the timer if still not at max else stop the timer
			var l_randomtime = randi() %11 +5
			cReloadTimer.start(l_randomtime)
		else:
			cReloadTimer.stop()
		
	else:
		#stop the timer
		cReloadTimer.stop()

