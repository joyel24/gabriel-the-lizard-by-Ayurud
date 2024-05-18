extends KinematicBody2D

#player's state variable
var mPlayerState : String = "IDLE"

#player's direction vector variables
var mDirection := Vector2.ZERO
var mLastDirection := Vector2(1, 0)

#speed variables
const mNormalSpeed : int = 175
const mDashSpeed : int = 675#675
var mCurrentSpeed : int = mNormalSpeed

#dash variables
const mDashDuration : float = 0.12#0.16#0.10 
const mDashDelay : float = 0.2
var mDashAvailable : bool = true
var mDashFrame : Texture

#variable of the dedicated ghost effect scene
export(PackedScene) var mGhosteffect

#variable of the dedicated blood effect scene
export(PackedScene) var mBloodeffect

#variable of the dedicated player bullet scene
export(PackedScene) var mBullet
onready var cSpitParticles := $SpitParticles
onready var cBulletEmitter := $BulletEmitter
onready var cBulletTimer := $BulletTimer
onready var cBulletSound := $BulletSound
const mShootDelay : float = 0.6

#animated sprite child
onready var cAnimatedSprite := $AnimatedSprite

#timers
onready var cDashTimer := $DashTimer
onready var cGhostTimer := $GhostTimer
onready var cCanBeHitTimer := $CanBeHitTimer
onready var cBlinkTimer := $BlinkTimer

#sounds
onready var cWalkSound := $WalkSound
onready var cTongueSound := $TongueSound
onready var cDashSound := $DashSound
onready var cHitSound := $HitSound

#particles emitters
onready var cLeftPawParticles := $LeftPawParticles
onready var cRightPawParticles := $RightPawParticles
onready var cDustDashParticles := $DustDashParticles

#Tongue's collision hitbox
onready var cTongueCollision := $TongueHitBox/CollisionShape2D

#Lizard's HurtBox Collision Shape
onready var cHurtBoxCollisionShape := $HurtBox/CollisionShape2D

#camera
onready var cCamera2D = $Camera2D


#########
# READY #
#########
func _ready() -> void:
	#set the camera for shaking global script
	CameraShake.SetCamera(cCamera2D)
	#set the player into the engine
	LzEngine.gPlayer = self


##########################
## PROCESS              ##
##########################
# warning-ignore:unused_argument
func _process(delta) -> void:
	#call the current state function
	call(mPlayerState)
	
	#animate the player's sprite with the function
	animates_player()


##########################
## PHYSIC PROCESS       ##
##########################
# warning-ignore:unused_argument
func _physics_process(delta) -> void:
	#movement execution with sliding option on colisions
	#if the direction vector is null, there is no movement
	var l_movement = mCurrentSpeed * mDirection
	# warning-ignore:return_value_discarded
	move_and_slide(l_movement)


##########################
## ANIMATE THE SPRITE   ##
##########################
func animates_player() -> void:
	#set the animation speed
	match mPlayerState:
		"IDLE", "TONGUE":
			cAnimatedSprite.frames.set_animation_speed(mPlayerState, 12)
		"EAT":
			cAnimatedSprite.frames.set_animation_speed(mPlayerState, 32)
		"WALK":
			#walk animation speed depend of the Direction vector's length
			cAnimatedSprite.frames.set_animation_speed(mPlayerState, 5 + 7 * mDirection.length())
		"DEATH":
			cAnimatedSprite.frames.set_animation_speed("WALK", false)
		"WAIT":
			cAnimatedSprite.frames.set_animation_speed("IDLE", 12)
			cAnimatedSprite.play("IDLE")
			return
		_:
			return
			#If the state animation is not handled, then return to avoid trying to play it and get errors
	
	if mPlayerState != "DEATH":
		#play the animation whose name is matching the actual state
		cAnimatedSprite.play(mPlayerState)
	else:
		cAnimatedSprite.frames.set_animation_speed("WALK", false)
		cAnimatedSprite.play("WALK")


############################
## HANDLE GAMEPLAY INPUTS ##
############################
func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_circle"):
		#the test button !
		#GotHit(self.global_position)
		#LzEngine.EnemyKilled()
		pass
	
	match mPlayerState:
		"IDLE":
			#on IDLE state, SQUARE button (PS) = lizard's tongue attack state
			if event.is_action_pressed("ui_carre"):
				mPlayerState = "TONGUE"
				
			#on IDLE state, Triangle button (PS) = lizard's bullet attack
			if event.is_action_pressed("ui_triangle") && LzEngine.gAppleAmount >=1 && cBulletTimer.is_stopped():
				ShootABullet()
				
			#if event.is_action_pressed("ui_accept"):
			#	LzEngine.DataPrint()
			#	
			if event.is_action_pressed("ui_quitter"):
				#suicide to quit and return to main menu (=game over)
				LzEngine.gLife =1
				GotHit(Vector2.RIGHT)
		"WALK":
			#on WALK state, SQUARE button (PS) = lizard's tongue attack state
			if event.is_action_pressed("ui_carre"):
				mPlayerState = "TONGUE"
				
			#on WALK state, Triangle button (PS) = lizard's bullet attack
			if event.is_action_pressed("ui_triangle") && LzEngine.gAppleAmount >=1 && cBulletTimer.is_stopped():
				ShootABullet()
				
			#on WALK state, CROSS button (PS) = lizard's dash state BUT only if the dash is available
			if event.is_action_pressed("ui_croix") && mDashAvailable == true && LzEngine.gDashAmount > 0 && cDashTimer.is_stopped():
				#substract a dash from game's engine dash amount and emit the reload signal
				LzEngine.gDashAmount -= 1
				LzEngine.emit_signal("gDashReload")
				#store the actual animation frame in a variable for the ghost effect
				mDashFrame = cAnimatedSprite.frames.get_frame(mPlayerState, cAnimatedSprite.frame)
				#need a direction vector with a length of 1 (full power !)
				mDirection = mDirection.normalized()
				mPlayerState = "DASH"


####################
## SHOOT A BULLET ##
####################
func ShootABullet() -> void:
	#substract an apple
	LzEngine.gAppleAmount -= 1
	
	#instance a bullet and set a direction
	var l_bullet = mBullet.instance()
	l_bullet.global_position = cBulletEmitter.global_position
	l_bullet.mDirection = mLastDirection
	
	#spit particle
	cSpitParticles.restart()
	cSpitParticles.emitting = true
	
	#sound
	if cBulletSound.playing == false:
		cBulletSound.play()
	
	#add bullet as a child of the scene
	get_parent().add_child(l_bullet)
	
	#start the timer
	cBulletTimer.start(mShootDelay)


#############
## GOT HIT ##
#############
func GotHit(DamageSourceDirection : Vector2) -> void:
	#substract 1 life from game engine's stats
	LzEngine.gLife -= 1
	#Shake the camera : intensity(int), duration(float)
	CameraShake.Shake(20, 0.1)
	
	#if there is no more life, lunch Dying function, else take the hit
	if LzEngine.gLife <= 0:
		#disable the hurtbox
		cHurtBoxCollisionShape.set_deferred("disabled", true)
		
		#instance the blood effect
		var l_blood_effect : CPUParticles2D = mBloodeffect.instance()
		l_blood_effect.global_position = self.global_position
		l_blood_effect.direction.x = DamageSourceDirection.x
		l_blood_effect.direction.y = DamageSourceDirection.y
		#add it as a child of the player's parent scene
		#get_parent().add_child(l_blood_effect)
		get_parent().call_deferred("add_child", l_blood_effect)
		
		#DEATH state and call the dying function
		if mPlayerState != "DEATH":
			mPlayerState = "DEATH"
			Dying()
	else:
		#invunerability timer starts
		cCanBeHitTimer.start()
		#set the sprite whiter
		cAnimatedSprite.material.set_shader_param("mix_weight", 0.7)
		cAnimatedSprite.material.set_shader_param("whiten", true)
		#start the blink timer
		cBlinkTimer.start()
		
		#instance the blood effect
		var l_blood_effect : CPUParticles2D = mBloodeffect.instance()
		l_blood_effect.global_position = self.global_position
		l_blood_effect.direction.x = DamageSourceDirection.x
		l_blood_effect.direction.y = DamageSourceDirection.y
		#add it as a child of the player's parent scene
		#get_parent().add_child(l_blood_effect)
		get_parent().call_deferred("add_child", l_blood_effect)


##################
## LIZARD DEATH ##
##################
func Dying() -> void:
	#NEED A GAME OVER HANDLE HERE
	#send a signal for all enemy to stop
	#warning : camera shake
	LzEngine.gPlayer = null
	LzEngine.emit_signal("gPlayerDeath")
	CameraShake.SetNull()
	cAnimatedSprite.frames.set_animation_speed("WALK", false)
	pass


##########################
## DEATH STATE          ##
##########################
func DEATH() -> void:
	#set the direction vector equal to null, the player must not be able to move
	mDirection = Vector2.ZERO


##########################
## WAIT STATE           ##
##########################
func WAIT() -> void:
	#set the direction vector equal to null, the player must not be able to move
	mDirection = Vector2.ZERO


##########################
## IDLE STATE           ##
##########################
func IDLE() -> void:
	#get input vector
	mDirection = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#if the vector is not null, go to the WALK state
	if mDirection != Vector2.ZERO:
		 mPlayerState = "WALK"


##########################
## WALK STATE           ##
##########################
func WALK() -> void:
	#get input vector
	mDirection = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	#if the vecor is null, return to IDLE state
	if mDirection == Vector2.ZERO:
		 mPlayerState = "IDLE"
		
	#else set the direction, rotation, magnitude and sound
	else:
		#store the magnitude before normalizing the direction vector
		var l_magnitude = mDirection.length()
		#normalize the direction vector in order to get the right angle and direction
		mDirection = GetSpriteAngle(mDirection)
		#update the last direction
		mLastDirection = mDirection
		#apply back the stored magnitude
		mDirection = mDirection * l_magnitude
		#apply the angle to the rotation
		self.rotation = mDirection.angle()
		#if not already playing, start the walking sound effect
		if cWalkSound.playing == false:
			cWalkSound.play()


#################################
## GET ANGLE FOR THE  ROTATION ##
#################################
#usefull to avoid the "car driving effect" while changing lizard's direction with a gamepad's stick
func GetSpriteAngle(direction : Vector2) -> Vector2:
	if direction.angle() > 0.0:
		#positive
		if direction.angle() < 0.392699:
			#Right
			direction = Vector2(1, 0)
		else:
			if direction.angle() < 1.178097:
				#Down-Right
				direction = Vector2(0.707107, 0.707107)
			else:
				if direction.angle() < 1.963495:
					#Down
					direction = Vector2(0, 1)
				else:
					if direction.angle() < 2.748893:
						#Down-Left
						direction = Vector2(-0.707107, 0.707107)
					else:
						#Left
						direction = Vector2(-1, 0)
	else:
		#negative
		if direction.angle() > -0.392699:
			#Right
			direction = Vector2(1, 0)
		else:
			if direction.angle() > -1.178097:
				#Up-Right
				direction = Vector2(0.707107, -0.707107)
			else:
				if direction.angle() > -1.963495:
					#Up
					direction = Vector2(0, -1)
				else:
					if direction.angle() > -2.748893:
						#Up-Left
						direction = Vector2(-0.707107, -0.707107)
					else:
						#Left
						direction = Vector2(-1, 0)
	return direction


##########################
## DASH STATE           ##
##########################
func DASH() -> void:
	#if the dash's timer is not running -> begin to dash
	if cDashTimer.is_stopped() && mDashAvailable == true:
		#dashing is no longer available
		mDashAvailable = false
		#Disable the hurtbox
		cHurtBoxCollisionShape.disabled = true
		
		#instance the first ghost effect
		var l_ghost_effect = mGhosteffect.instance()
		#it take the player's actuel frame, rotation angle, global position
		l_ghost_effect.texture = mDashFrame
		l_ghost_effect.rotation = self.rotation
		l_ghost_effect.global_position = self.global_position
		#add it as a child of the player's parent scene
		get_parent().add_child(l_ghost_effect)
		
		#set the sprite a litlle whiter with the shader
		if cCanBeHitTimer.is_stopped():
			cAnimatedSprite.material.set_shader_param("mix_weight", 0.7)
			cAnimatedSprite.material.set_shader_param("whiten", true)
		
		#emit some dust/smoke particles
		cDustDashParticles.restart()
		cDustDashParticles.emitting = true
		
		#set the current speed to the dash speed
		mCurrentSpeed = mDashSpeed
		
		#play the dash sound effect
		cDashSound.play()
		
		#start the dash timer for the dash duration variable
		cDashTimer.start(mDashDuration)
		#start the ghost timer (duration is set in the timer itself)
		cGhostTimer.start()


##########################
## TONGUE STATE         ##
##########################
func TONGUE() -> void:
	#set the direction vector equal to null, the player must not be able to move
	mDirection = Vector2.ZERO


##########################
## EAT STATE            ##
##########################
func EAT() -> void:
	#set the direction vector equal to null, the player must not be able to move
	mDirection = Vector2.ZERO


##########################
## ANIMATION'S END CODE ##
##########################
func _on_AnimatedSprite_animation_finished() -> void:
	#at the end of complete animation, check the state
	match mPlayerState:
		#if the finished animation is TONGUE, then manke the Hitbox inactive and switch back to the IDLE state
		"TONGUE", "EAT":
			cTongueCollision.disabled = true
			mPlayerState = "IDLE"


##############################
## ANIMATION'S FRAME EVENTS ##
##############################
func _on_AnimatedSprite_frame_changed() -> void:
	#check the state at each new frame of the sprite's animation 
	match mPlayerState:
		"TONGUE":
			#during the tongue's animation, when the tongue reach its max range (frame 5)
			#play the tongue's sound effect and make the Hitbox active
			if cAnimatedSprite.frame == 5:
				cTongueCollision.disabled = false
				cTongueSound.play()
		"WALK":
			match cAnimatedSprite.frame:
				0:
					#at frame 0, if not already emitting, start to emit dirt paticles on the left paw
					if cLeftPawParticles.emitting ==  false:
						cLeftPawParticles.restart()
						cLeftPawParticles.emitting = true
				2:
					#at frame 2, if not already emitting, start to emit dirt paticles on the right paw
					if cRightPawParticles.emitting ==  false:
						cRightPawParticles.restart()
						cRightPawParticles.emitting = true
				_:
					pass


######################
## DASH TIMER'S END ##
######################
func _on_DashTimer_timeout() -> void:
	#check the player's state at the end of the dash timer
	match mPlayerState:
		"DASH":
			cDashTimer.stop()
			#if in DASH state, the dash duration is ending
			#set back to the normal speed and return to IDLE state
			mCurrentSpeed = mNormalSpeed
			mPlayerState = "IDLE"
			#Enable the hurtbox
			cHurtBoxCollisionShape.disabled = false
			#stop the shader effet that make the player's sprite whiter
			cAnimatedSprite.material.set_shader_param("whiten", false)
			#stop the ghost timer in order to stop making ghost instances pop out
			cGhostTimer.stop()
			#start the dash timer but for the delay between two dash
			cDashTimer.start(mDashDelay)
		_:
			#if not in the DASH state, the dash delay between two dash is ending
			#stop the timer and make dash available again
			cDashTimer.stop()
			mDashAvailable = true


#######################
## GHOST TIMER'S END ##
#######################
func _on_GhostTimer_timeout() -> void:
	#each time this timer is out, the player is still dashing, instance a ghost effect
	var l_ghost_effect = mGhosteffect.instance()
	#it take the player's actuel frame, rotation angle, global position
	l_ghost_effect.texture = mDashFrame
	l_ghost_effect.rotation = self.rotation
	l_ghost_effect.global_position = self.global_position
	#add it as a child of the player's parent scene
	get_parent().add_child(l_ghost_effect)


######################################
## HANDLE THE HURTBOX CASES - ENTER ##
######################################
func _on_HurtBox_area_entered(area : Area2D) -> void:
	if area.collision_layer == 8 && LzEngine.gAppleAmount < LzEngine.gMaxApple:
		#update the apple amount in the engine stats
		#LzEngine.gAppleAmount += 1
		#it's an apple ! we know it has a PickedUp function to call
		area.get_parent().PickedUp()
	
	if area.collision_layer == 32 && cCanBeHitTimer.is_stopped():
		#enemy bullet
		#only if sound disabled from enemy bullet destroy function
		cHitSound.play()
		#execute the got hit function
		GotHit(area.get_parent().mDirection)
		#destroy the bullet
		area.get_parent().DestroyTheBullet()
	
	if area.collision_layer == 4 && cCanBeHitTimer.is_stopped():
		#enemy
		#execute the got hit function
		cHitSound.play()
		GotHit((self.get_position() - area.get_parent().get_position()).normalized())



#####################################
## HANDLE THE HURTBOX CASES - EXIT ##
#####################################
func _on_HurtBox_area_exited(area : Area2D) -> void:
	if area.collision_layer == 32 && cCanBeHitTimer.is_stopped():
		#enemy bullet
		#only if sound disabled from enemy bullet destroy function
		cHitSound.play()
		#execute the got hit function
		GotHit(area.get_parent().mDirection)
		#destroy the bullet
		area.get_parent().DestroyTheBullet()
	
	if area.collision_layer == 4 && cCanBeHitTimer.is_stopped():
		#enemy
		#execute the got hit function
		cHitSound.play()
		GotHit((self.get_position() - area.get_parent().get_position()).normalized())



##############################
## THE TONGUE MEET AN APPLE ##
##############################
func _on_TongueHitBox_area_entered(area : Area2D) -> void:
	if area.collision_layer == 8 && LzEngine.gAppleAmount < LzEngine.gMaxApple:
		#EAT state !
		mPlayerState = "EAT"
		#update the apple amount in the engine stats
		#LzEngine.gAppleAmount += 1
		#it's an apple ! we know it has a PickedUp function to call
		area.get_parent().PickedUp()


########################
## BULLET TIMER'S END ##
########################
func _on_BulletTimer_timeout() -> void:
	cBulletTimer.stop()


############################
## CAN BE HIT TIMER'S END ##
############################
func _on_CanBeHitTimer_timeout() -> void:
	#invincibility is ending, stop blinking, set the player hitable again (visible and "canbehit" timer stopped
	cBlinkTimer.stop()
	cCanBeHitTimer.stop()
	if cAnimatedSprite.visible == false:
		cAnimatedSprite.visible = true


#######################
## BLINK TIMER'S END ##
#######################
func _on_BlinkTimer_timeout() -> void:
	#first time the blink timer ends, make stop the whiten option on the sprite
	if cAnimatedSprite.material.get_shader_param("whiten") == true:
		cAnimatedSprite.material.set_shader_param("whiten", false)
	
	#each time the blink timer ends, change the sprite's visibility
	if cAnimatedSprite.visible == true:
		cAnimatedSprite.visible = false
	else:
		cAnimatedSprite.visible = true
