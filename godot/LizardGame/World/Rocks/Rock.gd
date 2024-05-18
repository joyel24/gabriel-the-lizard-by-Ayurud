extends KinematicBody2D

#Variables
var mCanBeHit : bool = false

#Child's variables
onready var cSprite := $Sprite
onready var cCollisionShape := $CollisionShape2D


###########
## READY ##
###########
func _ready():
	if cSprite.texture.get_size().x < 16:
		self.z_index = -10
		cCollisionShape.disabled = true
		mCanBeHit = false
		
	else:
		mCanBeHit = true



