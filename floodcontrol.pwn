/* Purpose: Controlling overall flood on the server */

/* Defines */
#define FLOODCMD_COOLDOWN 0.1
#define MAX_CMD_FLOOD_WARNS 8
#define INTERIOR_COOLDOWN 2
#define MAX_INTERIOR_WARNS 8
#define CARDEATH_COOLDOWN 2
#define MAX_CARDEATH_WARNS 3
#define PLAYERDEATH_COOLDOWN 2
#define MAX_PLAYERDEATH_WARNS 3
//-----------

/* New's */
new cmdFloodWarns[MAX_PLAYERS];
new interiorWarns[MAX_PLAYERS];
new carDeathWarns[MAX_PLAYERS];
new playerDeathWarns[MAX_PLAYERS];
//-----------

/* Functions */
isFloodingCommands(playerid) { //returns 1 if a player is flooding commands and 0 if not. If 1, it assigns a command flood warn and doesn't allow the player to perform any commands
	new time = GetPVarInt(playerid, "CommandCoolDown");
	new timenow = gettime();
	if(FLOODCMD_COOLDOWN-(timenow-time) > 0) {
		assignAndCheckFloodWarns(playerid);
		#if debug
		printf("Last Spam: Time: %f", FLOODCMD_COOLDOWN-(timenow-time));
		#endif
		return 1;
	}
	cmdFloodWarns[playerid] = 0; //If the above doesn't happen
	SetPVarInt(playerid, "CommandCoolDown", gettime());
	return 0;
}

assignAndCheckFloodWarns(playerid) {
	if(++cmdFloodWarns[playerid] > MAX_CMD_FLOOD_WARNS) {
		hackKick(playerid, "Spamming Commands", "Command Spamming");
	}
	return 1;
}

onInteriorFloodCheck(playerid) {
	new time = GetPVarInt(playerid, "InteriorCoolDown");
	new timenow = gettime();
	if(INTERIOR_COOLDOWN-(timenow-time) > 0) {
		assignAndCheckInteriorWarns(playerid);
		return 1;
	}
	interiorWarns[playerid] = 0; //If the above doesn't happen
	SetPVarInt(playerid, "InteriorCoolDown", gettime());
	return 1;
}

assignAndCheckInteriorWarns(playerid) {
	if(++interiorWarns[playerid] > MAX_INTERIOR_WARNS) {
		hackKick(playerid, "Spamming Interiors", "Interior Spamming");
	}
	return 1;
}

isFloodingCarDeaths(playerid) { //returns 1 if a player is flooding car deaths and 0 if not. If 1, it assigns a car death flood warn
	if(playerid != INVALID_PLAYER_ID) {
		new time = GetPVarInt(playerid, "CarDeathCoolDown");
		new timenow = gettime();
		if(CARDEATH_COOLDOWN-(timenow-time) > 0) {
			checkCarFloodWarns(playerid);
			#if debug
			printf("Last Spam: Time: %f", CARDEATH_COOLDOWN-(timenow-time));
			#endif
			return 1;
		}
		carDeathWarns[playerid] = 0; //If the above doesn't happen
		SetPVarInt(playerid, "CarDeathCoolDown", gettime());
	}
	return 0;
}

checkCarFloodWarns(playerid) {
	if(++carDeathWarns[playerid] > MAX_CARDEATH_WARNS) {
		hackKick(playerid, "Spamming Car Deaths", "Spamming Car Deaths");
	}
	return 1;
}

isFloodingPlayerDeaths(playerid) { //returns 1 if a player is flooding car deaths and 0 if not. If 1, it assigns a car death flood warn
	new time = GetPVarInt(playerid, "PlayerDeathCoolDown");
	new timenow = gettime();
	if(PLAYERDEATH_COOLDOWN-(timenow-time) > 0) {
		checkPlayerDeathFloodWarns(playerid);
		#if debug
		printf("Last Spam: Time: %f", PLAYERDEATH_COOLDOWN-(timenow-time));
		#endif
		return 1;
	}
	playerDeathWarns[playerid] = 0; //If the above doesn't happen
	SetPVarInt(playerid, "PlayerDeathCoolDown", gettime());
	return 0;
}

checkPlayerDeathFloodWarns(playerid) {
	if(++playerDeathWarns[playerid] > MAX_PLAYERDEATH_WARNS) {
		hackKick(playerid, "Spamming Fake Deaths", "Spamming Fake Deaths");
	}
	return 1;
}

onFloodCheckerDisconnect(playerid, reason) {
	#pragma unused reason
	if(reason != 3) {
		DeletePVar(playerid, "CommandCoolDown");
		DeletePVar(playerid, "InteriorCoolDown");
		DeletePVar(playerid, "CarDeathCoolDown");
		DeletePVar(playerid, "PlayerDeathCoolDown");
		cmdFloodWarns[playerid] = 0;
		interiorWarns[playerid] = 0;
		carDeathWarns[playerid] = 0;
		playerDeathWarns[playerid] = 0;
	}
	return 1;
}
