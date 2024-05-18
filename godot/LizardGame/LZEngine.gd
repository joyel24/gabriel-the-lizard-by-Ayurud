extends Node

#Lizard Variables
var gPlayer : KinematicBody2D = null
#life
var gLife : int = 3 setget LifeSetter#BONUS HERE
#dash
var gMaxDash : int = 1#BONUS HERE
var gDashAmount : int = gMaxDash setget DashAmountSetter
const gDashReducerAmount : float = 0.2
var gDashReducerQuantity : int = 0#BONUS HERE
#apple
var gMaxApple : int = 3#BONUS HERE
var gAppleAmount : int = 0 setget AppleAmountSetter
#orb
var gOrb : bool = false setget OrbPickedUp

#Signals
signal gLifeChanged
signal gDashAmountChanged
# warning-ignore:unused_signal
signal gDashReload
signal gAppleAmountChanged
# warning-ignore:unused_signal
signal gPlayerDeath
var gdeath : bool = false
# warning-ignore:unused_signal
signal gPlayerWin
var gwin : bool = false
# warning-ignore:unused_signal
signal gAreaActivated
signal gAreaFreed
signal gGotTheOrb

#variables to memorise the active area and enemy count
var gActiveArea = null
var gEnemyCount : int = 0

#difficulty variable
var gDifficulty : int = 1

var gBonusScreen := "res://LizardGame/UI/BonusScreen/BonusScreen.tscn"
var gMainMenu := "res://LizardGame/World/Levels/Level_1.tscn"
var gMazeScene := "res://LizardGame/World/Levels/Maze.tscn"
var gScoreScreen := "res://LizardGame/UI/ScoreScreen/ScoreScreen.tscn"
var gCurrentScene

var gEnvironmentActif : bool = false
var gEnvironnment := "res://LizardGame/World/Levels/WorldEnvironment.tscn"


#gametime variables
var gGametime : float = 0.0
var gLeveltime : float = 0.0
var gFinalPartyTime : float = 0.0

#scoring variables
var gGlobalScore : int = 0
var gLevelScore : int = 0
var gMultiplier : float = 0.0

var gNames = {1: "Gabriel", 2: "Gabriel", 3: "Gabriel", 4: "Gabriel", 5: "Gabriel", 6: "Gabriel", 7: "Gabriel", 8: "Gabriel", 9: "Gabriel", 10: "Gabriel"}
var gScores = {1: 300000, 2: 256000, 3: 128000, 4: 64000, 5: 32000, 6: 16000, 7: 8000, 8: 4000, 9: 2000, 10: 1000}

var gNamesTA = {1: "Gabriel", 2: "Gabriel", 3: "Gabriel", 4: "Gabriel", 5: "Gabriel", 6: "Gabriel", 7: "Gabriel", 8: "Gabriel", 9: "Gabriel", 10: "Gabriel"}
var gScoresTA = {1: 10000.000000, 2: 11000.000000, 3: 12000.000000, 4: 13000.000000, 5: 14000.000000, 6: 15000.000000, 7: 16000.000000, 8: 17000.000000, 9: 18000.000000, 10: 19000.000000}

const TEST_PATH : String = "res://LizardSave.json"
const SAVE_PATH : String = "user://LizardSave.json"
var gFile := File.new()

var gShowLScore : bool = false
var gShowGScore : bool = false
var gShowTimer : bool = false


###########
## READY ##
###########
func _ready() -> void:
	#initialize the game LATTER : NOTHING IN READY AND INITIALIZE WHEN THE GAME IS STARTING
	GameInit()
	#LzEngine.connect("gLifeChanged", self, "_On_Life_Changed")
	# warning-ignore:return_value_discarded
	connect("gPlayerDeath", self, "_On_Player_Death")
	# warning-ignore:return_value_discarded
	connect("gPlayerWin", self, "_On_Player_Win")
	
	LoadGame()


###############
## LOAD GAME ##
###############
func LoadGame() -> void:
	if gFile.open(SAVE_PATH, File.READ) != OK :return
	var lDataString := gFile.get_as_text()
	gFile.close()
	
	var lLoadData : Dictionary = JSON.parse(lDataString).result
	
	gNames[1] = lLoadData.SCORE_PLAYERS.un
	gNames[2] = lLoadData.SCORE_PLAYERS.deux
	gNames[3] = lLoadData.SCORE_PLAYERS.trois
	gNames[4] = lLoadData.SCORE_PLAYERS.quatre
	gNames[5] = lLoadData.SCORE_PLAYERS.cinq
	gNames[6] = lLoadData.SCORE_PLAYERS.six
	gNames[7] = lLoadData.SCORE_PLAYERS.sept
	gNames[8] = lLoadData.SCORE_PLAYERS.huit
	gNames[9] = lLoadData.SCORE_PLAYERS.neuf
	gNames[10] = lLoadData.SCORE_PLAYERS.dix
	
	gScores[1] = lLoadData.SCORE_SCORES.un
	gScores[2] = lLoadData.SCORE_SCORES.deux
	gScores[3] = lLoadData.SCORE_SCORES.trois
	gScores[4] = lLoadData.SCORE_SCORES.quatre
	gScores[5] = lLoadData.SCORE_SCORES.cinq
	gScores[6] = lLoadData.SCORE_SCORES.six
	gScores[7] = lLoadData.SCORE_SCORES.sept
	gScores[8] = lLoadData.SCORE_SCORES.huit
	gScores[9] = lLoadData.SCORE_SCORES.neuf
	gScores[10] = lLoadData.SCORE_SCORES.dix
	
	gNamesTA[1] = lLoadData.TIME_PLAYERS.un
	gNamesTA[2] = lLoadData.TIME_PLAYERS.deux
	gNamesTA[3] = lLoadData.TIME_PLAYERS.trois
	gNamesTA[4] = lLoadData.TIME_PLAYERS.quatre
	gNamesTA[5] = lLoadData.TIME_PLAYERS.cinq
	gNamesTA[6] = lLoadData.TIME_PLAYERS.six
	gNamesTA[7] = lLoadData.TIME_PLAYERS.sept
	gNamesTA[8] = lLoadData.TIME_PLAYERS.huit
	gNamesTA[9] = lLoadData.TIME_PLAYERS.neuf
	gNamesTA[10] = lLoadData.TIME_PLAYERS.dix
	
	gScoresTA[1] = lLoadData.TIME_TIMES.un
	gScoresTA[2] = lLoadData.TIME_TIMES.deux
	gScoresTA[3] = lLoadData.TIME_TIMES.trois
	gScoresTA[4] = lLoadData.TIME_TIMES.quatre
	gScoresTA[5] = lLoadData.TIME_TIMES.cinq
	gScoresTA[6] = lLoadData.TIME_TIMES.six
	gScoresTA[7] = lLoadData.TIME_TIMES.sept
	gScoresTA[8] = lLoadData.TIME_TIMES.huit
	gScoresTA[9] = lLoadData.TIME_TIMES.neuf
	gScoresTA[10] = lLoadData.TIME_TIMES.dix
	
	if lLoadData.has("SHOWLSCORE"):
		gShowLScore = lLoadData.SHOWLSCORE
		gShowGScore = lLoadData.SHOWGSCORE
		gShowTimer = lLoadData.SHOWTIMER


###############
## SAVE GAME ##
###############
func SaveGame() -> void:
	if gFile.open(SAVE_PATH, File.WRITE) != OK :return
	var lSaveData : Dictionary = {
		"SCORE_PLAYERS" : {
			"un": gNames[1],
			"deux": gNames[2],
			"trois": gNames[3],
			"quatre": gNames[4],
			"cinq": gNames[5],
			"six": gNames[6],
			"sept": gNames[7],
			"huit": gNames[8],
			"neuf": gNames[9],
			"dix": gNames[10]
		},
		"SCORE_SCORES" : {
			"un": gScores[1],
			"deux": gScores[2],
			"trois": gScores[3],
			"quatre": gScores[4],
			"cinq": gScores[5],
			"six": gScores[6],
			"sept": gScores[7],
			"huit": gScores[8],
			"neuf": gScores[9],
			"dix": gScores[10]
		},
		"TIME_PLAYERS" : {
			"un": gNamesTA[1],
			"deux": gNamesTA[2],
			"trois": gNamesTA[3],
			"quatre": gNamesTA[4],
			"cinq": gNamesTA[5],
			"six": gNamesTA[6],
			"sept": gNamesTA[7],
			"huit": gNamesTA[8],
			"neuf": gNamesTA[9],
			"dix": gNamesTA[10]
		},
		"TIME_TIMES" : {
			"un": gScoresTA[1],
			"deux": gScoresTA[2],
			"trois": gScoresTA[3],
			"quatre": gScoresTA[4],
			"cinq": gScoresTA[5],
			"six": gScoresTA[6],
			"sept": gScoresTA[7],
			"huit": gScoresTA[8],
			"neuf": gScoresTA[9],
			"dix": gScoresTA[10]
		},
		"SHOWLSCORE" : gShowLScore,
		"SHOWGSCORE" : gShowGScore,
		"SHOWTIMER" : gShowTimer
	}
	
	var lDataString := JSON.print(lSaveData)
	gFile.store_string(lDataString)
	gFile.close()


###################
## SCORE RANKING ##
###################
func ScoreRanking(pName : String, pScore : int) -> void:
	
	var lPlayerName : String = pName
	var lPlayerScore : int = pScore
	
	var lTempName : String = ""
	var lTempScore : int = 0
	
	var i : int = 10
	var lRankingPosition : int = 0
	
	while i != 0:
		if lPlayerScore > gScores[i]:
			lRankingPosition = i
		
		i = i-1
	
	if lRankingPosition > 0:
		#there is a ranking
		i = lRankingPosition
		while i != 10:
			lTempName = gNames[i]
			lTempScore = gScores[i]
			
			gNames[i] = lPlayerName
			gScores[i] = lPlayerScore
			
			lPlayerName = lTempName
			lPlayerScore = lTempScore
			
			i = i+1
		
		#THE LAST 10TH
		gNames[i] = lPlayerName
		gScores[i] = lPlayerScore


###################
## TIME RANKING ##
###################
func TimeRanking(pName : String, pTime : float) -> void:
	
	var lPlayerName : String = pName
	var lPlayerTime : float = pTime
	
	var lTempName : String = ""
	var lTempTime : float = 0.0
	
	var i : int = 10
	var lRankingPosition : int = 0
	
	while i != 0:
		if lPlayerTime < gScoresTA[i]:
			lRankingPosition = i
		
		i = i-1
	
	if lRankingPosition > 0:
		#there is a ranking
		i = lRankingPosition
		while i != 10:
			lTempName = gNamesTA[i]
			lTempTime = gScoresTA[i]
			
			gNamesTA[i] = lPlayerName
			gScoresTA[i] = lPlayerTime
			
			lPlayerName = lTempName
			lPlayerTime = lTempTime
			
			i = i+1
		
		#THE LAST 10TH
		gNamesTA[i] = lPlayerName
		gScoresTA[i] = lPlayerTime


####################
## PLAYER'S DEATH ##
####################
func _On_Player_Death() -> void:
	if gdeath == false:
		gdeath = true
		Lzui.cGameOver.add_color_override("font_color", Color(1,0,0))
		Lzui.cGameOver.text = "GAME OVER"
		Lzui.cGameOver.rect_position.x = 180
		Lzui.cAnimationP.play("FadeIn")
	else:
		gdeath = false
		gCurrentScene.queue_free()
		
		Lzui.levelup() # add ok ?
		
		#scorebefore dying
		gGlobalScore = gGlobalScore + gLevelScore
		#LzEngine.gFinalPartyTime = LzEngine.gGametime
		
		var l_root := get_tree().root
		var l_score : Node = load(gScoreScreen).instance()
		gCurrentScene = l_score
		l_root.add_child(l_score)
		#var l_root := get_tree().root
		#var l_menu : Node = load(gMainMenu).instance()
		#gCurrentScene = l_menu
		#l_root.add_child(l_menu)


func gotomenu() -> void:
	#CameraShake.SetNull()
	var l_root := get_tree().root
	var l_menu : Node = load(gMainMenu).instance()
	gCurrentScene = l_menu
	l_root.add_child(l_menu)
	#GameInit()


##################
## PLAYER'S WIN ##
##################
func _On_Player_Win() -> void:
	if gwin == false:
		gwin =  true
		Lzui.cGameOver.add_color_override("font_color", Color(1,1,1))
		Lzui.cGameOver.text = "Level " + str(gDifficulty) + " Complete"
		Lzui.cGameOver.rect_position.x = 180
		Lzui.cAnimationP.play("FadeIn")
	else:
		gwin = false
		gCurrentScene.queue_free()
		
		Lzui.levelup()
		
		if gDifficulty <= 9:
			var l_root := get_tree().root
			var l_bonus : Node = load(gBonusScreen).instance()
			gCurrentScene = l_bonus
			l_root.add_child(l_bonus)
		else:
			var l_root := get_tree().root
			var l_score : Node = load(gScoreScreen).instance()
			gCurrentScene = l_score
			l_root.add_child(l_score)


#####################
## ADD ENVIRONMENT ##
#####################
func AddEnvironment()-> void:
	var l_root := get_tree().root
	var l_environment : Node = load(gEnvironnment).instance()
	l_root.add_child(l_environment)


######################
## START A NEW GAME ##
######################
func Startagame(Level1) -> void:
	Level1.queue_free()
	
	if gEnvironmentActif == false:
		gEnvironmentActif = true
		AddEnvironment()
	
	#var l_tree := get_tree()
	#ar l_root := l_tree.root
	var l_root := get_tree().root
	var l_newmaze : Node = load(gMazeScene).instance()
	gCurrentScene = l_newmaze
	l_root.add_child(l_newmaze)
	#GameInit()


#########################
## INITIALIZE THE GAME ##
#########################
func GameInit() -> void:
	#Init the lizard's stats, starting with life
	gLife = 3
	#dash
	gMaxDash = 1
	gDashAmount = gMaxDash
	gDashReducerQuantity = 0
	#apple
	gMaxApple = 3
	gAppleAmount = 0

func DataPrint() -> void:
	print("Difficulty : " + str(gDifficulty))
	print("Life : " + str(gLife))
	#dash
	print("max dash : " + str(gMaxDash))
	print("dash amount : " + str(gDashAmount))
	print("dash reducer nb : " + str(gDashReducerQuantity))
	#apple
	print("max apple : " + str(gMaxApple))
	print("apple amount : " + str(gAppleAmount))



################
## GET PLAYER ##
################
func GetPlayer() -> KinematicBody2D:
	#return the player
	return gPlayer


######################
## LIFE STAT SETTER ##
######################
func LifeSetter(NewValue) -> void:
	#update the stat
	gLife = NewValue
	#emit the signal
	emit_signal("gLifeChanged")


##########################
## ORB PICKED UP SETTER ##
##########################
func OrbPickedUp(NewValue) -> void:
	#update the stat
	gOrb = NewValue
	#emit the signal
	#if gOrb == true:
	emit_signal("gGotTheOrb")


########################
## DASH AMOUNT SETTER ##
########################
func DashAmountSetter(NewValue) -> void:
	#update the stat
	gDashAmount = NewValue
	#emit the signal
	emit_signal("gDashAmountChanged")


#########################
## APPLE AMOUNT SETTER ##
#########################
func AppleAmountSetter(NewValue) -> void:
	#update the stat
	gAppleAmount = NewValue
	#emit the signal
	emit_signal("gAppleAmountChanged")


##################
## ENEMY KILLED ##
##################
func EnemyKilled() -> void:
	#update the count
	gEnemyCount -= 1
	#print(gEnemyCount)
	
	if gEnemyCount <= 0:
		#the the EnemyCount reach 0, free the area by emitting the signal
		gEnemyCount = 0
		emit_signal("gAreaFreed")
