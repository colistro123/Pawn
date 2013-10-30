/*
	Purpose: Basketball module
	
	Module Documentation
	PVars used by this module:
	WasToySlotUsed (int) - Can be used to determine if the toy slot was used and then toggle the toy again
	BasketBallArea (int) - The basket ball area the player is playing at
	LastBallID(int) - The Last Ball ID
*/
#define SDK_BASKETBALL_MDL 2114 //BasketBall Ball
#define SDK_BASKET_MDL 2114 //Basket ID goes here (unused and MDL is wrong)
#define SDK_BASKETBALL_SLOT 9 //Basketball slot
#define SDK_TACKLE_COOLDOWN 2 //Basketball cooldown

enum { //anims
	BASKETBALL_WALK, //0
	BASKETBALL_RUN, //1
	BASKETBALL_DUNK, //2
	BASKETBALL_DEFENSE, //3
}
enum {
	ISNOT_DYNAMIC_OBJECT,
	IS_DYNAMIC_OBJECT,
}
enum {
	SDK_TEAM_1,
	SDK_TEAM_2,
}
enum {
	AREA_EASTLS,
	AREA_UNITY,
	AREA_P_SEVILLE,
}
enum EBallInfo {
	EBallModelID,
	EBallType,
	Float:EBallX,
	Float:EBallY,
	Float:EBallZ,
	Float:EBallRotX,
	Float:EBallRotY,
	Float:EBallRotZ,
	EBallVW,
	EBallInt,
	EBallObjectID,
	EBBallArea,
	EBBallOwner, //Last user that had the ball
};
enum EBallBasketInfo {
	EBasketModelID,
	EBasketType,
	Float:EBasketX,
	Float:EBasketY,
	Float:EBasketZ,
	Float:EBasketRotX,
	Float:EBasketRotY,
	Float:EBasketRotZ,
	EBasketVW,
	EBasketInt,
	EBasketObjectID,
	EBasketTeam,
	EBasketArea,
	EBasketScore,
	Text3D:EBasketText,
};
new BBallsInfo[][EBallInfo] = {
	{SDK_BASKETBALL_MDL, IS_DYNAMIC_OBJECT, 2316.94,-1527.65,24.45, 0.0, 0.0, 0.0, 0, 0, 0, AREA_EASTLS, -1},
	{SDK_BASKETBALL_MDL, IS_DYNAMIC_OBJECT, 1790.64, -1792.96, 12.73, 0.00, 0.00, 0.00, 0, 0, 0, AREA_UNITY, -1},
	{SDK_BASKETBALL_MDL, IS_DYNAMIC_OBJECT, 2782.40, -2019.52, 12.73, 0.00, 0.00, 0.00, 0, 0, 0, AREA_P_SEVILLE, -1}
};
new BallBasketInfo[][EBallBasketInfo] = {
	{SDK_BASKET_MDL, ISNOT_DYNAMIC_OBJECT, 2316.83, -1514.80, 28.14, 0.0, 0.0, 90.0, 0, 0, 0, SDK_TEAM_1, AREA_EASTLS, 0},
	{SDK_BASKET_MDL, ISNOT_DYNAMIC_OBJECT, 2317.03, -1541.13, 28.14, 0.0, 0.0, 90.0, 0, 0, 0, SDK_TEAM_2, AREA_EASTLS, 0},
	{SDK_BASKET_MDL, ISNOT_DYNAMIC_OBJECT, 1790.94, -1806.54, 16.65, 0.0, 0.0, 90.0, 0, 0, 0, SDK_TEAM_1, AREA_UNITY, 0},
	{SDK_BASKET_MDL, ISNOT_DYNAMIC_OBJECT, 1790.41, -1780.04, 16.65, 0.0, 0.0, 90.0, 0, 0, 0, SDK_TEAM_2, AREA_UNITY, 0},
	{SDK_BASKET_MDL, ISNOT_DYNAMIC_OBJECT, 2795.08, -2019.67, 16.43, 0.0, 0.0, 90.0, 0, 0, 0, SDK_TEAM_1, AREA_P_SEVILLE, 0},
	{SDK_BASKET_MDL, ISNOT_DYNAMIC_OBJECT, 2768.64, -2019.67, 16.43, 0.0, 0.0, 90.0, 0, 0, 0, SDK_TEAM_2, AREA_P_SEVILLE, 0}
};
/* ----------------------------- Loading  ----------------------------- */
basketballOnGameModeInit() {
	loadBasketBalls();
	loadBaskets();
}
loadBasketBalls() {
	for(new i=0; i < sizeof(BBallsInfo); i++) {
		if(BBallsInfo[i][EBallType] == IS_DYNAMIC_OBJECT) {
			BBallsInfo[i][EBallObjectID] = CreateDynamicObject(BBallsInfo[i][EBallModelID],BBallsInfo[i][EBallX], BBallsInfo[i][EBallY],BBallsInfo[i][EBallZ], BBallsInfo[i][EBallRotX], BBallsInfo[i][EBallRotY], BBallsInfo[i][EBallRotZ],BBallsInfo[i][EBallVW],BBallsInfo[i][EBallInt]);
		}
	}
}
loadBaskets() {
	new bBallScoreLabel[128];
	for(new i=0; i < sizeof(BallBasketInfo); i++) {
		if(BallBasketInfo[i][EBasketType] == IS_DYNAMIC_OBJECT) {
			BallBasketInfo[i][EBasketObjectID] = CreateDynamicObject(BallBasketInfo[i][EBasketModelID],BallBasketInfo[i][EBasketX], BallBasketInfo[i][EBasketY],BallBasketInfo[i][EBasketZ], BallBasketInfo[i][EBasketRotX], BallBasketInfo[i][EBasketRotY], BallBasketInfo[i][EBasketRotZ],BallBasketInfo[i][EBasketVW],BallBasketInfo[i][EBasketInt]);
		}
		format(bBallScoreLabel, sizeof(bBallScoreLabel), "{FFFFFF}Score: %d", BallBasketInfo[i][EBasketScore]);
		BallBasketInfo[i][EBasketText] = CreateDynamic3DTextLabel(bBallScoreLabel, 0x89CEF3, BallBasketInfo[i][EBasketX], BallBasketInfo[i][EBasketY],BallBasketInfo[i][EBasketZ]+0.25, 50.0,INVALID_PLAYER_ID, INVALID_VEHICLE_ID,0,BallBasketInfo[i][EBasketVW], BallBasketInfo[i][EBasketInt]);
	}
}
/* ----------------------------- Things related with the basketball balls  ----------------------------- */
isAtBBall(playerid, Float: radi = 1.5) { //Is at a basketball ball
	for(new i=0;i<sizeof(BBallsInfo);i++) {
		if(IsPlayerInRangeOfPoint(playerid, radi, BBallsInfo[i][EBallX], BBallsInfo[i][EBallY],BBallsInfo[i][EBallZ])) {
			return 1;
		}
	}
	return 0;
}
getClosestBBall(playerid, Float: radi = 1.5) { //Gets the closest basketball ball
	for(new i=0;i<sizeof(BBallsInfo);i++) {
		if(IsPlayerInRangeOfPoint(playerid, radi, BBallsInfo[i][EBallX], BBallsInfo[i][EBallY],BBallsInfo[i][EBallZ])) {
			return i;
		}
	}
	return -1;
}
getBBallArea(ballid) {
	return BBallsInfo[ballid][EBBallArea];
}
task CheckBasketBall[1000] () {
	foreach(Player, i) {
		if(IsPlayerConnectEx(i)) {
			checkPlayingState(i);
		}
	}
}
checkPlayingState(playerid) {
	if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) {
		if(isPlayingBasketBall(playerid)) {
			if(isAtBBall(playerid, 30.0)) {
				if(hasBall(playerid)) {
					loadBBallAnims(playerid, BASKETBALL_RUN);
					playBounceSoundForPeople(playerid, 20.0);
				}
			} else {
				exitBBallGame(playerid);
			}
		}
	}
	return 1;
}
/* ----------------------------- User interaction with the ball  ----------------------------- */
joiningOrLeavingBBall(playerid) {
	if(isPlayingBasketBall(playerid) && !isAtBBall(playerid)) {
		exitBBallGame(playerid);
	} else {
		tryPickUpBall(playerid);
	}
}
exitBBallGame(playerid) {
	SendClientMessage(playerid, X11_WHITE, "[INFO]: You've left the basketball game!");
	new areaid = getAreaUserIsPlayingAt(playerid);
	destroyBBallPVars(playerid);
	tryDropBall(playerid);
	checkBBallGameState(areaid);
	unloadBBallAnims(playerid);
}
checkBBallGameState(areaid) {
	if(getAmountPlayingAtArea(areaid) < 1) {
		restartBasketScores(areaid);
	}
}
destroyBBallPVars(playerid) {
	DeletePVar(playerid, "BasketBallArea");
}
tryDropBall(playerid) {
	new ballid = getLastBallID(playerid);
	if(getBallOwner(ballid) == playerid) {
		respawnBall(ballid);
		removeBallFromPlayer(playerid);
	}
}
respawnBall(ballid) {
	BBallsInfo[ballid][EBallObjectID] = CreateDynamicObject(BBallsInfo[ballid][EBallModelID],BBallsInfo[ballid][EBallX], BBallsInfo[ballid][EBallY],BBallsInfo[ballid][EBallZ], BBallsInfo[ballid][EBallRotX], BBallsInfo[ballid][EBallRotY], BBallsInfo[ballid][EBallRotZ],BBallsInfo[ballid][EBallVW],BBallsInfo[ballid][EBallInt]);
	setBallOwner(-1, ballid); //reset the ball owner since the ball was dropped
}
removeBallFromPlayer(playerid) {
	RemovePlayerAttachedObject(playerid, SDK_BASKETBALL_SLOT);
	if(GetPVarType(playerid, "WasToySlotUsed") != PLAYER_VARTYPE_NONE) {
		if(GetPVarInt(playerid, "WasToySlotUsed") == 1) {
			toggleAccessorySlot(playerid, SDK_BASKETBALL_SLOT);
			DeletePVar(playerid, "WasToySlotUsed");
		}
	}
	return 1;
}
tryPickUpBall(playerid) {
	if(isAtBBall(playerid)) {
		new ballindex = getClosestBBall(playerid);
		if(ballIsNotBeingUsed(ballindex)) {
			DestroyDynamicObject(BBallsInfo[ballindex][EBallObjectID]);
			pickupBBall(playerid, ballindex);
		} else {
			//Ball is being used, make the player join the game
			joinBBallGame(playerid, ballindex);
		}
	}
}
ballIsNotBeingUsed(ballid) {
	if(BBallsInfo[ballid][EBBallOwner] != -1) {
		return 0;
	}
	return 1;
}
pickupBBall(playerid, ballid) {
	joinBBallGame(playerid, ballid);
	attachBBallToPlayer(playerid, ballid);
	ApplyAnimation(playerid,"BSKTBALL","BBALL_pickup",4.0,0,0,0,0,0); //Pick up the ball.
}
joinBBallGame(playerid, ballindex) {
	if(!isPlayingBasketBall(playerid)) {
		SendClientMessage(playerid, X11_WHITE, "[INFO]: You've joined the basketball game!");
		ShowScriptMessage(playerid, "Controls: ~r~ SPRINT KEY: ~w~ Tackle ~n~ ~r~ JUMP KEY: ~w~ Dunk ~r~ WALK Key: ~w~ DEFEND",3000);
	}
	new areaid = getBBallArea(ballindex);
	setUserAreaIsPlayingAt(playerid, areaid);
}
setLastBallID(playerid, ballid) {
	SetPVarInt(playerid, "LastBallID", ballid);
}
getLastBallID(playerid) {
	if(GetPVarType(playerid, "LastBallID") != PLAYER_VARTYPE_NONE) {
		return GetPVarInt(playerid, "LastBallID");
	}
	return -1;
}
setUserAreaIsPlayingAt(playerid, area) {
	SetPVarInt(playerid, "BasketBallArea", area);
}
getAreaUserIsPlayingAt(playerid) {
	if(GetPVarType(playerid, "BasketBallArea") != PLAYER_VARTYPE_NONE) {
		return GetPVarInt(playerid, "BasketBallArea");
	}
	return -1;
}
getAmountPlayingAtArea(areaid) {
	new count;
	foreach(Player, i) {
		if(GetPVarType(i, "BasketBallArea") != PLAYER_VARTYPE_NONE) {
			if(GetPVarInt(i, "BasketBallArea") == areaid) {
				count++;
			}
		}
	}
	return count;
}
attachBBallToPlayer(playerid, ballid) {
	if(IsPlayerAttachedObjectSlotUsed(playerid, SDK_BASKETBALL_SLOT)) {
		toggleAccessorySlot(playerid, SDK_BASKETBALL_SLOT);
		SetPVarInt(playerid, "WasToySlotUsed", 1);
	} else {
		SetPlayerAttachedObject(playerid, SDK_BASKETBALL_SLOT, SDK_BASKETBALL_MDL, BONE_RHAND);
	}
	setBallOwner(playerid, ballid);
	loadBBallAnims(playerid);
}
getBallOwner(ballid) {
	return BBallsInfo[ballid][EBBallOwner];
}
setBallOwner(playerid, ballid) {
	setLastBallID(playerid, ballid);
	BBallsInfo[ballid][EBBallOwner] = playerid;
}
isPlayingBasketBall(playerid) {
	if(GetPVarType(playerid, "BasketBallArea") != PLAYER_VARTYPE_NONE) {
		return 1;
	}
	return 0;
}
loadBBallAnims(playerid, anim = BASKETBALL_WALK) {
	switch(anim) {
		case BASKETBALL_WALK: {
			ApplyAnimation(playerid,"BSKTBALL","BBALL_walk",4.1,1,1,1,1,1);
		}
		case BASKETBALL_RUN: {
			ApplyAnimation(playerid,"BSKTBALL","BBALL_run",4.1,1,1,1,1,1);
		}
		case BASKETBALL_DUNK: {
			ApplyAnimation(playerid, "BSKTBALL", "BBALL_DNK", 4.0, 0, 0, 0, 0, 0);
		}
		case BASKETBALL_DEFENSE: {
			ApplyAnimation(playerid, "BSKTBALL", "BBALL_DEF_LOOP", 4.0, 1, 0, 0, 0, 0);
		}
	}
}
unloadBBallAnims(playerid) {
	ClearAnimations(playerid);
	ApplyAnimation(playerid, "CARRY", "crry_prtial", 1.0, 0, 0, 0, 0, 0);
}
playBounceSoundForPeople(playerid, Float: radi = 5.0) {
	new Float: X, Float: Y, Float: Z;
	GetPlayerPos(playerid, X, Y, Z);
	foreach(Player, i) {
		if(IsPlayerConnectEx(i)) {
			if(IsPlayerInRangeOfPoint(i, radi, X, Y, Z)) {
				PlayerPlaySound(i, 4602, X, Y, Z);
			}
		}
	}
}
basketballKeysOnPlayerKeyState(playerid, newkeys, oldkeys) {
	#pragma unused oldkeys
	#if debug
	printf("basketballKeysOnPlayerKeyState(%d, %d, %d)", playerid, newkeys, oldkeys);
	#endif 
	if(isPlayingBasketBall(playerid)) {
		if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) {
			if(newkeys & KEY_JUMP) {
				tryScoreBBall(playerid);
			}
			if(newkeys & KEY_SPRINT) {
				tryMarkOpponent(playerid);
			}
			if(newkeys & KEY_HANDBRAKE) {
				tryPassBall(playerid);
			}
			if(newkeys & KEY_WALK) {
				loadBBallAnims(BASKETBALL_DEFENSE);
			}
		}
	}
	return 1;
}
tryMarkOpponent(playerid) {
	#if debug
		printf("tryMarkOpponent(%d)", playerid);
	#endif
	if(!basketballTackleCool(playerid)) {
		if(!hasBall(playerid)) {
			new opponentid = getClosestBBallOpponentID(playerid, 1.5);
			if(opponentid != -1) {
				sendBBall(playerid, opponentid, 0);
			}
		}
	}
}
basketballTackleCool(playerid) {
	new time = GetPVarInt(playerid, "SDKTackleCoolDown");
	new timenow = gettime();
	if(SDK_TACKLE_COOLDOWN-(timenow-time) > 0) {
		return 0;
	}
	SetPVarInt(playerid, "SDKTackleCoolDown", gettime());
	return 1;
}
tryPassBall(playerid) {
	#if debug
		printf("tryPassBall(%d)", playerid);
	#endif
	if(hasBall(playerid)) {
		new sendto = GetPlayerTargetPlayer(playerid);
		if(sendto != INVALID_PLAYER_ID) {
			sendBBall(playerid, sendto, 1);
		}
	}
}
sendBBall(playerid, opponentid, calculatedist) {
	new ballid = getLastBallID(playerid);
	if(getAreaUserIsPlayingAt(playerid) != getAreaUserIsPlayingAt(opponentid)) {
		return 1;
	}
	if(ballid != -1) {
		unloadBBallAnims(playerid);
		if(calculatedist != 1) { //Calculatedist will be used to calculate the time the ball will take to travel in seconds
			removeBallFromPlayer(opponentid);
			attachBBallToPlayer(playerid, ballid);
		} else {
			moveBallPhys(playerid, ballid, opponentid);
		}
	}
	return 1;
}
moveBallPhys(playerid, ballid, opponentid) {
	/*
	new Float: X, Float: Y, Float: Z, Float: XPpos, Float: YPpos, Float: ZPpos, Float: distance, Float: passSpeed, Float: Time;
	passSpeed = 8.0;
	GetPlayerPos(opponentid, X, Y, Z);
	distance = GetPlayerDistanceFromPoint(playerid, X, Y, Z);
	Time = distance/passSpeed;
	GetPlayerPos(playerid, XPpos, YPpos, ZPpos);
	BBallsInfo[ballid][EBallObjectID] = CreateDynamicObject(BBallsInfo[ballid][EBallModelID],BBallsInfo[ballid][EBallX], BBallsInfo[ballid][EBallY],BBallsInfo[ballid][EBallZ], BBallsInfo[ballid][EBallRotX], BBallsInfo[ballid][EBallRotY], BBallsInfo[ballid][EBallRotZ],BBallsInfo[ballid][EBallVW],BBallsInfo[ballid][EBallInt]);
	MoveDynamicObject(BBallsInfo[ballid][EBallObjectID], XPpos, YPpos, ZPpos, passSpeed);
	DestroyDynamicObject(BBallsInfo[ballid][EBallObjectID]);
	*/
	removeBallFromPlayer(playerid);
	attachBBallToPlayer(opponentid, ballid);
}
getClosestBBallOpponentID(playerid, Float: radi = 2.0) {
	new Float: X, Float: Y, Float: Z;
	GetPlayerPos(playerid, X, Y, Z);
	foreach(Player, i) {
		if(IsPlayerConnectEx(i)) {
			if(isPlayingBasketBall(i) && i != playerid) {
				if(IsPlayerInRangeOfPoint(i, radi, X, Y, Z)) {
					if(getAreaUserIsPlayingAt(i) == getAreaUserIsPlayingAt(playerid)) {
						if(hasBall(i)) {
							return i;
						}
					}
				}
			}
		}
	}
	return -1;
}
hasBall(playerid) {
	new ballid = getLastBallID(playerid);
	new getactualballowner = getBallOwner(ballid);
	#if debug
		printf("hasBall(%d): ballid: %d, getactualballowner: %d",playerid, ballid, getactualballowner);
	#endif
	if(playerid != getactualballowner) {
		return 0;
	}
	return 1;
}
tryScoreBBall(playerid) {
	#if debug
		printf("tryScoreBBall(%d)", playerid);
	#endif
	if(isAtBasketBallBasket(playerid, 6.0)) {
		if(hasBall(playerid)) {
			grantScore(playerid);
		}
	}
	return 1;
}
grantScore(playerid) {
	#if debug
		printf("grantScore(%d)", playerid);
	#endif
	TogglePlayerControllableEx(playerid, 0);
	SetTimerEx("SetControllable",1500,false,"dd",playerid,1);
	new basketid = getClosestBasketBallBasket(playerid, 6.0);
	new score = getBasketScore(basketid);
	setBasketScore(basketid, score+1);
	resyncBasketLabel(basketid);
	SetPlayerPos(playerid, BallBasketInfo[basketid][EBasketX], BallBasketInfo[basketid][EBasketY],BallBasketInfo[basketid][EBasketZ]-3.0);
	loadBBallAnims(playerid, BASKETBALL_DUNK);
	SendClientMessage(playerid, X11_WHITE, "[INFO]: Scored!");
	tryDropBall(playerid);
}
/*  ----------------------------- Things related with the baskets  ----------------------------- */
isAtBasketBallBasket(playerid, Float: radi = 5.0) { //Is at a basket
	for(new i=0;i<sizeof(BallBasketInfo);i++) {
		if(IsPlayerInRangeOfPoint(playerid, radi, BallBasketInfo[i][EBasketX], BallBasketInfo[i][EBasketY],BallBasketInfo[i][EBasketZ])) {
			return 1;
		}
	}
	return 0;
}
getClosestBasketBallBasket(playerid, Float: radi = 3.0) { //Gets the closest BasketBall Basket
	for(new i=0;i<sizeof(BallBasketInfo);i++) {
		if(IsPlayerInRangeOfPoint(playerid, radi, BallBasketInfo[i][EBasketX], BallBasketInfo[i][EBasketY],BallBasketInfo[i][EBasketZ])) {
			return i;
		}
	}
	return -1;
}
resyncBasketLabel(basketid) {
	new bBallScoreLabel[128];
	format(bBallScoreLabel, sizeof(bBallScoreLabel), "{FFFFFF}Score: %d", BallBasketInfo[basketid][EBasketScore]);
	UpdateDynamic3DTextLabelText(BallBasketInfo[basketid][EBasketText],X11_WHITE,bBallScoreLabel);
}
restartBasketScores(areaid) {
	for(new i=0;i<sizeof(BallBasketInfo);i++) {
		if(BallBasketInfo[i][EBasketArea] == areaid) {
			setBasketScore(i, 0);
			resyncBasketLabel(i);
		}
	}
}
getBasketScore(basketid) {
	return BallBasketInfo[basketid][EBasketScore];
}
setBasketScore(basketid, amount) {
	BallBasketInfo[basketid][EBasketScore] = amount;
}
getBasketTeam(basketid) {
	return BallBasketInfo[basketid][EBasketTeam];
}
/* --------------------- OnPlayerDisconnect Handling -------------------------------- */
basketballOnPlayerDisconnect(playerid, reason) {
	#pragma unused reason
	if(isPlayingBasketBall(playerid)) {
		exitBBallGame(playerid);
	}
	return 1;
}
