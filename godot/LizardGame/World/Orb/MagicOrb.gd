extends Area2D

onready var cPickupSound := $PickupSound
onready var cSprite := $Sprite
onready var cShadow := $Shadow
onready var cCollisionShape := $CollisionShape2D

var mCollectable : bool = true

func _ready():
	$AnimationPlayer.play("RESET")
	$AnimationPlayer.play("Bounce")
	#pass


func _on_MagicOrb_body_entered(body):
	if body.collision_layer == 2 && LzEngine.gOrb == false && mCollectable == true:
		mCollectable = false
		
		LzEngine.gOrb = true
		
		cSprite.visible = false
		cShadow.visible = false
		#cCollisionShape.disabled = true
		cCollisionShape.set_deferred("disabled", true)
		
		cPickupSound.play()
		yield(cPickupSound, "finished")
		queue_free()
