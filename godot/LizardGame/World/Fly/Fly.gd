extends KinematicBody2D

#variables
var mTarget : KinematicBody2D = null
var mState : String = "DEATH"

#life variables
var mLife = 3

#Fly's direction vector variables
var mDirection := Vector2.ZERO
var mLastDirection := Vector2(1, 0)
var mKnockbackDirection := Vector2.ZERO

#speed variables
var mNormalSpeed : float = 50.0
const mDashSpeed : int = 500
const mDashDuration : float = 0.25
var mCurrentSpeed : float = mNormalSpeed
var mKnockbackSpeed : float = 0.0
const mKnockbackMax : float = 80.0

#distance variables
var mAwakeDistance : float = 200.0
var mTooClose : float = 100.0

#childs
onready var cWaitTimer := $WaitTimer
onready var cBlinkTimer := $BlinkTimer
onready var cAnimatedSprite := $AnimatedSprite
onready var cEyes := $Eyes
onready var cHurtBoxCollisionShape := $Hurtbox/CollisionShape2D
onready var cCollision := $CollisionShape2D
onready var cHitSound := $HitSound
onready var cExplosionSound := $ExplosionSound
onready var cSpawningSound := $SpawningSound

#variable of the dedicated player bullet scene
export(PackedScene) var mBullet
var mBulletToShoot : int = 0
onready var cSpitParticles := $SpitParticles
onready var cBulletSound := $BulletSound
onready var cBulletAxis := $BulletAxis
onready var cBulletEmitter = $BulletAxis/BulletEmitter

#variables of the dedicated ghost and dash effect scene
export(PackedScene) var mGhosteffect
onready var cDashTimer := $DashTimer
onready var cGhostTimer := $GhostTimer
var mDashFrame : Texture
onready var cDustDashParticles := $DustDashParticles
onready var cDashSound := $DashSound

#variable of the dedicated blood effect scene
export(PackedScene) var mBloodeffect

#attack dictionary
var mAttackList = {
	1: "DASHINGATTACK",
	2: "SINGLESHOT",
	3: "SLOWSHOTGUN",
	4: "FASTSHOTGUN",
	5: "TRISHOT",
	6: "UZI",
	7: "NOVA",
	8: "FASTNOVA",
	9: "ROTATORRIGHT",
	10: "ROTATORLEFT"
}
##################################TEMPLATES##########################################
#attack templates
var mDasher = {1: "DASHINGATTACK", 2: "DASHINGATTACK", 3: "DASHINGATTACK", 4: "DASHINGATTACK", 5: "DASHINGATTACK", 6: "DASHINGATTACK", 7: "DASHINGATTACK", 8: "SINGLESHOT", 9: "TRISHOT", 10: "TRISHOT"}
var mSimpleGun = {1: "DASHINGATTACK", 2: "DASHINGATTACK", 3: "SINGLESHOT", 4: "SINGLESHOT", 5: "SINGLESHOT", 6: "TRISHOT", 7: "TRISHOT", 8: "TRISHOT", 9: "TRISHOT", 10: "TRISHOT"}
var mShotGun = {1: "DASHINGATTACK", 2: "DASHINGATTACK", 3: "SLOWSHOTGUN", 4: "SLOWSHOTGUN", 5: "SLOWSHOTGUN", 6: "SLOWSHOTGUN", 7: "FASTSHOTGUN", 8: "FASTSHOTGUN", 9: "FASTSHOTGUN", 10: "FASTSHOTGUN"}
var mUzi = {1: "DASHINGATTACK", 2: "DASHINGATTACK", 3: "TRISHOT", 4: "TRISHOT", 5: "TRISHOT", 6: "UZI", 7: "UZI", 8: "UZI", 9: "UZI", 10: "UZI"}
var mNova = {1: "DASHINGATTACK", 2: "DASHINGATTACK", 3: "NOVA", 4: "NOVA", 5: "NOVA", 6: "NOVA", 7: "FASTNOVA", 8: "FASTNOVA", 9: "FASTNOVA", 10: "FASTNOVA"}
var mRotator = {1: "DASHINGATTACK", 2: "DASHINGATTACK", 3: "ROTATORRIGHT", 4: "ROTATORRIGHT", 5: "ROTATORRIGHT", 6: "ROTATORRIGHT", 7: "ROTATORLEFT", 8: "ROTATORLEFT", 9: "ROTATORLEFT", 10: "ROTATORLEFT"}
var mFull = {1: "DASHINGATTACK", 2: "SINGLESHOT", 3: "SLOWSHOTGUN", 4: "FASTSHOTGUN", 5: "TRISHOT", 6: "UZI", 7: "NOVA", 8: "FASTNOVA", 9: "ROTATORRIGHT", 10: "ROTATORLEFT"}

var mTemplates = {1: mDasher, 2: mSimpleGun, 3: mShotGun, 4: mUzi, 5: mNova, 6: mRotator, 7: mFull}
##################################TEMPLATES##########################################

#not needed !!#######################
onready var label = $Label
#####################################


###########
## READY ##
###########
func _ready() -> void:
	#connection to the player's death signal
	# warning-ignore:return_value_discarded
	LzEngine.connect("gPlayerDeath", self, "_On_Player_Death")
	
	#initialize speed randomness #50-100
	randomize()
	mNormalSpeed = rand_range(mNormalSpeed, mNormalSpeed+50)
	mCurrentSpeed = mNormalSpeed
	
	#initialize close distance randomness #0-150
	mTooClose = rand_range(mTooClose-100, mTooClose+50)
	
	#initialise the eyes modulate to normal
	cEyes.modulate = Color(1, 1, 1, 1)
	
	cAnimatedSprite.play("SPAWNING")
	cSpawningSound.play()
	
	#add an enemy to the count
	LzEngine.gEnemyCount += 1
	#print(LzEngine.gEnemyCount)
	
	#animated_sprite.modulate = Color(2, 2, 2, 1)
	#var l_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	#l_tween.tween_property(animated_sprite, "modulate", Color(2, 2, 2, 1.0), 0.1).from_current()
	
	var random = RandomNumberGenerator.new()
	random.randomize()
	var l_enemytemplate : int
	match LzEngine.gDifficulty:
		1:
			l_enemytemplate = 1 + randi() %3
			mLife = 1 #1
		2:
			l_enemytemplate = 1 + randi() %4
			mLife = 1 + randi() %2 #1-2
		3:
			l_enemytemplate = 1 + randi() %5
			mLife = 1 +  randi() %2 #1-2
		4:
			l_enemytemplate = 1 + randi() %6
			mLife = 2 #2
		5:
			l_enemytemplate = 1 + randi() %6
			mLife = 2 #2
		6:
			l_enemytemplate = 1 + randi() %7
			mLife = 2 #2
		7:
			l_enemytemplate = 1 + randi() %7
			mLife = 2 + randi() %2 #2-3
		8:
			l_enemytemplate = 7
			mLife = 2 + randi() %2 #2-3
		9:
			l_enemytemplate = 7
			mLife = 2 + randi() %2 #2-3
		10:
			l_enemytemplate = 7
			mLife = 3 #3
	mAttackList = mTemplates[l_enemytemplate]
	#print(mTemplates[l_enemytemplate])



##########################
## PROCESS              ##
##########################
# warning-ignore:unused_argument
func _process(delta) -> void:

	### LABEL NOT NEEDED #####################
	if self.rotation != 0:
		label.set_rotation(-self.rotation)
	#label.text = mState# + " " + str(mCurrentSpeed) + " " + str(mTooClose)
	#label.text = str(mKnockbackDirection) + " " + str(mKnockbackSpeed)
	##########################################
	
	#knockback decrease if not null
	if mKnockbackSpeed > 0.0:
		mKnockbackSpeed = mKnockbackSpeed - (delta*150)
	else:
		mKnockbackSpeed = 0.0
	
	#call the current state function
	call(mState)


##########################
## PHYSIC PROCESS       ##
##########################
# warning-ignore:unused_argument
func _physics_process(delta) -> void:
	#movement execution with sliding option on colisions
	#if the direction vector is null, there is no movement
	var l_movement = mCurrentSpeed * mDirection
	
	#if there is a knockback speed, it's a priority
	if mKnockbackSpeed > 0.0:
		l_movement = mKnockbackSpeed * mKnockbackDirection

	# warning-ignore:return_value_discarded
	move_and_slide(l_movement)


#############
## GOT HIT ##
#############
func GotHit(DamageSourceDirection : Vector2) -> void:
	#substract 1 life
	mLife -= 1
	match mLife:
		2:
			var tempo = cEyes.frame
			cEyes.play("EYESRED")
			cEyes.frame = tempo
		1:
			var tempo = cEyes.frame
			cEyes.play("EYESPURPLE")
			cEyes.frame = tempo
	
	#if there is no more life, lunch Dying function, else take the hit
	if mLife <= 0:
		#disable the hurtbox and the collisionbox
		cHurtBoxCollisionShape.set_deferred("disabled", true)
		cCollision.set_deferred("disabled", true)
		
		#instance the blood effect
		var l_blood_effect : CPUParticles2D = mBloodeffect.instance()
		l_blood_effect.global_position = self.global_position
		l_blood_effect.direction.x = DamageSourceDirection.x
		l_blood_effect.direction.y = DamageSourceDirection.y
		#add it as a child of the player's parent scene
		get_parent().call_deferred("add_child", l_blood_effect)
		
		#scoring
		if mState != "DEATH":
			LzEngine.gLevelScore = LzEngine.gLevelScore + (LzEngine.gDifficulty*100)
			Lzui.cLevelScore.text = str(LzEngine.gLevelScore)
		
		#DEATH state and call the dying function
		mState = "DEATH"
		Dying()
	else:
		#set the sprite whiter
		cAnimatedSprite.material.set_shader_param("mix_weight", 0.7)
		cAnimatedSprite.material.set_shader_param("whiten", true)
		#start the blink timer
		cBlinkTimer.start()
		
		#knockback
		mKnockbackSpeed = mKnockbackMax
		mKnockbackDirection = DamageSourceDirection
		
		#instance the blood effect
		var l_blood_effect : CPUParticles2D = mBloodeffect.instance()
		l_blood_effect.global_position = self.global_position
		l_blood_effect.direction.x = DamageSourceDirection.x
		l_blood_effect.direction.y = DamageSourceDirection.y
		#add it as a child of the player's parent scene
		get_parent().call_deferred("add_child", l_blood_effect)


###############
## FLY DEATH ##
###############
func Dying() -> void:
	#call the function from the engine to substract the fly to the count
	#and free the area if needed
	LzEngine.EnemyKilled()
	
	#explosion sound
	cExplosionSound.play()
	
	#set back eyes modulate to normal and hide them before switching to explode animation
	cEyes.modulate = Color(1, 1, 1, 1)
	cEyes.visible = false
	
	#play the big explosion animation and wait until it's finished
	cAnimatedSprite.scale = cAnimatedSprite.scale*1.5
	cAnimatedSprite.play("EXPLODE")
	yield(cAnimatedSprite, "animation_finished")
	
	#queue free for the moment
	queue_free()


##########################
## DEATH STATE          ##
##########################
func DEATH() -> void:
	#set the direction vector equal to null, the fly must not be able to move
	mDirection = Vector2.ZERO
	mCurrentSpeed = 0.0
	mKnockbackDirection = Vector2.ZERO
	mKnockbackSpeed = 0.0


######################
## GET PLAYER STATE ##
######################
func GETPLAYER() -> void:
	#ask the engine for a target (the player)
	if mTarget == null:
		mTarget = LzEngine.GetPlayer()
		if mTarget != null:
			#if we got a target to look at, go IDLE state
			mState = "IDLE"


###########################
## PLAYER'S DEATH SIGNAL ##
###########################
func _On_Player_Death() -> void:
	#no more target
	mTarget = null


################
## IDLE STATE ##
################
func IDLE() -> void:
	#don't move
	mDirection = Vector2.ZERO
	
	#if there is no or no more target, go into the GETPLAYER state
	if mTarget == null:
		mState = "GETPLAYER"
		return
	
	if global_position.distance_to(mTarget.global_position) <= mAwakeDistance:
		#if the target is in the awake zone, go CHASE state
		mState = "CHASE"
		#shoot waiting timer
		cWaitTimer.start(rand_range(0.5, 2.5))
	else:
		if cWaitTimer.is_stopped():
			#50% to go wandering, 
			if randf() <= 0.5:
				#go wandering state during the next 0.5 to 1.5 seconds in a random direction
				cWaitTimer.start(rand_range(0.5, 1.5))
				mState = "WANDER"
				while mDirection == Vector2.ZERO:
					mDirection = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized()
				
				#update angle facing before moving
				mLastDirection = mDirection
				UpdateAngle(mDirection)
				
			else:
				#next try changing state in 0.5 to 1.5 seconds
				cWaitTimer.start(rand_range(0.5, 1.5))


##################
## WANDER STATE ##
##################
func WANDER() -> void:
	#if there is no or no more target, go into the IDLE state
	if mTarget == null:
		mState = "IDLE"
		return
	
	if global_position.distance_to(mTarget.global_position) <= mAwakeDistance:
		#if the target is in the awake zone, go CHASE state
		mState = "CHASE"
		#shoot waiting timer
		cWaitTimer.start(rand_range(0.5, 2.5))
	else:
		if cWaitTimer.is_stopped():
			#stop wandering, go to idle state at least for 0.5 to 1.5 seconds
			cWaitTimer.start(rand_range(0.5, 1.5))
			mState = "IDLE"


#################
## CHASE STATE ##
#################
func CHASE() -> void:
	#if there is no or no more target, go into the IDLE state
	if mTarget == null:
		mState = "IDLE"
		return
	
	#update the angle and direction to the target
	var l_vector_to_target = (mTarget.global_position - global_position).normalized()
	UpdateAngle(l_vector_to_target)
	
	#set the speed
	if global_position.distance_to(mTarget.global_position) <= mTooClose:
		mCurrentSpeed = 0
	else:
		mCurrentSpeed = mNormalSpeed


#########################################
## UPDATE ANGLE AND DIRECTION FUNCTION ##
#########################################
func UpdateAngle(l_vector_to_target) -> void:
	#calculate the rotation to face the target and tween to it
	var l_angle_to_target = Vector2(0, 1).rotated(self.rotation).angle_to(l_vector_to_target)
	var l_final_angle = self.rotation + l_angle_to_target
	
	var l_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	l_tween.tween_property(self, "rotation", l_final_angle, 0.1).from(self.rotation)
	
	#update the direction for movement
	mDirection = l_vector_to_target
	mLastDirection = mDirection


######################
## SINGLESHOT STATE ##
######################
func SINGLESHOT() -> void:
	#if there is no or no more target, go into the IDLE state
	if mTarget == null:
		#set eyes modulate back to normal
		cEyes.modulate = Color(1, 1, 1, 1)
		mState = "IDLE"
		return
	
	#update the angle and direction to the target
	var l_vector_to_target = (mTarget.global_position - global_position).normalized()
	UpdateAngle(l_vector_to_target)
	
	#set the speed
	if global_position.distance_to(mTarget.global_position) <= mTooClose:
		mCurrentSpeed = 0
	else:
		mCurrentSpeed = mNormalSpeed
	
	#instance a bullet
	InstanceABullet(cBulletEmitter.global_position, mLastDirection, 175)
	#spit particle
	cSpitParticles.restart()
	cSpitParticles.emitting = true
	#sound
	if cBulletSound.playing == false:
		cBulletSound.play()
	
	#back to the chase state and set eyes modulate to normal
	cEyes.modulate = Color(1, 1, 1, 1)
	mState = "CHASE"
	
	#start the timer for the next attack
	cWaitTimer.start(rand_range(1.5, 2.0))


#######################
## SLOWSHOTGUN STATE ##
#######################
func SLOWSHOTGUN() -> void:
	#if there is no or no more target, go into the IDLE state
	if mTarget == null:
		#set eyes modulate back to normal
		cEyes.modulate = Color(1, 1, 1, 1)
		mState = "IDLE"
		return
	
	#update the angle and direction to the target
	var l_vector_to_target = (mTarget.global_position - global_position).normalized()
	UpdateAngle(l_vector_to_target)
	
	#set the speed
	if global_position.distance_to(mTarget.global_position) <= mTooClose:
		mCurrentSpeed = 0
	else:
		mCurrentSpeed = mNormalSpeed
	
	var l_direction_vector : Vector2 = mLastDirection.rotated(PI*-20/180)
	InstanceABullet(cBulletEmitter.global_position, l_direction_vector, 88)
	# warning-ignore:unused_variable
	for i in range(4):
		#i starts at 0 to 3
		l_direction_vector = l_direction_vector.rotated(PI*10/180)
		InstanceABullet(cBulletEmitter.global_position, l_direction_vector, 88)
	
	#spit particle
	cSpitParticles.restart()
	cSpitParticles.emitting = true
	#sound
	if cBulletSound.playing == false:
		cBulletSound.play()
	
	#back to the chase state and set eyes modulate to normal
	cEyes.modulate = Color(1, 1, 1, 1)
	mState = "CHASE"
	
	#start the timer for the next attack
	cWaitTimer.start(rand_range(2.0, 3.0))


#######################
## FASTSHOTGUN STATE ##
#######################
func FASTSHOTGUN() -> void:
	#if there is no or no more target, go into the IDLE state
	if mTarget == null:
		#set eyes modulate back to normal
		cEyes.modulate = Color(1, 1, 1, 1)
		mState = "IDLE"
		return
	
	#update the angle and direction to the target
	var l_vector_to_target = (mTarget.global_position - global_position).normalized()
	UpdateAngle(l_vector_to_target)
	
	#set the speed
	if global_position.distance_to(mTarget.global_position) <= mTooClose:
		mCurrentSpeed = 0
	else:
		mCurrentSpeed = mNormalSpeed
	
	var l_direction_vector : Vector2 = mLastDirection.rotated(PI*-30/180)
	InstanceABullet(cBulletEmitter.global_position, l_direction_vector, 132)
	# warning-ignore:unused_variable
	for i in range(4):
		#i starts at 0 to 3
		l_direction_vector = l_direction_vector.rotated(PI*15/180)
		InstanceABullet(cBulletEmitter.global_position, l_direction_vector, 132)
	
	#spit particle
	cSpitParticles.restart()
	cSpitParticles.emitting = true
	#sound
	if cBulletSound.playing == false:
		cBulletSound.play()
	
	#back to the chase state and set eyes modulate to normal
	cEyes.modulate = Color(1, 1, 1, 1)
	mState = "CHASE"
	
	#start the timer for the next attack
	cWaitTimer.start(rand_range(2.0, 3.0))


###################
## TRISHOT STATE ##
###################
func TRISHOT() -> void:
	#if there is no or no more target, go into the IDLE state
	if mTarget == null:
		#set eyes modulate back to normal
		cEyes.modulate = Color(1, 1, 1, 1)
		mState = "IDLE"
		return
	
	#update the angle and direction to the target
	var l_vector_to_target = (mTarget.global_position - global_position).normalized()
	UpdateAngle(l_vector_to_target)
	
	#set the speed
	if global_position.distance_to(mTarget.global_position) <= mTooClose:
		mCurrentSpeed = 0
	else:
		mCurrentSpeed = mNormalSpeed
	
	if mBulletToShoot == 0:
		#no more bullet to shoot, return to CHASE state and set eyes modulate to normal
		cEyes.modulate = Color(1, 1, 1, 1)
		mState = "CHASE"
		#start the timer for the next attack
		cWaitTimer.start(rand_range(2.0, 3.0))
		return
	
	if cWaitTimer.is_stopped():
		#shoot and restart the timer
		mBulletToShoot-=1
		
		#instance a bullet
		InstanceABullet(cBulletEmitter.global_position, mLastDirection, 175)
		
		#spit particle
		cSpitParticles.restart()
		cSpitParticles.emitting = true
		
		#sound
		if cBulletSound.playing == false:
			cBulletSound.play()
		
		cWaitTimer.start(0.25)


###############
## UZI STATE ##
###############
func UZI() -> void:
	#if there is no or no more target, go into the IDLE state
	if mTarget == null:
		#set eyes modulate back to normal
		cEyes.modulate = Color(1, 1, 1, 1)
		mState = "IDLE"
		return
	
	#update the angle and direction to the target
	var l_vector_to_target = (mTarget.global_position - global_position).normalized()
	UpdateAngle(l_vector_to_target)
	
	#set the speed
	if global_position.distance_to(mTarget.global_position) <= mTooClose:
		mCurrentSpeed = 0
	else:
		mCurrentSpeed = mNormalSpeed
	
	if mBulletToShoot == 0:
		#no more bullet to shoot, return to CHASE state and set eyes modulate to normal
		cEyes.modulate = Color(1, 1, 1, 1)
		mState = "CHASE"
		#start the timer for the next attack
		cWaitTimer.start(rand_range(2.0, 3.0))
		return
	
	if cWaitTimer.is_stopped():
		#shoot and restart the timer
		mBulletToShoot-=1
		
		#instance a bullet with a few angle variation
		var l_angle_variation : int = 0
		l_angle_variation = randi() % 20 + 1
		if randi() % 2 == 0:
			l_angle_variation = l_angle_variation * -1
		
		var l_direction_vector : Vector2 = mLastDirection.rotated(PI*l_angle_variation/180)
		InstanceABullet(cBulletEmitter.global_position, l_direction_vector, 175)
		
		#spit particle
		cSpitParticles.restart()
		cSpitParticles.emitting = true
		
		#sound
		if cBulletSound.playing == false:
			cBulletSound.play()
		
		cWaitTimer.start(0.25)


################
## NOVA STATE ##
################
func NOVA() -> void:
	#if there is no or no more target, go into the IDLE state
	if mTarget == null:
		#set eyes modulate back to normal
		cEyes.modulate = Color(1, 1, 1, 1)
		mState = "IDLE"
		return
	
	#set the speed
	mCurrentSpeed = 0
	
	if mBulletToShoot > 0:
		#handle the nova unique shot
		mBulletToShoot-=1
		
		#update the angle and direction to the target
		var l_vector_to_target = (mTarget.global_position - global_position).normalized()
		UpdateAngle(l_vector_to_target)
		
		#Fly is rising
		var l_tween = create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
		l_tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.2)
		yield(l_tween, "finished")
		
		#Fly is falling
		l_tween = create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
		l_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
		yield(l_tween, "finished")
		
		#sound
		if cBulletSound.playing == false:
			cBulletSound.play()
		
		var l_shoot_vector : Vector2 = mLastDirection
		# warning-ignore:unused_variable
		for i in range(36):
			InstanceABullet(self.global_position, l_shoot_vector, 100)
			l_shoot_vector = l_shoot_vector.rotated(PI*10/180)
		
		#wait a little
		cWaitTimer.start(0.6)


####################
## FASTNOVA STATE ##
####################
func FASTNOVA() -> void:
	#if there is no or no more target, go into the IDLE state
	if mTarget == null:
		#set eyes modulate back to normal
		cEyes.modulate = Color(1, 1, 1, 1)
		mState = "IDLE"
		return
	
	#set the speed
	mCurrentSpeed = 0
	
	if mBulletToShoot > 0:
		#handle the nova unique shot
		mBulletToShoot-=1
		
		#update the angle and direction to the target
		var l_vector_to_target = (mTarget.global_position - global_position).normalized()
		UpdateAngle(l_vector_to_target)
		
		#Fly is rising
		var l_tween = create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
		l_tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.2)
		yield(l_tween, "finished")
		
		#Fly is falling
		l_tween = create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
		l_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
		yield(l_tween, "finished")
		
		#sound
		if cBulletSound.playing == false:
			cBulletSound.play()
		
		var l_shoot_vector : Vector2 = mLastDirection
		# warning-ignore:unused_variable
		for i in range(18):
			InstanceABullet(self.global_position, l_shoot_vector, 175)
			l_shoot_vector = l_shoot_vector.rotated(PI*20/180)
		
		#wait a little
		cWaitTimer.start(0.4)


########################
## ROTATORRIGHT STATE ##
########################
func ROTATORRIGHT() -> void:
	#if there is no or no more target, go into the IDLE state
	if mTarget == null:
		#set eyes modulate back to normal
		cEyes.modulate = Color(1, 1, 1, 1)
		mState = "IDLE"
		return
	
	#set the speed to zero, don't move during rotator phase
	mCurrentSpeed = 0
	
	if mBulletToShoot == -2 && cWaitTimer.is_stopped():
		#-1 then wait 0.1 for the UpdateAngle tween to finish
		mBulletToShoot += 1
		cWaitTimer.start(0.1)
	
	if mBulletToShoot == -1 && cWaitTimer.is_stopped():
		#initialize the roration
		#to 90° to the left of the fly in order to rotate to the right
		mLastDirection = mLastDirection.rotated(PI*-90/180).normalized()
		var l_vector_to_target = mLastDirection
		var l_angle_to_target = Vector2(0, 1).rotated(self.rotation).angle_to(l_vector_to_target)
		var l_final_angle = self.rotation + l_angle_to_target
		self.rotation = l_final_angle
		
		#bullet number during rotation and so are the numbre of the rotation
		mBulletToShoot = 18
	
	if mBulletToShoot > 0  && cWaitTimer.is_stopped() :
		#until there is no mort bullet to shoot, substract one bullet, shot and rotate
		mBulletToShoot -= 1
		
		#instance a bullet
		InstanceABullet(cBulletEmitter.global_position, mLastDirection, 175)
		#spit particle
		cSpitParticles.restart()
		cSpitParticles.emitting = true
		#sound
		if cBulletSound.playing == false:
			cBulletSound.play()
		
		#rotate 10° right
		mLastDirection = mLastDirection.rotated(PI*10/180).normalized()
		var l_vector_to_target = mLastDirection
		var l_angle_to_target = Vector2(0, 1).rotated(self.rotation).angle_to(l_vector_to_target)
		var l_final_angle = self.rotation + l_angle_to_target
		self.rotation = l_final_angle
		
		if mBulletToShoot > 0:
			#timer during bullets as long as there is bullet to shoot
			cWaitTimer.start(0.025)
		else:
			#back to the chase state and set eyes modulate to normal
			cEyes.modulate = Color(1, 1, 1, 1)
			mState = "CHASE"
			#start the timer for the next attack
			cWaitTimer.start(rand_range(1.5, 2.0))


#######################
## ROTATORLEFT STATE ##
#######################
func ROTATORLEFT() -> void:
	#if there is no or no more target, go into the IDLE state
	if mTarget == null:
		#set eyes modulate back to normal
		cEyes.modulate = Color(1, 1, 1, 1)
		mState = "IDLE"
		return
	
	#set the speed to zero, don't move during rotator phase
	mCurrentSpeed = 0
	
	if mBulletToShoot == -2 && cWaitTimer.is_stopped():
		#-1 then wait 0.1 for the UpdateAngle tween to finish
		mBulletToShoot += 1
		cWaitTimer.start(0.1)
	
	if mBulletToShoot == -1 && cWaitTimer.is_stopped():
		#initialize the roration
		#to 90° to the right of the fly in order to rotate to the left
		mLastDirection = mLastDirection.rotated(PI*90/180).normalized()
		var l_vector_to_target = mLastDirection
		var l_angle_to_target = Vector2(0, 1).rotated(self.rotation).angle_to(l_vector_to_target)
		var l_final_angle = self.rotation + l_angle_to_target
		self.rotation = l_final_angle
		
		#bullet number during rotation and so are the numbre of the rotation
		mBulletToShoot = 18
	
	if mBulletToShoot > 0  && cWaitTimer.is_stopped() :
		#until there is no mort bullet to shoot, substract one bullet, shot and rotate
		mBulletToShoot -= 1
		
		#instance a bullet
		InstanceABullet(cBulletEmitter.global_position, mLastDirection, 175)
		#spit particle
		cSpitParticles.restart()
		cSpitParticles.emitting = true
		#sound
		if cBulletSound.playing == false:
			cBulletSound.play()
		
		#rotate 10° left
		mLastDirection = mLastDirection.rotated(PI*-10/180).normalized()
		var l_vector_to_target = mLastDirection
		var l_angle_to_target = Vector2(0, 1).rotated(self.rotation).angle_to(l_vector_to_target)
		var l_final_angle = self.rotation + l_angle_to_target
		self.rotation = l_final_angle
		
		if mBulletToShoot > 0:
			#timer during bullets as long as there is bullet to shoot
			cWaitTimer.start(0.025)
		else:
			#back to the chase state and set eyes modulate to normal
			cEyes.modulate = Color(1, 1, 1, 1)
			mState = "CHASE"
			#start the timer for the next attack
			cWaitTimer.start(rand_range(1.5, 2.0))


#########################
## DASHINGATTACK STATE ##
#########################
func DASHINGATTACK() -> void:
	#if there is no or no more target, go into the IDLE state
	if mTarget == null:
		mState = "IDLE"
		#set eyes modulate back to normal
		cEyes.modulate = Color(1, 1, 1, 1)
		#restart animations
		cAnimatedSprite.play("FLY")
		
		
		#cEyes.play("EYES")
		match mLife:
			3:
				cEyes.play("EYESORANGE")
			2:
				cEyes.play("EYESRED")
			1:
				cEyes.play("EYESPURPLE")
		
		
		
		
		#stop the shader effet that make the player's sprite whiter
		cAnimatedSprite.material.set_shader_param("whiten", false)
		#stop the ghost timer in order to stop making ghost instances pop out
		cGhostTimer.stop()
		cDashTimer.stop()
		return
	
	if cDashTimer.is_stopped() && cWaitTimer.is_stopped() && mBulletToShoot == -1:
		#first phase
		mBulletToShoot = 0
		#stop the animations
		cAnimatedSprite.stop()
		cEyes.stop()
		#set the first frame
		cAnimatedSprite.frame = 0
		cEyes.frame = 0
		#stop moving
		mCurrentSpeed = 0
		#wait a little to dash
		cWaitTimer.start(0.25)
	
	#if the dash's timer is not running and in second phase and not waiting -> begin to dash
	if cDashTimer.is_stopped() && cWaitTimer.is_stopped() && mBulletToShoot == 0:
		#instance the first ghost effect
		var l_ghost_effect = mGhosteffect.instance()
		#it take the fly's first frame, rotation angle, global position
		mDashFrame = cAnimatedSprite.frames.get_frame("FLY", 0)
		l_ghost_effect.texture = mDashFrame
		l_ghost_effect.rotation = self.rotation
		l_ghost_effect.global_position = self.global_position
		#add it as a child of the fly's parent scene
		get_parent().add_child(l_ghost_effect)
		
		#set the sprite a litlle whiter with the shader
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


#######################
## INSTANCE A BULLET ##
#######################
func InstanceABullet(Position : Vector2, Direction : Vector2, Speed : int) -> void:
	if mLife >0:
		#instance a bullet and set a direction
		var l_bullet = mBullet.instance()
		l_bullet.global_position = Position
		l_bullet.mDirection = Direction
		l_bullet.mSpeed = Speed
		#add bullet as a child of the scene
		get_parent().add_child(l_bullet)


######################
## WAIT TIMER'S END ##
######################
func _on_WaitTimer_timeout() -> void:
	match mState:
		"CHASE":
			#stop the timer
			cWaitTimer.stop()
			
			if mTarget != null:
				#if close enough to attack
				if global_position.distance_to(mTarget.global_position) <= (mAwakeDistance+50):
					#if the eyes modulate is normal, light the eyes for 0.25s to announce the incoming attack
					#else attack (keeping eyes enlighten)
					if cEyes.modulate == Color(1, 1, 1, 1):
						cEyes.modulate = Color(1.7, 1.7, 1.7, 1)
						cWaitTimer.start(0.25)
					else:
						#randomize and choose and attack state
						randomize()
						
						var l_next_attack_state = mAttackList[randi() % 10 +1]
						
						#is there an amount of bullet to shoot?
						match l_next_attack_state:
							"TRISHOT":
								mBulletToShoot = 3
							"UZI":
								mBulletToShoot = 8
							"NOVA", "FASTNOVA":
								mBulletToShoot = 1
							"ROTATORRIGHT", "ROTATORLEFT":
								#-2 to handle the 0.1s tween on Update angle function and initialize the rotation at -1 next
								#the real bullet quantity will be set in the state
								mBulletToShoot = -2
							"DASHINGATTACK":
								mBulletToShoot = -1
							_:
								mBulletToShoot = 0
						
						#go into the specific attack state
						mState = l_next_attack_state
				else:
					cWaitTimer.start(0.01)
			
		"NOVA", "FASTNOVA":
			#stop the timer
			cWaitTimer.stop()
			
			#end of the little wait after the nova shot
			if mLife > 0:
				#back to the chase state and set eyes modulate to normal (if still alive)
				cEyes.modulate = Color(1, 1, 1, 1)
				mState = "CHASE"
				#start the timer for the next attack
				cWaitTimer.start(rand_range(2.0, 3.0))
			
		_:
			#stop the timer
			cWaitTimer.stop()


##############################
## HANDLE THE HURTBOX CASES ##
##############################
func _on_Hurtbox_area_entered(area) -> void:
	if area.collision_layer == 16:
		#from player
		if area.get_parent() == mTarget:
			#player's tongue
			#execute the got hit function if not in dashingattack state
			if mState!= "DASHINGATTACK":
				GotHit((self.get_position() - area.get_parent().get_position()).normalized())
				#play the hit sound
				if cHitSound.playing == false:
					cHitSound.play()
			
		else:
			#player's bullet
			#execute the got hit function if not in dashingattack state
			if mState!= "DASHINGATTACK":
				GotHit(area.get_parent().mDirection)
			#destroy the bullet
			area.get_parent().DestroyTheBullet()


#######################
## BLINK TIMER'S END ##
#######################
func _on_BlinkTimer_timeout() -> void:
	#stop the timer and the whiten shader of the sprite
	if cAnimatedSprite.material.get_shader_param("whiten") == true:
		cAnimatedSprite.material.set_shader_param("whiten", false)
	cBlinkTimer.stop()


#######################
## ANIMATION'S END ##
#######################
func _on_AnimatedSprite_animation_finished() -> void:
	#if it's the spawning animation witch is ending
	if cAnimatedSprite.animation == "SPAWNING":
		#play the FLY animation, set the normal speed, get a player (state)
		cEyes.visible = true
		
		
		#cEyes.play("EYES")
		match mLife:
			3:
				cEyes.play("EYESORANGE")
			2:
				cEyes.play("EYESRED")
			1:
				cEyes.play("EYESPURPLE")
		
		
		
		cAnimatedSprite.play("FLY")
		mCurrentSpeed = mNormalSpeed
		mState = "GETPLAYER"
		#enable the collision and the hurtbox
		cHurtBoxCollisionShape.set_deferred("disabled", false)
		cCollision.set_deferred("disabled", false)


#######################
## GHOST TIMER'S END ##
#######################
func _on_GhostTimer_timeout():
	#each time this timer is out, the fly is still dashing, instance a ghost effect
	var l_ghost_effect = mGhosteffect.instance()
	#it take the saved frame, rotation angle, global position
	l_ghost_effect.texture = mDashFrame
	l_ghost_effect.rotation = self.rotation
	l_ghost_effect.global_position = self.global_position
	#add it as a child of the fly's parent scene
	get_parent().add_child(l_ghost_effect)


######################
## DASH TIMER'S END ##
######################
func _on_DashTimer_timeout():
	#check the fly's state at the end of the dash timer
	match mState:
		"DASHINGATTACK":
			#if in DASH state, the dash duration is ending
			#set back to the normal speed
			mCurrentSpeed = mNormalSpeed
			
			#back to the chase state and set eyes modulate to normal
			cEyes.modulate = Color(1, 1, 1, 1)
			cAnimatedSprite.play("FLY")
			
			
			
			#cEyes.play("EYES")
			match mLife:
				3:
					cEyes.play("EYESORANGE")
				2:
					cEyes.play("EYESRED")
				1:
					cEyes.play("EYESPURPLE")
			
			
			
			
			mState = "CHASE"
			#start the timer for the next attack
			cWaitTimer.start(rand_range(2.0, 3.0))
			
			#stop the shader effet that make the fly's sprite whiter
			cAnimatedSprite.material.set_shader_param("whiten", false)
			#stop the ghost timer in order to stop making ghost instances pop out
			cGhostTimer.stop()
			cDashTimer.stop()

