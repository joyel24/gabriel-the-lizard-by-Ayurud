extends CanvasLayer

#childs
onready var oAnimPlayer := $AnimationPlayer							#get_node("AnimationPlayer")
onready var oLogo := $AyuLogoBeta
onready var oHow := $HowToPlay
onready var oMenu := $MenuContainer
onready var oTitle := $MenuContainer/Title
onready var cScoreNames := $MenuContainer/MenuHighScore/HBoxContainer/Names
onready var cScoreScores := $MenuContainer/MenuHighScore/HBoxContainer/Scores
onready var cTimeNames := $MenuContainer/MenuTimeScore/HBoxContainer/Names
onready var cTimeScores := $MenuContainer/MenuTimeScore/HBoxContainer/Scores
onready var cShowLScore := $MenuContainer/MenuOptions/ShowLScore
onready var cShowGScore := $MenuContainer/MenuOptions/ShowGScore
onready var cShowTimer := $MenuContainer/MenuOptions/ShowTimer


#variables ; Is the menu active for pressing butyons?
var mActivemenu : bool = false

func _ready():
	#StageCurtain fade out
	oTitle.text = "GABRIEL THE LIZARD"
	oAnimPlayer.play("FadeOut")
	
	Remplissage_Scores()
	Remplissage_Temps()
	
	match LzEngine.gShowLScore:
		false:
			cShowLScore.text = "Show Local Score : OFF"
			Lzui.cLevelScore.visible = false
		true:
			cShowLScore.text = "Show Local Score : ON"
			Lzui.cLevelScore.visible = true
	
	match LzEngine.gShowGScore:
		false:
			cShowGScore.text = "Show Global Score : OFF"
			Lzui.cGlobalScore.visible = false
		true:
			cShowGScore.text = "Show Global Score : ON"
			Lzui.cGlobalScore.visible = true
	
	match LzEngine.gShowTimer:
		false:
			cShowTimer.text = "Show game timer : OFF"
			Lzui.cGameTime.visible = false
		true:
			cShowTimer.text = "Show game timer : ON"
			Lzui.cGameTime.visible = true


func Remplissage_Scores() ->void :
	cScoreNames.text = ""
	cScoreScores.text = ""
	
	for i in 10:
		cScoreScores.text = cScoreScores.text + str(LzEngine.gScores[i+1])
		cScoreNames.text = cScoreNames.text + LzEngine.gNames[i+1]
		
		if i < 9:
			cScoreScores.text = cScoreScores.text + "\n"
			cScoreNames.text = cScoreNames.text + "\n"

func Remplissage_Temps() ->void :
	cTimeNames.text = ""
	cTimeScores.text = ""
	
	for i in 10:
		cTimeScores.text = cTimeScores.text + str(LzEngine.gScoresTA[i+1])
		cTimeNames.text = cTimeNames.text + LzEngine.gNamesTA[i+1]
		
		if i < 9:
			cTimeScores.text = cTimeScores.text + "\n"
			cTimeNames.text = cTimeNames.text + "\n"

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"FadeOut":
			#if the logo is there => fade in
			if oLogo.visible == true :
				oAnimPlayer.play("FadeIn")
		"FadeIn":
			#when the screen is black, if the logo is there, make it invisible, show the first menu and make it active => fadeout
			if oLogo.visible == true :
				oLogo.visible = false
				oMenu.visible=true
				oAnimPlayer.play("FadeOut")
				if mActivemenu == false:
					$MenuContainer/Menu1/Start.grab_focus()
					mActivemenu = true
		_:
			return


func _on_Quit_pressed():
	if mActivemenu == true:
		#menu inactive
		mActivemenu = false
		#set the camera to null and quit the game
		CameraShake.SetNull()
		get_tree().quit()


func _on_HighScore_pressed():
	if mActivemenu == true:
		#menu inactive
		mActivemenu = false
		#change the title
		oTitle.text = "HighScore"
		#Turn Menu1 invisible ; MenuHighscore visible
		$MenuContainer/Menu1.visible = false
		$MenuContainer/MenuHighScore.visible = true
		#grab focus on button and reactivate
		$MenuContainer/MenuHighScore/BackHighscore.grab_focus()
		mActivemenu = true


func _on_BackHighscore_pressed():
	if mActivemenu == true:
		#menu inactive
		mActivemenu = false
		#change the title
		oTitle.text = "GABRIEL THE LIZARD"
		$MenuContainer/MenuHighScore.visible = false
		$MenuContainer/Menu1.visible = true
		$MenuContainer/Menu1/HighScore.grab_focus()
		mActivemenu = true


func _on_How_pressed():
	if mActivemenu == true:
		#menu inactive
		mActivemenu = false
		oTitle.text = " "
		$MenuContainer/Menu1.visible = false
		oHow.visible=true
		$MenuContainer/MenuHowToPlay.visible = true
		$MenuContainer/MenuHowToPlay/BackHowToPlay.grab_focus()
		mActivemenu = true


func _on_BackHowToPlay_pressed():
	if mActivemenu == true:
		#menu inactive
		mActivemenu = false
		oHow.visible=false
		#change the title
		oTitle.text = "GABRIEL THE LIZARD"
		$MenuContainer/MenuHowToPlay.visible = false
		$MenuContainer/Menu1.visible = true
		$MenuContainer/Menu1/How.grab_focus()
		mActivemenu = true


func _on_Options_pressed():
	if mActivemenu == true:
		#menu inactive
		mActivemenu = false
		#change the title
		oTitle.text = "Options"
		#Turn Menu1 invisible ; MenuOptions visible
		$MenuContainer/Menu1.visible = false
		$MenuContainer/MenuOptions.visible = true
		#grab focus on button and reactivate
		$MenuContainer/MenuOptions/BackOptions.grab_focus()
		mActivemenu = true


func _on_BackOptions_pressed():
	if mActivemenu == true:
		#menu inactive
		mActivemenu = false
		#change the title
		oTitle.text = "GABRIEL THE LIZARD"
		$MenuContainer/MenuOptions.visible = false
		$MenuContainer/Menu1.visible = true
		$MenuContainer/Menu1/Options.grab_focus()
		mActivemenu = true


func _on_Start_pressed():
	#ask the engine to start a game
	Lzui.visible = true
	
	LzEngine.gLife = 3
	#dash
	LzEngine.gMaxDash = 1
	LzEngine.gDashAmount = LzEngine.gMaxDash
	LzEngine.gDashReducerQuantity = 0
	#apple
	LzEngine.gMaxApple = 3
	LzEngine.gAppleAmount = 0
	#difficulty
	LzEngine.gDifficulty = 1
	#freezone & ennemy numbers
	LzEngine.gActiveArea = null
	LzEngine.gEnemyCount = 0
	#no orb
	LzEngine.gOrb = false
	
	Lzui.cGameOver.modulate = 0
	Lzui.cOrbIcon.visible = false
	Lzui.cOrbLabel.visible = false
	
	#LzEngine.DataPrint()
	CameraShake.SetNull()
	LzEngine.Startagame(get_parent())
	
	Lzui.cGameTime.text = str(0.0)
	Lzui.cLevelTime.text = str(0.0)
	Lzui.cGlobalScore.text = str(0)
	Lzui.cLevelScore.text = str(0)
	LzEngine.gGametime = 0.0
	LzEngine.gFinalPartyTime = 0.0
	LzEngine.gLeveltime = 0.0
	LzEngine.gGlobalScore = 0
	LzEngine.gLevelScore = 0
	LzEngine.gMultiplier = 100.0



func _on_TimeScore_pressed():
	if mActivemenu == true:
		#menu inactive
		mActivemenu = false
		#change the title
		oTitle.text = "TimeScore"
		#Turn Menu1 invisible ; MenuHighscore visible
		$MenuContainer/Menu1.visible = false
		$MenuContainer/MenuTimeScore.visible = true
		#grab focus on button and reactivate
		$MenuContainer/MenuTimeScore/BackTimeScore.grab_focus()
		mActivemenu = true


func _on_BackTimeScore_pressed():
	if mActivemenu == true:
		#menu inactive
		mActivemenu = false
		#change the title
		oTitle.text = "GABRIEL THE LIZARD"
		$MenuContainer/MenuTimeScore.visible = false
		$MenuContainer/Menu1.visible = true
		$MenuContainer/Menu1/TimeScore.grab_focus()
		mActivemenu = true


func _on_ShowLScore_pressed():
	match LzEngine.gShowLScore:
		false:
			cShowLScore.text = "Show Local Score : ON"
			LzEngine.gShowLScore = true
			Lzui.cLevelScore.visible = true
			LzEngine.SaveGame()
		true:
			cShowLScore.text = "Show Local Score : OFF"
			LzEngine.gShowLScore = false
			Lzui.cLevelScore.visible = false
			LzEngine.SaveGame()


func _on_ShowGScore_pressed():
	match LzEngine.gShowGScore:
		false:
			cShowGScore.text = "Show Global Score : ON"
			LzEngine.gShowGScore = true
			Lzui.cGlobalScore.visible = true
			LzEngine.SaveGame()
		true:
			cShowGScore.text = "Show Global Score : OFF"
			LzEngine.gShowGScore = false
			Lzui.cGlobalScore.visible = false
			LzEngine.SaveGame()


func _on_ShowTimer_pressed():
	match LzEngine.gShowTimer:
		false:
			cShowTimer.text = "Show game timer : ON"
			LzEngine.gShowTimer = true
			Lzui.cGameTime.visible = true
			LzEngine.SaveGame()
		true:
			cShowTimer.text = "Show game timer : OFF"
			LzEngine.gShowTimer = false
			Lzui.cGameTime.visible = false
			LzEngine.SaveGame()
