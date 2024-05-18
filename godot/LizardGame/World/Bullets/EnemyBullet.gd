extends KinematicBody2D

#childs
onready var cSprite := $Sprite
onready var cExplosionAnimation := $Explosion
onready var cHitBoxCollisionShape := $HitBox/CollisionShape2D
onready var cExplosionSound := $ExplosionSound

#variables
var mSpeed : int = 100
var mDirection := Vector2(0, 0)


##########################
## PHYSIC PROCESS       ##
##########################
# warning-ignore:unused_argument
func _physics_process(delta) -> void:
	#movement execution with sliding option on colisions
	#if the direction vector is null, there is no movement
	var l_movement = mSpeed * mDirection
	# warning-ignore:return_value_discarded
	move_and_slide(l_movement)


###############################
## EXPLOSION ANIMATION'S END ##
###############################
func _on_Explosion_animation_finished() -> void:
	queue_free()


########################
## DESTROY THE BULLET ##
########################
func DestroyTheBullet() -> void:
	#disable the HitBox, set the speed to 0 and hide the bullet sprite
	set_deferred("cHitBoxCollisionShape.disabled", true)
	mSpeed = 0
	cSprite.visible = false
	#show the explosion animation, play it and the sound too
	cExplosionAnimation.visible = true
	cExplosionAnimation.play("EXPLOSION")
	#too much destroying bullet sounds = too noisy ?
	#cExplosionSound.play()



##################################
## HANDLE THE HITBOX COLLISIONS ##
##################################
func _on_HitBox_body_entered(body) -> void:
	#world collision
	if body.collision_layer == 1:
		DestroyTheBullet()
