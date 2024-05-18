extends StaticBody2D

onready var cOrb := $Orb
onready var cPickupSound := $PickupSound

var mOrbSocketed : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Orbdetection_body_entered(body):
	if body.collision_layer == 2 && mOrbSocketed == false && LzEngine.gOrb == true:
		body.mPlayerState = "WAIT"
		
		#stop scoring level
		LzEngine.gGlobalScore = LzEngine.gGlobalScore + LzEngine.gLevelScore + int(float(LzEngine.gLevelScore)*LzEngine.gMultiplier/100.0)
		LzEngine.gLevelScore = 0
		Lzui.cGlobalScore.text = str(LzEngine.gGlobalScore)
		Lzui.cLevelScore.text = str(LzEngine.gLevelScore) 
		#for time attack if level 10 is complete
		if LzEngine.gDifficulty == 10:
			LzEngine.gFinalPartyTime = LzEngine.gGametime
		
		
		LzEngine.gOrb = false
		mOrbSocketed = true
		cOrb.visible = true
		cPickupSound.play()
		yield(cPickupSound, "finished")
		
		LzEngine.gPlayer = null
		CameraShake.SetNull()
		LzEngine.emit_signal("gPlayerWin")
