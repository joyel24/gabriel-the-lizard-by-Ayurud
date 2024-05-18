extends Control

var mTimeToGo : bool = true

onready var cLabelDuHaut := $MarginContainer/VBoxContainer/LabelDuHaut
onready var cPlayerName := $MarginContainer/VBoxContainer/HBoxContainer/PlayerName
onready var cLabelDuBas := $MarginContainer/VBoxContainer/LabelDuBas


func _ready():
	Lzui.visible = false
	cLabelDuHaut.text = "Game is over, Thank you for playing ! " + "\n\n\n\n"
	cLabelDuHaut.text = cLabelDuHaut.text + "Score : " + str(LzEngine.gGlobalScore) + "\n\n"
	cLabelDuHaut.text = cLabelDuHaut.text + "Time score (if level 10 is complete) : " + str(LzEngine.gFinalPartyTime) + "\n\n"
	
	
	cLabelDuBas.text = "(press Enter to validate and return to the main menu)"
	
	cPlayerName.grab_focus()


############################
## HANDLE GAMEPLAY INPUTS ##
############################
func _unhandled_input(event : InputEvent) -> void:
	
	if event.is_action_pressed("ui_validate"):
		pass
	#	self.queue_free()
	#	LzEngine.gotomenu()


#######################################################
## ENTER IS PRESSED AFTER TEXT INPUT FOR PLAYER NAME ##
#######################################################
func _on_PlayerName_text_entered(new_text):
	if mTimeToGo == true:
		mTimeToGo = false
		#LzEngine.gGlobalScore = 10000
		#LzEngine.gFinalPartyTime = 12456.123456
		LzEngine.ScoreRanking(new_text, LzEngine.gGlobalScore)
		if LzEngine.gFinalPartyTime > 0.0:
			LzEngine.TimeRanking(new_text, LzEngine.gFinalPartyTime)
		LzEngine.SaveGame()
		
		self.queue_free()
		LzEngine.gotomenu()

