MySQL_Init()
{
	if (hDatabase != INVALID_HANDLE) return;	// already connected.
	//hDatabase														=	INVALID_HANDLE;

	GetConfigValue(TheDBPrefix, sizeof(TheDBPrefix), "database prefix?");
	GetConfigValue(Hostname, sizeof(Hostname), "server name?");
	if (GetConfigValueInt("friendly fire enabled?") == 1) ReplaceString(Hostname, sizeof(Hostname), "{FF}", "FF ON");
	else ReplaceString(Hostname, sizeof(Hostname), "{FF}", "FF OFF");
	if (StrContains(Hostname, "{V}", true) != -1) ReplaceString(Hostname, sizeof(Hostname), "{V}", PLUGIN_VERSION);

	iServerLevelRequirement		= GetConfigValueInt("server level requirement?");
	RatingPerLevel				= GetConfigValueInt("rating level multiplier?");
	InfectedTalentLevel			= GetConfigValueInt("talent level multiplier?");
	fEnrageModifier				= GetConfigValueFloat("enrage modifier?");

	if (iServerLevelRequirement > 0) {

		if (StrContains(Hostname, "{RS}", true) != -1) {

			decl String:HostLevels[64];
			//Format(HostLevels, sizeof(HostLevels), "Lv%s(TruR%s)", AddCommasToString(iServerLevelRequirement), AddCommasToString(iServerLevelRequirement * RatingPerLevel));
			Format(HostLevels, sizeof(HostLevels), "Lv%d+", iServerLevelRequirement);
			ReplaceString(Hostname, sizeof(Hostname), "{RS}", HostLevels);
		}
	}
	//Format(sHostname, sizeof(sHostname), "%s", Hostname);

	GetConfigValue(RatingType, sizeof(RatingType), "db record?");
	if (StrEqual(RatingType, "-1")) {

		if (ReadyUp_GetGameMode() == 3) Format(RatingType, sizeof(RatingType), "%s", SURVRECORD_DB);
		else Format(RatingType, sizeof(RatingType), "%s", COOPRECORD_DB);
	}

	//LogMessage("Setting hostname %s", Hostname);
	ServerCommand("hostname %s", Hostname);
	//SetSurvivorsAliveHostname();
	SQL_TConnect(DBConnect, TheDBPrefix);
}

stock SetSurvivorsAliveHostname() {

	static String:Newhost[64];
	Format(Newhost, sizeof(Newhost), "%s", sHostname);
	if (b_IsActiveRound) Format(Newhost, sizeof(Newhost), "%s - %d alive", sHostname, LivingSurvivors());
	else Format(Newhost, sizeof(Newhost), "%s - Intermission", sHostname);
	ServerCommand("hostname %s", Newhost);
}

public ReadyUp_GroupMemberStatus(client, groupStatus) {

	if (IsLegitimateClient(client)) {
		if (HasCommandAccess(client, "donator package flag?") || groupStatus == 1) IsGroupMember[client] = true;
		else IsGroupMember[client] = false;

		CheckGroupStatus(client);
	}
}

public DBConnect(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
	{
		LogMessage("Unable to connect to database: %s", error);
		SetFailState("%s", error);
	}

	hDatabase = hndl;

	new GenerateDB = GetConfigValueInt("generate database?");
	
	decl String:tquery[PLATFORM_MAX_PATH];
	decl String:text[64];
	
	if (GenerateDB == 1) {

		//Format(tquery, sizeof(tquery), "SET NAMES 'UTF8';");
		//SQL_TQuery(hDatabase, QueryResults, tquery);
		//Format(tquery, sizeof(tquery), "SET CHARACTER SET utf8;");
		//SQL_TQuery(hDatabase, QueryResults, tquery);

		//Format(tquery, sizeof(tquery), "CREATE TABLE IF NOT EXISTS `%s_maps` (`mapname` varchar(64) NOT NULL, PRIMARY KEY (`mapname`)) ENGINE=MyISAM;", TheDBPrefix);
		//SQL_TQuery(hDatabase, QueryResults, tquery);

		Format(tquery, sizeof(tquery), "CREATE TABLE IF NOT EXISTS `%s` (`steam_id` varchar(64) NOT NULL, PRIMARY KEY (`steam_id`)) ENGINE=InnoDB;", TheDBPrefix);
		LogMessage(tquery);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` CHARACTER SET utf8 COLLATE utf8_general_ci;", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `primarywep` varchar(32) NOT NULL DEFAULT 'none';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `secondwep` varchar(32) NOT NULL DEFAULT 'none';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `exp` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `expov` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `upgrade cost` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `level` int(32) NOT NULL DEFAULT '1';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `skylevel` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);

		GetConfigValue(text, sizeof(text), "sky points menu name?");
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `%s` int(32) NOT NULL DEFAULT '0';", TheDBPrefix, text);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `time played` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `talent points` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `total upgrades` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `free upgrades` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `restt` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `restexp` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `lpl` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `resr` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `survpoints` varchar(32) NOT NULL DEFAULT '0.0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `bec` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `rem` varchar(32) NOT NULL DEFAULT '0.0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `%s` int(32) NOT NULL DEFAULT '0';", TheDBPrefix, COOPRECORD_DB);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `%s` int(32) NOT NULL DEFAULT '0';", TheDBPrefix, SURVRECORD_DB);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		GetConfigValue(text, sizeof(text), "db record?");
		if (!StrEqual(text, "-1")) {

			Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `%s` int(32) NOT NULL DEFAULT '0';", TheDBPrefix, text);
			SQL_TQuery(hDatabase, QueryResults, tquery);
		}
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `myrating %s` int(32) NOT NULL DEFAULT '0';", TheDBPrefix, RatingType);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `ratinghc %s` int(32) NOT NULL DEFAULT'0';", TheDBPrefix, RatingType);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `pri` int(32) NOT NULL DEFAULT '1';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `tcolour` varchar(32) NOT NULL DEFAULT 'none';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `tname` varchar(32) NOT NULL DEFAULT 'none';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `ccolour` varchar(32) NOT NULL DEFAULT 'none';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		//Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `mapname` varchar(32) NOT NULL DEFAULT 'none';", TheDBPrefix);
		//SQL_TQuery(hDatabase, QueryResults, tquery);

		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `xpdebt` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `upav` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `upawarded` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);

		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `companionname` varchar(32) NOT NULL DEFAULT 'survivor';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `companionowner` varchar(32) NOT NULL DEFAULT 'survivor';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);

		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `lastserver` varchar(64) NOT NULL DEFAULT 'none';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `myseason` varchar(32) NOT NULL DEFAULT 'none';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);

		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `lvlpaused` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `itrails` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);

		/*
			weapon levels
			\\rewarding players who use a specific weapon category with increased proficiency in that category.
		*/
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `pistol_xp` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `melee_xp` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `uzi_xp` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		/*
			has both pump and auto shotgun tiers
		*/
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `shotgun_xp` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `sniper_xp` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `assault_xp` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);

		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `medic_xp` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `grenade_xp` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);


		Format(tquery, sizeof(tquery), "CREATE TABLE IF NOT EXISTS `%s_loot` (`owner_id` varchar(64) NOT NULL, PRIMARY KEY (`owner_id`)) ENGINE=InnoDB;", TheDBPrefix);
		LogMessage(tquery);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` CHARACTER SET utf8 COLLATE utf8_general_ci;", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `constitution` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `resilience` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `agility` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `technique` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `endurance` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `armor` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `talent` varchar(32) NOT NULL DEFAULT 'none';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `reference` varchar(32) NOT NULL DEFAULT 'none';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `augments` varchar(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `value` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `forsale` int(4) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `itemname` varchar(64) NOT NULL DEFAULT 'none';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);



		new ActionSlotSize = iActionBarSlots;
		for (new i = 0; i < ActionSlotSize; i++) {

			Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `aslot%d` VARCHAR(32) NOT NULL DEFAULT 'None';", TheDBPrefix, i+1);
			SQL_TQuery(hDatabase, QueryResults, tquery);
		}
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `disab` INT(4) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);

		/*new size			=	GetArraySize(a_Database_Talents);

		for (new i = 0; i < size; i++) {

			GetArrayString(Handle:a_Database_Talents, i, text, sizeof(text));
			Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `%s` int(32) NOT NULL DEFAULT '0';", TheDBPrefix, text);
			SQL_TQuery(hDatabase, QueryResults, tquery);
		}*/
	}

	ClearArray(Handle:a_Database_Talents_Defaults);
	ClearArray(Handle:a_Database_Talents_Defaults_Name);
	//ClearArray(Handle:a_ClassNames);

	decl String:NewValue[64];

	new size			=	GetArraySize(a_Menu_Talents);
	nodesInExistence	=	0;
	//new TheValue		=	0;
	new nodeLayer		=	0;	// this will hide nodes not currently available from players total node count.
	for (new i = 0; i < size; i++) {

		DatabaseKeys			=	GetArrayCell(a_Menu_Talents, i, 0);
		DatabaseValues			=	GetArrayCell(a_Menu_Talents, i, 1);
		if (GetKeyValueInt(DatabaseKeys, DatabaseValues, "is sub menu?") == 1) continue;

		DatabaseSection			=	GetArrayCell(a_Menu_Talents, i, 2);

		GetArrayString(Handle:DatabaseSection, 0, text, sizeof(text));
		PushArrayString(Handle:a_Database_Talents_Defaults_Name, text);
		/*if (GetKeyValueInt(DatabaseKeys, DatabaseValues, "is survivor class role?") == 1) {

			PushArrayString(a_ClassNames, text);
			//continue;
		}*/

		//FormatKeyValue(NewValue, sizeof(NewValue), DatabaseKeys, DatabaseValues, "ability inherited?");
		//TheValue	= StringToInt(NewValue);
		nodeLayer = GetKeyValueInt(DatabaseKeys, DatabaseValues, "layer?");
		if (nodeLayer >= 1 && nodeLayer <= iMaxLayers) nodesInExistence++;

		if (GenerateDB == 1) {

			Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `%s` int(32) NOT NULL DEFAULT '0';", TheDBPrefix, text);
			//else Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `%s` int(32) NOT NULL DEFAULT '-1';", TheDBPrefix, text);
			SQL_TQuery(hDatabase, QueryResults, tquery);

			if (GetKeyValueInt(DatabaseKeys, DatabaseValues, "talent type?") == 1) {

				Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `%s xp` int(32) NOT NULL DEFAULT '0';", TheDBPrefix, text);
				SQL_TQuery(hDatabase, QueryResults, tquery);
			}
		}

		//if (StringToInt(NewValue) < 0) Format(NewValue, sizeof(NewValue), "0");
		PushArrayString(Handle:a_Database_Talents_Defaults, NewValue);
	}

	if (GenerateDB == 1) {

		GenerateDB = 0;

		size				=	GetArraySize(a_DirectorActions);

		for (new i = 0; i < size; i++) {

			DatabaseSection			=	GetArrayCell(a_DirectorActions, i, 2);
			GetArrayString(Handle:DatabaseSection, 0, text, sizeof(text));
			Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `%s` int(32) NOT NULL DEFAULT '0';", TheDBPrefix, text);
			SQL_TQuery(hDatabase, QueryResults, tquery);
		}

		size				=	GetArraySize(a_Store);

		for (new i = 0; i < size; i++) {

			DatabaseSection			=	GetArrayCell(a_Store, i, 2);
			GetArrayString(Handle:DatabaseSection, 0, text, sizeof(text));
			Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `%s` int(32) NOT NULL DEFAULT '0';", TheDBPrefix, text);
			SQL_TQuery(hDatabase, QueryResults, tquery);
		}
	}

	size = GetArraySize(a_Database_Talents);

	ResizeArray(Handle:a_Database_PlayerTalents_Bots, size);
	ResizeArray(Handle:PlayerAbilitiesCooldown_Bots, size);
	ResizeArray(Handle:PlayerAbilitiesImmune_Bots, size);
}

public QuerySaveNewPlayer(Handle:owner, Handle:hndl, const String:error[], any:client) {

	if (hndl == INVALID_HANDLE) {

		if (StrContains(error, "Duplicate column name", false) == -1) LogMessage("QuerySaveNewPlayer Error %s", error);
		return;
	}
	if (IsLegitimateClient(client)) SaveAndClear(client, _, true);
}

public QueryResults(Handle:owner, Handle:hndl, const String:error[], any:client) {

	if (hndl == INVALID_HANDLE) {

		if (StrContains(error, "Duplicate column name", false) == -1) LogMessage("QueryResults Error %s", error);
		return;
	}
}

public QueryResults1(Handle:owner, Handle:hndl, const String:error[], any:client) {

	if (hndl == INVALID_HANDLE) {

		if (StrContains(error, "Duplicate column name", false) == -1) LogMessage("QueryResults1 Error %s", error);
		return;
	}
}

public QueryResults2(Handle:owner, Handle:hndl, const String:error[], any:client) {

	if (hndl == INVALID_HANDLE) {

		if (StrContains(error, "Duplicate column name", false) == -1) LogMessage("QueryResults2 Error %s", error);
		return;
	}
}

public QueryResults3(Handle:owner, Handle:hndl, const String:error[], any:client) {

	if (hndl == INVALID_HANDLE) {

		if (StrContains(error, "Duplicate column name", false) == -1) LogMessage("QueryResults3 Error %s", error);
		return;
	}
}

public QueryResults4(Handle:owner, Handle:hndl, const String:error[], any:client) {

	if (hndl == INVALID_HANDLE) {

		if (StrContains(error, "Duplicate column name", false) == -1) LogMessage("QueryResults4 Error %s", error);
		return;
	}
}

public QueryResults5(Handle:owner, Handle:hndl, const String:error[], any:client) {

	if (hndl == INVALID_HANDLE) {

		if (StrContains(error, "Duplicate column name", false) == -1) LogMessage("QueryResults5 Error %s", error);
		return;
	}
}

public QueryResults6(Handle:owner, Handle:hndl, const String:error[], any:client) {

	if (hndl == INVALID_HANDLE) {

		if (StrContains(error, "Duplicate column name", false) == -1) LogMessage("QueryResults6 Error %s", error);
		return;
	}
}

public QueryResults7(Handle:owner, Handle:hndl, const String:error[], any:client) {

	if (hndl == INVALID_HANDLE) {

		if (StrContains(error, "Duplicate column name", false) == -1) LogMessage("QueryResults7 Error %s", error);
		return;
	}
}

public QueryResults8(Handle:owner, Handle:hndl, const String:error[], any:client) {

	if (hndl == INVALID_HANDLE) {

		if (StrContains(error, "Duplicate column name", false) == -1) LogMessage("QueryResults8 Error %s", error);
		return;
	}
}

stock LoadLeaderboards(client, count) {

	new listpage = GetConfigValueInt("leaderboard players per page?");
	if (count == 0) {

		if (TheLeaderboardsPageSize[client] >= listpage) TheLeaderboardsPage[client] -= listpage;
		else TheLeaderboardsPage[client] = 0;
	}
	else if (TheLeaderboardsPageSize[client] >= listpage) {		// if a page didn't load 10 entries, we don't increment. If a page exactly 10 entries, the next page will be empty and only have a return option.

		TheLeaderboardsPage[client] += listpage;
	}
	decl String:tquery[1024];
	decl String:Mapname[64];
	GetCurrentMap(Mapname, sizeof(Mapname));

	Format(tquery, sizeof(tquery), "SELECT `tname`, `level`, `steam_id`, `%s` FROM `%s` ORDER BY `%s` DESC;", RatingType, TheDBPrefix, RatingType);
	SQL_TQuery(hDatabase, LoadLeaderboardsQuery, tquery, client);
}

public LoadLeaderboardsQuery(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
	{
		LogMessage("[LoadLeaderboardsQuery] %s", error);
		return;
	}
	new i = 0;
	new count = 0;
	new counter = 0;
	new listpage = GetConfigValueInt("leaderboard players per page?");
	new Handle:LeadName = CreateArray(16);
	new Handle:LeadLevel = CreateArray(16);
	new Handle:LeadSteam = CreateArray(16);
	new Handle:LeadRating = CreateArray(16);

	if (!bIsMyRanking[data]) {

		ResizeArray(Handle:LeadName, listpage);
		ResizeArray(Handle:LeadLevel, listpage);
		ResizeArray(Handle:LeadSteam, listpage);
		ResizeArray(Handle:LeadRating, listpage);
	}
	else {

		ResizeArray(Handle:LeadName, 1);
		ResizeArray(Handle:LeadLevel, 1);
		ResizeArray(Handle:LeadSteam, 1);
		ResizeArray(Handle:LeadRating, 1);
	}
	decl String:text[64];
	//decl String:tquery[1024];
	new Pint = 0;
	new IgnoreRating = RatingPerLevel;
	decl String:SteamID[64];
	GetClientAuthString(data, SteamID, sizeof(SteamID));
	ClearArray(TheLeaderboards[data]);		// reset the data held when a page is loaded.

	while (i < listpage && SQL_FetchRow(hndl))
	{
		SQL_FetchString(hndl, 2, text, sizeof(text));
		if (bIsMyRanking[data] && !StrEqual(text, SteamID, false)) {

			counter++;
			continue;
		}
		if (StrContains(text, sBotTeam, false) != -1) continue;

		count++;
		counter++;
		if (count < TheLeaderboardsPage[data]) continue;

		Pint = SQL_FetchInt(hndl, 3);
		if (Pint <= IgnoreRating) {

			count--;
			counter--;
			continue;	// players can un-set their name to hide themselves on the leaderboards.
		}

		/*SQL_FetchString(hndl, 2, text, sizeof(text));
		if (bIsMyRanking[data] && !StrEqual(text, SteamID, false)) {// ||
			//StrContains(text, "STEAM_", true) == -1) {

			count--;
			//if (StrContains(text, "STEAM_", true) == -1)
			//counter--;
			continue;	// will not display bots rating in the leaderboards.
		}*/

		SQL_FetchString(hndl, 0, text, sizeof(text));
		if (strlen(text) < 16) {

			if (strlen(text) > 12) Format(text,sizeof(text), "%s\t", text);
			else if (strlen(text) > 8) Format(text,sizeof(text), "%s\t\t", text);
			else if (strlen(text) > 4) Format(text,sizeof(text), "%s\t\t\t", text);
			else Format(text,sizeof(text), "%s\t\t\t\t", text);
		}
		Format(text, sizeof(text), "#%d %s", counter, text);

		SetArrayString(Handle:LeadName, i, text);

		Pint = SQL_FetchInt(hndl, 1);
		Format(text, sizeof(text), "%d", Pint);
		SetArrayString(Handle:LeadLevel, i, text);

		//SQL_FetchString(hndl, 2, text, sizeof(text));
		//if (bIsMyRanking[data] && !StrEqual(text, SteamID, false)) continue;
		//if (StrContains(SteamID, "STEAM_", true) == -1) continue;	// will not display bots rating in the leaderboards.

		SetArrayString(Handle:LeadSteam, i, text);

		Pint = SQL_FetchInt(hndl, 3);
		Format(text, sizeof(text), "%d", Pint);
		SetArrayString(Handle:LeadRating, i, text);

		i++;
		if (bIsMyRanking[data]) break;
	}
	//bIsMyRanking[data] = false;

	//new size = GetArraySize(TheLeaderboards[data]);

	if (!bIsMyRanking[data]) {

		ResizeArray(Handle:LeadName, i);
		ResizeArray(Handle:LeadLevel, i);
		ResizeArray(Handle:LeadSteam, i);
		ResizeArray(Handle:LeadRating, i);
	}
	TheLeaderboardsPageSize[data] = i;

	ResizeArray(TheLeaderboards[data], 1);
	SetArrayCell(TheLeaderboards[data], 0, LeadName, 0);
	SetArrayCell(TheLeaderboards[data], 0, LeadLevel, 1);
	SetArrayCell(TheLeaderboards[data], 0, LeadSteam, 2);
	SetArrayCell(TheLeaderboards[data], 0, LeadRating, 3);

	if (GetArraySize(TheLeaderboards[data]) > 0) SendPanelToClientAndClose(DisplayTheLeaderboards(data), data, DisplayTheLeaderboards_Init, MENU_TIME_FOREVER);
	else BuildMenu(data);

	CloseHandle(LeadName);
	CloseHandle(LeadLevel);
	CloseHandle(LeadSteam);
	CloseHandle(LeadRating);
}

stock ResetData(client) {

	RefreshSurvivor(client);
	bIsCrushCooldown[client]		= false;
	Points[client]					= 0.0;
	SlatePoints[client]				= 0;
	FreeUpgrades[client]			= 0;
	b_IsDirectorTalents[client]		= false;
	b_IsJumping[client]				= false;
	ModifyGravity(client);
	ResetCoveredInBile(client);
	SpeedMultiplierBase[client]		= 1.0;
	if (IsLegitimateClientAlive(client) && !IsGhost(client)) SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", SpeedMultiplierBase[client]);
	TimePlayed[client]				= 0;
	t_Distance[client]				= 0;
	t_Healing[client]				= 0;
	b_IsBlind[client]				= false;
	b_IsImmune[client]				= false;
	GravityBase[client]				= 1.0;
	CommonKills[client]				= 0;
	CommonKillsHeadshot[client]		= 0;
	bIsMeleeCooldown[client]		= false;
	shotgunCooldown[client]			= false;
	ClearArray(Handle:InfectedHealth[client]);
	ClearArray(PlayerActiveAmmo[client]);
	ClearArray(PlayActiveAbilities[client]);
	ClearArray(ApplyDebuffCooldowns[client]);
	StrugglePower[client] = 0;
}

stock ClearAndLoad(client, bool:IgnoreLoad = false) {

	if (hDatabase == INVALID_HANDLE) return;
	//new client = FindClientWithAuthString(key, true);
	if (client < 1) return;

	decl String:key[64];
	GetClientAuthString(client, key, sizeof(key));

	//if (StrContains(key, "BOT", false) != -1) {
	if (IsFakeClient(client)) {

		decl String:TheName[64];
		GetSurvivorBotName(client, TheName, sizeof(TheName));
		Format(key, 64, "%s%s", sBotTeam, TheName);
	}

	new size = GetArraySize(Handle:a_Database_Talents);
	if (GetArraySize(a_Database_PlayerTalents[client]) != size) {

		ResizeArray(a_Database_PlayerTalents[client], size);
		ResizeArray(PlayerAbilitiesCooldown[client], size);
		ResizeArray(a_Database_PlayerTalents_Experience[client], size);
			//for (new i = 1; i <= MAXPLAYERS; i++) ResizeArray(PlayerAbilitiesImmune[client][i], size);
	}
	ClearArray(Handle:hWeaponList[client]);
	ResizeArray(Handle:hWeaponList[client], 2);

	decl String:text[64];
	Format(text, sizeof(text), "none");
	SetArrayString(Handle:hWeaponList[client], 0, text);
	SetArrayString(Handle:hWeaponList[client], 1, text);
	if (b_IsLoading[client] && !IgnoreLoad) return;
	b_IsLoading[client] = true;
	ResetData(client);

	LoadPos[client] = 0;

	if (!b_IsArraysCreated[client]) {

		b_IsArraysCreated[client]			= true;
	}
	if (GetArraySize(a_Store_Player[client]) != GetArraySize(a_Store)) {

		ResizeArray(a_Store_Player[client], GetArraySize(a_Store));
	}

	for (new i = 0; i < GetArraySize(a_Store); i++) {

		SetArrayString(a_Store_Player[client], i, "0");				// We clear all players arrays for the store.
	}
	ResizeArray(Handle:ChatSettings[client], 3);
	decl String:tquery[2048];
	Format(tquery, sizeof(tquery), "none");
	SetArrayString(Handle:ChatSettings[client], 0, tquery);
	SetArrayString(Handle:ChatSettings[client], 1, tquery);
	SetArrayString(Handle:ChatSettings[client], 2, tquery);

	//LogMessage("Loading %N data", client);

	decl String:themenu[64];
	GetConfigValue(themenu, sizeof(themenu), "sky points menu name?");

	Format(tquery, sizeof(tquery), "SELECT `steam_id`, `exp`, `expov`, `upgrade cost`, `level`, `skylevel`, `%s`, `time played`, `talent points`, `total upgrades`, `free upgrades`, `restt`,`restexp`, `lpl`, `resr`, `survpoints`, `bec`, `rem`, `pri`, `tcolour`, `tname`, `ccolour`, `xpdebt`, `upav`, `upawarded`, `%s`, `myrating %s`, `ratinghc %s`, `lastserver`, `myseason`, `lvlpaused`, `itrails`, `pistol_xp`, `melee_xp`, `uzi_xp`, `shotgun_xp`, `sniper_xp`, `assault_xp`, `medic_xp`, `grenade_xp` FROM `%s` WHERE (`steam_id` = '%s');", themenu, RatingType, RatingType, RatingType, TheDBPrefix, key);
// maybe set a value equal to the users steamid integer only, so if steam:0:1:23456, set the value of "client" equal to 23456 and then set the client equal to whatever client's steamid contains 23456?
	SQL_TQuery(hDatabase, QueryResults_Load, tquery, client);
}

public Query_CheckIfProfileLimit(Handle:owner, Handle:hndl, const String:error[], any:client) {

	if (hndl == INVALID_HANDLE) {

		LogMessage("Query_CheckIfProfileLimit Error: %s", error);
		return;
	}
	new ProfileCountLimit = GetConfigValueInt("profile editor limit?");
	decl String:thetext[64];
	GetConfigValue(thetext, sizeof(thetext), "donator package flag?");
	if (IsGroupMember[client] || HasCommandAccess(client, thetext)) ProfileCountLimit = RoundToCeil(ProfileCountLimit * 2.0);
	decl String:tquery[1024];
	decl String:key[128];

	while (SQL_FetchRow(hndl)) {

		if (SQL_FetchInt(hndl, 0) < ProfileCountLimit) {

			GetClientAuthString(client, key, sizeof(key));
			Format(key, sizeof(key), "%s%s+%s", key, PROFILE_VERSION, LoadoutName[client]);

			Format(tquery, sizeof(tquery), "SELECT COUNT(*) FROM `%s` WHERE (`steam_id` = '%s');", TheDBPrefix, key);
			SQL_TQuery(hDatabase, Query_CheckIfProfileExists, tquery, client);
		}
		else PrintToChat(client, "%T", "profile editor limit reached", client, orange);
	}
}

public Query_CheckCompanionCount(Handle:owner, Handle:hndl, const String:error[], any:client) {

	if (hndl == INVALID_HANDLE) {

		LogMessage("Query_CheckCompanionCount Error: %s", error);
		return;
	}
	while (SQL_FetchRow(hndl)) {

		if (SQL_FetchInt(hndl, 0) >= GetConfigValueInt("max unique companions?")) {

			PrintToChat(client, "companion limit %d exceeded", GetConfigValueInt("max unique companions?"));
			return;
		}
		else {

			PrintToChat(client, "Your party is not full, adding %s to the party!", CompanionNameQueue[client]);

			decl String:tquery[1024];
			Format(tquery, sizeof(tquery), "SELECT COUNT(*) FROM `%s` WHERE `companionname` = '%s';", TheDBPrefix, CompanionNameQueue[client]);
			SQL_TQuery(hDatabase, Query_CheckIfCompanionExists, tquery, client);
		}
	}
}

public Query_CheckIfCompanionExists(Handle:owner, Handle:hndl, const String:error[], any:client) {

	if (hndl == INVALID_HANDLE) {

		LogMessage("Query_CheckIfCompanionExists Error: %s", error);
		return;
	}
	while (SQL_FetchRow(hndl)) {

		if (SQL_FetchInt(hndl, 0) < 1) {

			ReadyUp_NtvCreateCompanion(client, CompanionNameQueue[client]);		// The companion of this name doesn't exist, so we allow the player to create it.
			CreateTimer(1.0, Timer_SaveCompanion, client, TIMER_FLAG_NO_MAPCHANGE);		// now we save the companion to the database so no one else can use this name.
		}
		else {

			PrintToChat(client, "companion name taken, please pick another");
			return;
		}
	}
}

public Query_CheckIfProfileExists(Handle:owner, Handle:hndl, const String:error[], any:client) {

	if (hndl == INVALID_HANDLE) {

		LogMessage("Query_CheckIfProfileExists Error: %s", error);
		return;
	}
	while (SQL_FetchRow(hndl)) {

		if (SQL_FetchInt(hndl, 0) < 1) {

			SaveProfile(client, 1);		// 1 for saving a new profile.
		}
		else SaveProfile(client, 2);	// 2 for overwriting an existing profile.
	}
}

stock ModifyCartelValue(client, String:thetalent[], thevalue) {

	new size = GetArraySize(a_Menu_Talents);
	decl String:text[512];

	for (new i = 0; i < size; i++) {

		CartelValueKeys[client]			= GetArrayCell(a_Menu_Talents, i, 0);
		CartelValueValues[client]		= GetArrayCell(a_Menu_Talents, i, 1);

		if (GetKeyValueInt(CartelValueKeys[client], CartelValueValues[client], "is sub menu?") == 1) continue;
		if (GetKeyValueInt(CartelValueKeys[client], CartelValueValues[client], "talent type?") <= 0) continue;

		GetArrayString(a_Database_Talents, i, text, sizeof(text));
		if (!StrEqual(text, thetalent, false)) continue;
		
		SetArrayCell(a_Database_PlayerTalents[client], i, thevalue);
		SetArrayCell(a_Database_PlayerTalents_Experience[client], i, 0);
	}
}

stock CreateNewPlayerEx(client) {

	decl String:tquery[1024];
	//decl String:text[64];
	decl String:TagColour[64];
	decl String:TagName[64];
	decl String:ChatColour[64];
	new size = GetArraySize(Handle:a_Database_Talents);

	decl String:key[512];
	decl String:TheName[64];
	if (IsSurvivorBot(client)) {

		GetSurvivorBotName(client, TheName, sizeof(TheName));
		Format(key, sizeof(key), "%s%s", sBotTeam, TheName);
	}
	else {

		GetClientAuthString(client, key, sizeof(key));
	}

	LogMessage("No data rows for %N with steamid: %s, could be found, creating new player data.", client, key);

	ResizeArray(Handle:ChatSettings[client], 3);

	Format(tquery, sizeof(tquery), "none");
	SetArrayString(Handle:ChatSettings[client], 0, tquery);
	SetArrayString(Handle:ChatSettings[client], 1, tquery);
	SetArrayString(Handle:ChatSettings[client], 2, tquery);

	if (IsSurvivorBot(client) || IsFakeClient(client)) PlayerLevel[client] = iBotPlayerStartingLevel;
	else PlayerLevel[client]				=	iPlayerStartingLevel;
	SetTotalExperienceByLevel(client, PlayerLevel[client]);
	ChallengeEverything(client);

	bIsNewPlayer[client]			= true;
	b_IsLoading[client]				= false;
	bIsTalentTwo[client]			= false;
	b_IsLoadingStore[client]		= false;
	b_IsLoadingTrees[client]		= false;
	LoadTarget[client]				=	-1;
	Rating[client]					=	0;
	ExperienceDebt[client]			=	0;
	//ExperienceLevel[client]			=	1;
	//ExperienceOverall[client]		=	1;
	PlayerLevelUpgrades[client]		=	0;
	SkyPoints[client]				=	0;
	TotalTalentPoints[client]		=	0;
	TimePlayed[client]				=	0;
	PlayerUpgradesTotal[client]		=	0;
	UpgradesAvailable[client]		= MaximumPlayerUpgrades(client);
	FreeUpgrades[client]			=	0;
	if (!IsFakeClient(client)) DefaultHealth[client]			=	iSurvivorBaseHealth;
	else DefaultHealth[client]			= iSurvivorBotBaseHealth;
	//PrintToChatAll("Setting %N to %d", client, PlayerLevel[client]);
	GiveMaximumHealth(client);
	Format(ActiveSpecialAmmo[client], sizeof(ActiveSpecialAmmo[]), "none");


	//for (new i = 1; i <= MAXPLAYERS; i++) ResizeArray(PlayerAbilitiesImmune[client][i], size);
	//ResizeArray(PlayerAbilitiesImmune[client], size);

	for (new i = 0; i < size; i++) {

		/*

			We used to set defaults here, instead we set everything to 0, and just don't allow a player to insert a point if it is locked.
		*/

		//GetArrayString(a_Database_Talents_Defaults, i, text, sizeof(text));
		//Format(text, sizeof(text), "%d", StringToInt(text) - 1);
		SetArrayCell(a_Database_PlayerTalents[client], i, 0);
		SetArrayCell(a_Database_PlayerTalents_Experience[client], i, 0);
	}
	if (GetArraySize(a_Store_Player[client]) != GetArraySize(a_Store)) {

		ResizeArray(a_Store_Player[client], GetArraySize(a_Store));
	}

	for (new i = 0; i < GetArraySize(a_Store); i++) {

		SetArrayString(a_Store_Player[client], i, "0");				// We clear all players arrays for the store.
	}
	BuildMenu(client);

	Format(TagColour, sizeof(TagColour), "none");
	//Format(TagName, sizeof(TagName), "none");
	if (!IsSurvivorBot(client)) GetClientName(client, TagName, sizeof(TagName));
	else GetSurvivorBotName(client, TagName, sizeof(TagName));

	SQL_EscapeString(hDatabase, TagName, TagName, sizeof(TagName));

	Format(ChatColour, sizeof(ChatColour), "none");
	//Format(tquery, sizeof(tquery), "INSERT INTO `%s` (`steam_id`, `exp`, `expov`, `upgrade cost`, `level`, `%s`, `time played`, `talent points`, `total upgrades`, `free upgrades`, `tcolour`, `tname`, `ccolour`) VALUES ('%s', '%d', '%d', '%d', '%d', '%d', '%d', '%d', '%d', '%d', '%s', '%s', '%s');", TheDBPrefix, spmn, key, ExperienceLevel[client], ExperienceOverall[client], PlayerLevelUpgrades[client], PlayerLevel[client], SkyPoints[client], TimePlayed[client], TotalTalentPoints[client], PlayerUpgradesTotal[client], FreeUpgrades[client], TagColour, TagName, ChatColour);
	Format(tquery, sizeof(tquery), "INSERT INTO `%s` (`steam_id`) VALUES ('%s');", TheDBPrefix, key);
	//SQL_EscapeString(hDatabase, tquery, tquery, sizeof(tquery));
	SQL_TQuery(hDatabase, QuerySaveNewPlayer, tquery, client);

	CreateTimer(5.0, Timer_LoggedUsers, client, TIMER_FLAG_NO_MAPCHANGE);
}

public Query_CheckIfDataExists(Handle:owner, Handle:hndl, const String:error[], any:client) {

	if (hndl == INVALID_HANDLE) {

		LogMessage("Query_ChecKIfDataExists Error: %s", error);
		return;
	}
	decl String:key[512];
	decl String:TheName[64];
	new count	= 0;
	if (!IsLegitimateClient(client)) return;
	if (IsSurvivorBot(client)) {

		GetSurvivorBotName(client, TheName, sizeof(TheName));
		Format(key, sizeof(key), "%s%s", sBotTeam, TheName);
	}
	else {

		GetClientAuthString(client, key, sizeof(key));
	}

	new size = GetArraySize(Handle:a_Database_Talents);

	while (SQL_FetchRow(hndl)) {

		//SQL_FetchString(hndl, 0, key, sizeof(key));
		count	= SQL_FetchInt(hndl, 0);

		ResizeArray(PlayerAbilitiesCooldown[client], size);
		ResizeArray(a_Database_PlayerTalents[client], size);
		ResizeArray(a_Database_PlayerTalents_Experience[client], size);
	}
	if (count < 1) {

		if (!CheckServerLevelRequirements(client)) return;	// client was kicked.

		CreateNewPlayerEx(client);

			//decl String:DefaultProfileName[512];
			//GetConfigValue(DefaultProfileName, sizeof(DefaultProfileName), "new player profile?");
			//if (StrContains(DefaultProfileName, "-1", false) == -1) LoadProfileEx(client, DefaultProfileName);
	}
	else {

		LogMessage("%d Data rows found for %N with steamid: %s, loading player data.", count, client, key);
		//b_IsLoading[client] = false;
		ClearAndLoad(client, true);
		//if (!IsFakeClient(client)) CheckServerLevelRequirements(client);
	}
}

stock CheckGroupStatus(client) {

	decl String:pct[4];
	Format(pct, sizeof(pct), "%");

	if (IsLegitimateClient(client) && !IsFakeClient(client) && GroupMemberBonus > 0.0) {

		if (IsGroupMember[client]) PrintToChat(client, "%T", "group member bonus", client, blue, GroupMemberBonus * 100.0, pct, green, orange);
		else PrintToChat(client, "%T", "group member benefit", client, orange, blue, GroupMemberBonus * 100.0, pct, green, blue);
	}
}

stock SaveCompanionData(client, bool:DontTell = false) {

	/*if (StrEqual(ActiveCompanion[client], "none")) return;
	if (!DontTell) PrintToChat(client, "%T", "saving companion data", orange, green, ActiveCompanion[client]);

	decl String:tquery[1024];
	decl String:text[64];
	GetClientAuthString(client, text, sizeof(text));
	Format(tquery, sizeof(tquery), "SELECT COUNT(*) FROM `%s` WHERE (`companion` = '%s');", TheDBPrefix, ActiveCompanion[client]);
	SQL_TQuery(hDatabase, Query_SaveCompanionData)*/
}

public Action:Timer_LoadDelay(Handle:timer, any:client) {

	if (IsLegitimateClient(client)) {

		LoadDelay[client] = false;
	}
	return Plugin_Stop;
}

stock CreateNewPlayer(client) {

	if (hDatabase == INVALID_HANDLE) {

		LogMessage("cannot create data because the database is still loading. %N", client);
		return;
	}
	//if (LoadDelay[client]) return;	// prevent constant loading (bots, specifically.)
	//LoadDelay[client] = true;
	//CreateTimer(3.0, Timer_LoadDelay, client, TIMER_FLAG_NO_MAPCHANGE);
	decl String:tquery[1024];
	decl String:key[512];
	decl String:TheName[64];

	if (b_IsLoading[client]) return;	// should stop bots (and players) from looping indefinitely.
	b_IsLoading[client] = true;

	LogMessage("Looking up player %N in Database before creating new data.", client);
	if (IsSurvivorBot(client)) {

		GetSurvivorBotName(client, TheName, sizeof(TheName));
		Format(key, sizeof(key), "%s%s", sBotTeam, TheName);
	}
	else {

		GetClientAuthString(client, key, sizeof(key));
	}

	Format(tquery, sizeof(tquery), "SELECT COUNT(*) FROM `%s` WHERE (`steam_id` = '%s');", TheDBPrefix, key);
	SQL_TQuery(hDatabase, Query_CheckIfDataExists, tquery, client);
}

public Action:Timer_SaveCompanion(Handle:timer, any:client) {

	//new companion = MySurvivorCompanion(client);
	//SaveAndClear(companion);
	return Plugin_Stop;
}

stock SaveInfectedData(client) {

	//return;
}

stock SaveAndClear(client, bool:b_IsTrueDisconnect = false, bool:IsNewPlayer = false) {

	if (!IsLegitimateClient(client)) return;
	new bool:IsLoadingData = b_IsLoading[client];
	if (!IsLoadingData) {
		LogMessage("Loading of Talents was completed for %N", client);
		IsLoadingData = bIsTalentTwo[client];
	}

	// if the database isn't connected, we don't try to save data, because that'll just throw errors.
	// If the player didn't participate, or if they are currently saving data, we don't save as well.
	// It's possible (but not likely) for a player to try to save data while saving, due to their ability to call the function at any time through commands.
	if (hDatabase == INVALID_HANDLE) {

		LogMessage("Database couldn't be found, cannot save for %N", client);
		return;
	}
	//ClearImmunities(client);
	if (!IsLegitimateClient(client)) return;	// fuck me!!
	//if (GetClientTeam(client) == TEAM_SPECTATOR) return;
	if (GetClientTeam(client) == TEAM_INFECTED) {

		SaveInfectedData(client);
		return;
	}
	if (GetArraySize(Handle:a_Database_PlayerTalents[client]) < 1) {

		// This is probably a survivor bot, or a human player who is simply playing vanilla.
		// I thought I had checks in place to make sure they didn't get this far, but it looks like something is still getting through.
		// Oh well, now it's not.
		return;
	}
	if (b_IsTrueDisconnect) {

		RoundExperienceMultiplier[client] = 0.0;
		BonusContainer[client] = 0;

		HealImmunity[client] = false;
		b_IsLoading[client] = false;
		bIsTalentTwo[client] = false;

		resr[client] = 1;
		WipeDebuffs(_, client, true);
		bIsDisconnecting[client] = true;
	}
	else resr[client] = 0;

	b_IsDirectorTalents[client] = false;

	if (IsLoadingData) {
		LogMessage("Client is loading Data, cannot save. %N", client);
		return;
	}
	//bSaveData[client] = true;

	decl String:tquery[1024];
	decl String:key[512];
	decl String:text[512];
	//decl String:text2[512];
	new talentexperience = 0;
	new talentlevel = 0;

	PreviousRoundIncaps[client] = RoundIncaps[client];

	new size = GetArraySize(a_Database_Talents);

	decl String:thesp[64];
	decl String:TheName[64];
	//decl String:Name[64];
	GetConfigValue(thesp, sizeof(thesp), "sky points menu name?");

	if (IsSurvivorBot(client)) {

		GetSurvivorBotName(client, TheName, sizeof(TheName));
		Format(key, sizeof(key), "%s%s", sBotTeam, TheName);
	}
	else {

		GetClientAuthString(client, key, sizeof(key));
	}
	/*if (PlayerUpgradesTotal[client] == 0 && FreeUpgrades[client] == 0 && PlayerLevel[client] <= 1) {

		Format(tquery, sizeof(tquery), "DELETE FROM `%s` WHERE `steam_id` = '%s';", TheDBPrefix, key);
		SQL_TQuery(hDatabase, QueryResults, tquery, client);
		bSaveData[client] = false;
		return;
	}*/

	decl String:sPoints[64];
	Format(sPoints, sizeof(sPoints), "%3.3f", Points[client]);

	//if (PlayerLevel[client] < 1) return;		// Clearly, their data hasn't loaded, so we don't save.
	Format(tquery, sizeof(tquery), "UPDATE `%s` SET `exp` = '%d', `expov` = '%d', `upgrade cost` = '%d', `level` = '%d', `%s` = '%d', `time played` = '%d', `talent points` = '%d', `total upgrades` = '%d', `free upgrades` = '%d' WHERE (`steam_id` = '%s');", TheDBPrefix, ExperienceLevel[client], ExperienceOverall[client], PlayerLevelUpgrades[client], PlayerLevel[client], thesp, SkyPoints[client], TimePlayed[client], TotalTalentPoints[client], PlayerUpgradesTotal[client], FreeUpgrades[client], key);

	SQL_TQuery(hDatabase, QueryResults1, tquery, client);
	
	Format(tquery, sizeof(tquery), "UPDATE `%s` SET `upav` = '%d', `upawarded` = '%d', `lvlpaused` = '%d', `itrails` = '%d' WHERE (`steam_id` = '%s');", TheDBPrefix, UpgradesAvailable[client], UpgradesAwarded[client], iIsLevelingPaused[client], iIsBulletTrails[client], key);
	SQL_TQuery(hDatabase, QueryResults2, tquery, client);

	Format(tquery, sizeof(tquery), "UPDATE `%s` SET `pistol_xp` = '%d', `melee_xp` = '%d', `uzi_xp` = '%d', `shotgun_xp` = '%d', `sniper_xp` = '%d', `assault_xp` = '%d', `medic_xp` = '%d', `grenade_xp` = '%d' WHERE (`steam_id` = '%s');", TheDBPrefix, pistolXP[client], meleeXP[client], uziXP[client], shotgunXP[client], sniperXP[client], assaultXP[client], medicXP[client], grenadeXP[client], key);
	SQL_TQuery(hDatabase, QueryResults3, tquery, client);

	decl String:bonusMult[64];
	Format(bonusMult, sizeof(bonusMult), "%3.3f", RoundExperienceMultiplier[client]);

	Format(tquery, sizeof(tquery), "UPDATE `%s` SET `myseason` = '%s', `rem` = '%s' WHERE (`steam_id` = '%s');", TheDBPrefix, RatingType, bonusMult, key);
	LogMessage(tquery);
	SQL_TQuery(hDatabase, QueryResults1, tquery, client);

	SQL_EscapeString(hDatabase, Hostname, text, sizeof(text));
	Format(tquery, sizeof(tquery), "UPDATE `%s` SET `lastserver` = '%s' WHERE (`steam_id` = '%s');", TheDBPrefix, text, key);
	SQL_TQuery(hDatabase, QueryResults1, tquery, client);

	Format(tquery, sizeof(tquery), "UPDATE `%s` SET `skylevel` = '%d' WHERE (`steam_id` = '%s');", TheDBPrefix, SkyLevel[client], key);
	SQL_TQuery(hDatabase, QueryResults1, tquery, client);
	//if (!IsFakeClient(client)) LogMessage(tquery);

	if (Rating[client] > BestRating[client]) BestRating[client] = Rating[client];
	new minimumRating = RoundToCeil(BestRating[client] * fRatingFloor);
	if (Rating[client] < minimumRating) Rating[client] = minimumRating;

	Format(tquery, sizeof(tquery), "UPDATE `%s` SET `restt` = '%d', `restexp` = '%d', `lpl` = '%d', `resr` = '%d', `pri` = '%d', `survpoints` = '%s', `bec` = '%d', `%s` = '%d', `myrating %s` = '%d', `ratinghc %s` = '%d' WHERE (`steam_id` = '%s');", TheDBPrefix, GetTime(), RestedExperience[client], LastPlayLength[client], resr[client], PreviousRoundIncaps[client], sPoints, BonusContainer[client], RatingType, BestRating[client], RatingType, Rating[client], RatingType, RatingHandicap[client], key);
	SQL_TQuery(hDatabase, QueryResults4, tquery, client);

	for (new i = 0; i < size; i++) {

		TalentTreeKeys[client]			= GetArrayCell(a_Menu_Talents, i, 0);
		TalentTreeValues[client]		= GetArrayCell(a_Menu_Talents, i, 1);

		if (GetKeyValueInt(TalentTreeKeys[client], TalentTreeValues[client], "is sub menu?") == 1) continue;

		//if (GetKeyValueInt(TalentTreeKeys[client], TalentTreeValues[client], "is survivor class role?") == 1) continue;	// class roles aren't stored in the database in the same way that talents/CARTEL are.

		GetArrayString(a_Database_Talents, i, text, sizeof(text));
		talentlevel = GetArrayCell(a_Database_PlayerTalents[client], i);// GetArrayString(a_Database_PlayerTalents[client], i, text2, sizeof(text2));

		if (GetKeyValueInt(TalentTreeKeys[client], TalentTreeValues[client], "talent type?") == 1) {

			talentexperience = GetArrayCell(a_Database_PlayerTalents_Experience[client], i);
			//GetArrayString(a_Database_PlayerTalents_Experience[client], i, text3, sizeof(text3));
		
			Format(tquery, sizeof(tquery), "UPDATE `%s` SET `%s` = '%d', `%s xp` = '%d' WHERE (`steam_id` = '%s');", TheDBPrefix, text, talentlevel, text, talentexperience, key);
			SQL_TQuery(hDatabase, QueryResults5, tquery, client);
		}
		else {
			Format(tquery, sizeof(tquery), "UPDATE `%s` SET `%s` = '%d' WHERE (`steam_id` = '%s');", TheDBPrefix, text, talentlevel, key);
			LogMessage(tquery);
			SQL_TQuery(hDatabase, QueryResults6, tquery, client);
		}
	}
	new ActionSlotSize = iActionBarSlots;
	if (GetArraySize(Handle:ActionBar[client]) != ActionSlotSize) ResizeArray(Handle:ActionBar[client], ActionSlotSize);
	decl String:ActionBarText[64];
	for (new i = 0; i < ActionSlotSize; i++) {	// isnt looping?

		GetArrayString(Handle:ActionBar[client], i, ActionBarText, sizeof(ActionBarText));
		//if (StrEqual(ActionBarText, "none")) continue;
		if (!IsAbilityTalent(client, ActionBarText) && (!IsTalentExists(ActionBarText) || GetTalentStrength(client, ActionBarText) < 1)) Format(ActionBarText, sizeof(ActionBarText), "none");
		Format(tquery, sizeof(tquery), "UPDATE `%s` SET `aslot%d` = '%s' WHERE (`steam_id` = '%s');", TheDBPrefix, i+1, ActionBarText, key);
		SQL_TQuery(hDatabase, QueryResults, tquery);
	}
	new isDisab = 0;
	if (DisplayActionBar[client]) isDisab = 1;
	Format(tquery, sizeof(tquery), "UPDATE `%s` SET `disab` = '%d' WHERE (`steam_id` = '%s');", TheDBPrefix, isDisab, key);
	SQL_TQuery(hDatabase, QueryResults, tquery);

	if (GetArraySize(Handle:hWeaponList[client]) < 2) {
		ResizeArray(hWeaponList[client], 2);
		new wepid = GetPlayerWeaponSlot(client, 0);
		if (IsValidEntity(wepid)) {
			GetEntityClassname(wepid, text, sizeof(text));
			SetArrayString(hWeaponList[client], 0, text);
		}
		else Format(text, sizeof(text), "%s", defaultLoadoutWeaponPrimary);
		Format(tquery, sizeof(tquery), "UPDATE `%s` SET `primarywep` = '%s'", TheDBPrefix, text);

		GetMeleeWeapon(client, text, sizeof(text));
		if (StrEqual(text, "null")) {	// if the secondary is not a melee weapon
			wepid = GetPlayerWeaponSlot(client, 1);
			if (IsValidEntity(wepid)) GetEntityClassname(wepid, text, sizeof(text));
			else Format(text, sizeof(text), "%s", defaultLoadoutWeaponSecondary);
		}
		SetArrayString(hWeaponList[client], 1, text);
		Format(tquery, sizeof(tquery), "%s, `secondwep` = '%s' WHERE (`steam_id` = '%s');", tquery, text, key);
	}
	else {
		GetArrayString(Handle:hWeaponList[client], 0, text, sizeof(text));
		Format(tquery, sizeof(tquery), "UPDATE `%s` SET `primarywep` = '%s'", TheDBPrefix, text);

		GetArrayString(Handle:hWeaponList[client], 1, text, sizeof(text));
		Format(tquery, sizeof(tquery), "%s, `secondwep` = '%s' WHERE (`steam_id` = '%s');", tquery, text, key);
	}
	SQL_TQuery(hDatabase, QueryResults, tquery);

	/*size				=	GetArraySize(a_Store);

	for (new i = 0; i < size; i++) {

		SaveSection[client]			=	GetArrayCell(a_Store, i, 2);
		GetArrayString(Handle:SaveSection[client], 0, text, sizeof(text));
		GetArrayString(a_Store_Player[client], i, text2, sizeof(text2));
		Format(tquery, sizeof(tquery), "UPDATE `%s` SET `%s` = '%s' WHERE (`steam_id` = '%s');", TheDBPrefix, text, text2, key);
		SQL_TQuery(hDatabase, QueryResults7, tquery, client);
	}*/

	if (GetArraySize(Handle:ChatSettings[client]) != 3) {

		ResizeArray(Handle:ChatSettings[client], 3);

		Format(tquery, sizeof(tquery), "none");
		SetArrayString(Handle:ChatSettings[client], 0, tquery);
		SetArrayString(Handle:ChatSettings[client], 1, tquery);
		SetArrayString(Handle:ChatSettings[client], 2, tquery);
	}
	decl String:TagColour[64];
	decl String:TagName[64];
	decl String:ChatColour[64];
	GetArrayString(Handle:ChatSettings[client], 0, TagColour, sizeof(TagColour));
	GetArrayString(Handle:ChatSettings[client], 1, TagName, sizeof(TagName));
	GetArrayString(Handle:ChatSettings[client], 2, ChatColour, sizeof(ChatColour));

	if (StrEqual(TagName, "none")) {

		if (!IsSurvivorBot(client)) GetClientName(client, TagName, sizeof(TagName));
		else GetSurvivorBotName(client, TagName, sizeof(TagName));
	}
	SQL_EscapeString(hDatabase, TagName, TagName, sizeof(TagName));

	Format(tquery, sizeof(tquery), "UPDATE `%s` SET `tcolour` = '%s', `tname` = '%s', `ccolour` = '%s' WHERE (`steam_id` = '%s');", TheDBPrefix, TagColour, TagName, ChatColour, key);
	//SQL_EscapeString(hDatabase, tquery, tquery, sizeof(tquery));// comment this line if it breaks
	SQL_TQuery(hDatabase, QueryResults8, tquery, client);
	if (IsNewPlayer) {

		CreateTimer(5.0, Timer_LoadNewPlayer, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	//else if (StrContains(key, "BOT", false) != -1 && IsSurvivorBot(client) || StrContains(key, "BOT", false) == -1 && !IsFakeClient(client)) {

		//SaveClassData(client);
		//if (!IsSurvivorBot(client)) SaveCompanionData(client);
	//}
	//bSaveData[client] = false;
}

public Action:Timer_LoadNewPlayer(Handle:timer, any:client) {
	if (!IsLegitimateClient(client)) return Plugin_Stop;
	if (forceProfileOnNewPlayers != 1) b_IsLoading[client] = false;
	else {
		b_IsLoading[client] = true;
		LoadTarget[client] = -1;
		if (IsSurvivorBot(client) && !StrEqual(DefaultBotProfileName, "-1")) LoadProfileEx(client, DefaultBotProfileName);
		else if (GetClientTeam(client) == TEAM_INFECTED && !StrEqual(DefaultInfectedProfileName, "-1")) LoadProfileEx(client, DefaultInfectedProfileName);
		else if (GetClientTeam(client) == TEAM_SURVIVOR && !StrEqual(DefaultProfileName, "-1")) LoadProfileEx(client, DefaultProfileName);
		else b_IsLoading[client] = false;
	}
	if (b_IsLoading[client]) LogMessage("Loading profile for new player %N", client);
	return Plugin_Stop;
}

stock LoadDirectorActions() {

	if (hDatabase == INVALID_HANDLE) return;
	decl String:key[64];
	decl String:section_t[64];
	decl String:tquery[1024];
	GetConfigValue(key, sizeof(key), "director steam id?");
	LoadPos_Director = 0;

	LoadDirectorSection					=	GetArrayCell(a_DirectorActions, LoadPos_Director, 2);
	GetArrayString(Handle:LoadDirectorSection, 0, section_t, sizeof(section_t));

	//decl String:thevalue[64];
	//GetConfigValue(thevalue, sizeof(thevalue), "database prefix?");

	Format(tquery, sizeof(tquery), "SELECT `%s` FROM `%s` WHERE (`steam_id` = '%s');", section_t, TheDBPrefix, key);
	//LogMessage("Loading Director Priorities: %s", tquery);
	SQL_TQuery(hDatabase, QueryResults_LoadDirector, tquery, -1);
}

public QueryResults_LoadDirector(Handle:owner, Handle:hndl, const String:error[], any:client) {

	if (hndl != INVALID_HANDLE) {

		decl String:text[64];
		decl String:key[64];
		decl String:key_t[64];
		decl String:value_t[64];
		decl String:section_t[64];
		decl String:tquery[1024];

		new bool:NoLoad						=	false;

		GetConfigValue(key, sizeof(key), "director steam id?");
		//decl String:dbpref[64];
		//GetConfigValue(dbpref, sizeof(dbpref), "database prefix?");
		new size = 0;

		while (SQL_FetchRow(hndl)) {

			SQL_FetchString(hndl, 0, text, sizeof(text));

			if (StrEqual(text, "0")) NoLoad = true;
			if (LoadPos_Director < GetArraySize(a_DirectorActions)) {

				QueryDirectorSection						=	GetArrayCell(a_DirectorActions, LoadPos_Director, 2);
				GetArrayString(Handle:QueryDirectorSection, 0, section_t, sizeof(section_t));

				QueryDirectorKeys							=	GetArrayCell(a_DirectorActions, LoadPos_Director, 0);
				QueryDirectorValues							=	GetArrayCell(a_DirectorActions, LoadPos_Director, 1);

				size							=	GetArraySize(QueryDirectorKeys);

				for (new i = 0; i < size && !NoLoad; i++) {

					GetArrayString(Handle:QueryDirectorKeys, i, key_t, sizeof(key_t));
					GetArrayString(Handle:QueryDirectorValues, i, value_t, sizeof(value_t));

					if (StrEqual(key_t, "priority?")) {

						SetArrayString(Handle:QueryDirectorValues, i, text);
						SetArrayCell(Handle:a_DirectorActions, LoadPos_Director, QueryDirectorValues, 1);
						break;
					}
				}
				LoadPos_Director++;
				if (LoadPos_Director < GetArraySize(a_DirectorActions) && !NoLoad) {

					QueryDirectorSection						=	GetArrayCell(a_DirectorActions, LoadPos_Director, 2);
					GetArrayString(Handle:QueryDirectorSection, 0, section_t, sizeof(section_t));

					Format(tquery, sizeof(tquery), "SELECT `%s` FROM `%s` WHERE (`steam_id` = '%s');", section_t, TheDBPrefix, key);
					SQL_TQuery(hDatabase, QueryResults_LoadDirector, tquery, -1);
				}
				else if (NoLoad) FirstUserDirectorPriority();
			}
		}
	}
}

stock FirstUserDirectorPriority() {

	new size						=	GetArraySize(a_Points);

	new sizer						=	0;

	decl String:s_key[64];
	decl String:s_value[64];

	for (new i = 0; i < size; i++) {

		FirstDirectorKeys						=	GetArrayCell(a_Points, i, 0);
		FirstDirectorValues						=	GetArrayCell(a_Points, i, 1);
		FirstDirectorSection					=	GetArrayCell(a_Points, i, 2);

		new size2					=	GetArraySize(FirstDirectorKeys);
		for (new ii = 0; ii < size2; ii++) {

			GetArrayString(Handle:FirstDirectorKeys, ii, s_key, sizeof(s_key));
			GetArrayString(Handle:FirstDirectorValues, ii, s_value, sizeof(s_value));

			if (StrEqual(s_key, "model?")) PrecacheModel(s_value, false);
			else if (StrEqual(s_key, "director option?") && StrEqual(s_value, "1")) {

				sizer				=	GetArraySize(a_DirectorActions);

				ResizeArray(a_DirectorActions, sizer + 1);
				SetArrayCell(a_DirectorActions, sizer, FirstDirectorKeys, 0);
				SetArrayCell(a_DirectorActions, sizer, FirstDirectorValues, 1);
				SetArrayCell(a_DirectorActions, sizer, FirstDirectorSection, 2);

				ResizeArray(a_DirectorActions_Cooldown, sizer + 1);
				SetArrayString(a_DirectorActions_Cooldown, sizer, "0");						// 0 means not on cooldown. 1 means on cooldown. This resets every map.
			}
		}
	}
}

stock FindClientWithAuthString(String:key[], bool:MustBeExact = false) {

	decl String:AuthId[512];
	decl String:TheName[64];
	for (new i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i)) {

			if (IsSurvivorBot(i)) {

				GetSurvivorBotName(i, TheName, sizeof(TheName));
				Format(AuthId, sizeof(AuthId), "%s%s", sBotTeam, TheName);
			}
			else {

				GetClientAuthString(i, AuthId, sizeof(AuthId));
			}
			if (MustBeExact && StrEqual(key, AuthId, false) || !MustBeExact && StrContains(key, AuthId, false) != -1) return i;
		}
	}
	return -1;
}

stock bool:IsReserve(client) {

	decl String:thevalue[64];
	GetConfigValue(thevalue, sizeof(thevalue), "donator package flag?");

	if (IsGroupMember[client] || HasCommandAccess(client, thevalue)) return true;
	return false;
}

stock bool:HasCommandAccess(client, String:accessflags[]) {

	decl String:flagpos[2];

	// We loop through the access flags passed to this function to see if the player has any of them and return the result.
	// This means flexibility for anything in RPG that allows custom flags, such as reserve player access or director menu access.
	for (new i = 0; i < strlen(accessflags); i++) {

		flagpos[0] = accessflags[i];
		flagpos[1] = 0;
		if (HasCommandAccessEx(client, flagpos)) return true;
	}
	// Old Method -> if (HasCommandAccess(client, "z") || HasCommandAccess(client, "a")) return true;
	return false;
}

public LoadInventory_Generate(Handle:owner, Handle:hndl, const String:error[], any:client) {

	if (hndl != INVALID_HANDLE) {

		decl String:text[128];

		while (SQL_FetchRow(hndl)) {

			SQL_FetchString(hndl, 0, text, sizeof(text));
			PushArrayString(Handle:PlayerInventory[client], text);
			if (SQL_MoreRows(hndl)) SQL_FetchMoreResults(hndl);
		}
		LoadInventoryEx(client);
	}
}

public ReadProfiles_Generate(Handle:owner, Handle:hndl, const String:error[], any:client) {

	if (hndl != INVALID_HANDLE) {

		decl String:text[128];
		decl String:result[2][128];
		decl String:VersionNumber[64];
		Format(VersionNumber, sizeof(VersionNumber), "SavedProfile%s", PROFILE_VERSION);

		while (SQL_FetchRow(hndl)) {

			SQL_FetchString(hndl, 0, text, sizeof(text));
			ExplodeString(text, "+", result, 2, 128);
			if (strlen(result[1]) >= 8 && StrContains(text, VersionNumber, true) != -1) {

				PushArrayString(Handle:PlayerProfiles[client], text);
			}
			if (SQL_MoreRows(hndl)) SQL_FetchMoreResults(hndl);
		}
		ReadProfilesEx(client);
	}
}

public ReadProfiles_GenerateAll(Handle:owner, Handle:hndl, const String:error[], any:client) {

	if (hndl != INVALID_HANDLE) {

		decl String:text[128];
		decl String:result[2][128];
		decl String:VersionNumber[64];
		Format(VersionNumber, sizeof(VersionNumber), "SavedProfile%s", PROFILE_VERSION);

		while (SQL_FetchRow(hndl)) {

			SQL_FetchString(hndl, 0, text, sizeof(text));
			ExplodeString(text, "+", result, 2, 128);
			if (StrContains(text, "default", false) == -1 && strlen(result[1]) >= 8 && StrContains(text, VersionNumber, true) != -1) {

				PushArrayString(Handle:PlayerProfiles[client], text);
			}
			if (SQL_MoreRows(hndl)) SQL_FetchMoreResults(hndl);
		}
		ReadProfilesEx(client);
	}
}

public QueryResults_Load(Handle:owner, Handle:hndl, const String:error[], any:client)
{
	if ( hndl != INVALID_HANDLE )
	{
		decl String:key[64];
		decl String:text[64];
		//decl String:tquery[512];
		decl String:t_Hostname[64];

		decl String:CurrentSeason[64];
		new RestedTime		= 0;
		new iLevel = 0;
		//decl String:t_Class[64];

		if (!IsLegitimateClient(client)) {

			if (client > 0) b_IsLoading[client] = false;
			return;
		}

		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, key, sizeof(key));
			//client = FindClientWithAuthString(key, true);
			if (client == -1) return;

			ExperienceLevel[client]		=	SQL_FetchInt(hndl, 1);
			ExperienceOverall[client]	=	SQL_FetchInt(hndl, 2);
			PlayerLevelUpgrades[client]	=	SQL_FetchInt(hndl, 3);
			PlayerLevel[client]			=	SQL_FetchInt(hndl, 4);
			SkyLevel[client]			=	SQL_FetchInt(hndl, 5);
			SkyPoints[client]			=	SQL_FetchInt(hndl, 6);
			TimePlayed[client]			=	SQL_FetchInt(hndl, 7);
			TotalTalentPoints[client]	=	SQL_FetchInt(hndl, 8);
			PlayerUpgradesTotal[client]	=	SQL_FetchInt(hndl, 9);
			FreeUpgrades[client]		=	SQL_FetchInt(hndl, 10);
			RestedTime					=	SQL_FetchInt(hndl, 11);
			RestedExperience[client]	=	SQL_FetchInt(hndl, 12);
			LastPlayLength[client]		=	SQL_FetchInt(hndl, 13);
			resr[client]				=	SQL_FetchInt(hndl, 14);
			SQL_FetchString(hndl, 15, text, sizeof(text));
			Points[client] = StringToFloat(text);
			BonusContainer[client] = SQL_FetchInt(hndl, 16);

			SQL_FetchString(hndl, 17, text, sizeof(text));
			RoundExperienceMultiplier[client] = StringToFloat(text);

			PreviousRoundIncaps[client]	=	SQL_FetchInt(hndl, 18);
			SQL_FetchString(hndl, 19, text, sizeof(text));
			SetArrayString(Handle:ChatSettings[client], 0, text);
			SQL_FetchString(hndl, 20, text, sizeof(text));
			SetArrayString(Handle:ChatSettings[client], 1, text);
			SQL_FetchString(hndl, 21, text, sizeof(text));
			SetArrayString(Handle:ChatSettings[client], 2, text);
			ExperienceDebt[client]		=	SQL_FetchInt(hndl, 22);
			UpgradesAvailable[client]	=	SQL_FetchInt(hndl, 23);
			UpgradesAwarded[client]		=	SQL_FetchInt(hndl, 24);
			//Format(ActiveSpecialAmmo[client], sizeof(ActiveSpecialAmmo[]), "none");
			//SQL_FetchString(hndl, 25, ActiveSpecialAmmo[client], sizeof(ActiveSpecialAmmo[]));
			BestRating[client] =	SQL_FetchInt(hndl, 25);
			Rating[client] = SQL_FetchInt(hndl, 26);
			RatingHandicap[client] = SQL_FetchInt(hndl, 27);
			SQL_FetchString(hndl, 28, t_Hostname, sizeof(t_Hostname));
			// Rating is now stored individually based on each server, so we don't have to reset it when they switch between servers - it'll remember where they left off, everywhere (Handicap, too!)
			/*if (!StrEqual(Hostname, t_Hostname)) {

				// Player is on a different server from where they earned their rating.
				LogMessage("%N LAST SERVER: %s CURRENT SERVER: %s", client, t_Hostname, Hostname);
				Rating[client] = 0;
			}*/
			SQL_FetchString(hndl, 29, CurrentSeason, sizeof(CurrentSeason));
			iIsLevelingPaused[client]	= SQL_FetchInt(hndl, 30);
			iIsBulletTrails[client]		= SQL_FetchInt(hndl, 31);
			//iNoobAssistance[client]		= SQL_FetchInt(hndl, 32);

			pistolXP[client] = SQL_FetchInt(hndl, 32);
			meleeXP[client] = SQL_FetchInt(hndl, 33);
			uziXP[client] = SQL_FetchInt(hndl, 34);
			shotgunXP[client] = SQL_FetchInt(hndl, 35);
			sniperXP[client] = SQL_FetchInt(hndl, 36);
			assaultXP[client] = SQL_FetchInt(hndl, 37);
			medicXP[client] = SQL_FetchInt(hndl, 38);
			grenadeXP[client] = SQL_FetchInt(hndl, 39);
		}
		if (PlayerLevel[client] > 0) {

			if (PlayerLevel[client] >= iHardcoreMode) PrintToChat(client, "%T", "hardcore mode enabled", client, orange, green, PlayerLevel[client], orange, blue);

			if (CurrentMapPosition == 0) {

				BonusContainer[client] = 0;
				RoundExperienceMultiplier[client] = 0.0;
				Points[client] = 0.0;
				LogMessage("%N Bonus multiplier is reset.", client);
			}

			/*new Minlevel = iPlayerStartingLevel;
			if (PlayerLevel[client] < Minlevel) {

				SetTotalExperienceByLevel(client, Minlevel);
				decl String:DefaultProfileName[64];
				GetConfigValue(DefaultProfileName, sizeof(DefaultProfileName), "new player profile?");
				if (StrContains(DefaultProfileName, "-1", false) == -1) LoadProfileEx(client, DefaultProfileName);
			}*/

			/*if (ReadyUp_GetGameMode() == 3) {

				BestRating[client] = MyNewRating;
				Rating[client] = RatingLevelMultiplier;
			}
			else Rating[client] = MyNewRating;*/

			// Don't need to reset rating in this way, since Rating/BestRating is pulled uniquely from each server.
			/*if (!StrEqual(CurrentSeason, RatingType)) {

				// If the leaderboard record is from a different season, we reset.
				LogMessage("Season: %s , RatingType: %s", CurrentSeason, RatingType);
				BestRating[client] = 0;
				Rating[client] = 0;
				Format(tquery, sizeof(tquery), "UPDATE `%s` SET `%s` = '%d', `myrating` = '%d', `myseason` = '%s' WHERE (`steam_id` = '%s');", TheDBPrefix, RatingType, BestRating[client], Rating[client], RatingType, key);
				SQL_TQuery(hDatabase, QueryResults4, tquery, client);
			}*/

			if (Rating[client] < 0) Rating[client] = 0;
			if (!CheckServerLevelRequirements(client)) {

				b_IsLoading[client] = false;
				bIsTalentTwo[client] = false;
				ResetData(client);
				return;	// client was kicked.
			}
			if (!IsFakeClient(client)) AwardExperience(client, -1);

			//	"experience start?" can be modified at any time in the config.
			//	In order to properly adjust player levels, we use this to check.

			if (resr[client] == 1) {	// they're loading in after previous leaving so does not accrue for a player whose disconnect is not from leaving (re: map changes)

				if (RestedTime > 0) {

					RestedTime					=	GetTime() - RestedTime;
					if (RestedTime > LastPlayLength[client]) RestedTime = LastPlayLength[client];

					while (RestedTime >= iRestedSecondsRequired) {

						RestedTime -= iRestedSecondsRequired;
						if (IsGroupMember[client]) RestedExperience[client] += iRestedDonator;
						else RestedExperience[client] += iRestedRegular;
					}
					new RestedExperienceMaximum = iRestedMaximum;
					if (RestedExperienceMaximum < 1) RestedExperienceMaximum = CheckExperienceRequirement(client);
					if (RestedExperience[client] > RestedExperienceMaximum) {

						RestedExperience[client] = RestedExperienceMaximum;
					}
				}
				LastPlayLength[client] = 0;
				Points[client] = 0.0;
			}
			else {		// Player did not leave the match - so a map transition occurred.

				if (iFriendlyFire == 1 || IsPvP[client] != 0) {

					PrintToChat(client, "%T", "PvP Enabled", client, white, blue);
				}
				iLevel = GetPlayerLevel(client);
				if (iLevel < iPlayerStartingLevel) iLevel = iPlayerStartingLevel;
				if (PlayerLevel[client] != iLevel) SetTotalExperienceByLevel(client, iLevel);
			}
			SetSpeedMultiplierBase(client);
			LoadPos[client] = 0;
			LoadTalentTrees(client, key);
		}
		else {

			ResetData(client);
			CreateNewPlayer(client);
		}
		if (iRPGMode < 1) {
			b_IsLoading[client] = false;
			bIsTalentTwo[client] = false;
			VerifyAllActionBars(client);
		}
		//if (b_IsLoading[client] && !IsFakeClient(client)) CheckServerLevelRequirements(client);
		/*b_IsLoading[client] = false;
		bIsTalentTwo[client] = false;
		VerifyAllActionBars(client);*/
		//if (!bFound && IsLegitimateClient(client)) {
	}
	else
	{
		//decl String:err[64];
		//GetConfigValue(err, sizeof(err), "database prefix?");
		SetFailState("Error: %s PREFIX IS: %s", error, TheDBPrefix);
		return;
	}
}

/*stock bool:IsClassLoading(String:key[]) {

	decl String:text[64];
	new size = GetArraySize(a_ClassNames);
	for (new i = 0; i < size; i++) {

		GetArrayString(a_ClassNames, i, text, sizeof(text));
		if (StrContains(key, text, false) != -1) return true;
	}
	return false;
}*/

public QueryResults_LoadTalentTrees(Handle:owner, Handle:hndl, const String:error[], any:client) {

	if (hndl != INVALID_HANDLE) {

		decl String:text[512];
		decl String:tquery[1024];

		//decl String:newplay[64];
		//GetConfigValue(newplay, sizeof(newplay), "new player profile?");

		//TalentTreeKeys[client]			= GetArrayCell(a_Menu_Talents, LoadPos[client], 0);
		//TalentTreeValues[client]		= GetArrayCell(a_Menu_Talents, LoadPos[client], 1);
		new size = GetArraySize(a_Database_Talents);
		new theresult = 0;

		new talentlevel = 0;
		new talentexperience = 0;
		decl String:key[512];
		decl String:TheName[64];
		//new iLevel			= 0;

		while (SQL_FetchRow(hndl)) {

			SQL_FetchString(hndl, 0, key, sizeof(key));
			//if (!IsClassLoading(key)) client = FindClientWithAuthString(key, true);
			//else client = FindClientWithAuthString(key);
			if (client == -1 || !IsLegitimateClient(client) || IsLegitimateClient(client) && GetClientTeam(client) != TEAM_SURVIVOR && IsFakeClient(client)) {

				if (IsLegitimateClient(client)) bIsTalentTwo[client] = false;
				return;
			}
			if (IsSurvivorBot(client)) {

				GetSurvivorBotName(client, TheName, sizeof(TheName));
				Format(key, sizeof(key), "%s%s", sBotTeam, TheName);
			}
			else {

				GetClientAuthString(client, key, sizeof(key));
			}
			if (LoadPos[client] < GetArraySize(a_Database_Talents)) {

				talentlevel = SQL_FetchInt(hndl, 1);
				//if (bIsTalentTwo[client]) PrintToChat(client, "talent level %d", talentlevel);
				if (talentlevel < 0) {

					talentlevel = 0;
					if (!bIsTalentTwo[client]) talentlevel = 1;
				}
				SetArrayCell(a_Database_PlayerTalents[client], LoadPos[client], talentlevel);
				SetArrayCell(a_Database_PlayerTalents_Experience[client], LoadPos[client], 0);		// overwritten by actual value if
				if (bIsTalentTwo[client]) {

					talentexperience = SQL_FetchInt(hndl, 2);
					if (talentexperience < 0) talentexperience = 0;
					SetArrayCell(a_Database_PlayerTalents_Experience[client], LoadPos[client], talentexperience);
				}
				LoadPos[client]++;	// otherwise it'll just loop the same request

				if (bIsTalentTwo[client]) {

					while (LoadPos[client] < size) {

						TalentTreeKeys[client]			= GetArrayCell(a_Menu_Talents, LoadPos[client], 0);
						TalentTreeValues[client]		= GetArrayCell(a_Menu_Talents, LoadPos[client], 1);

						if (GetKeyValueInt(TalentTreeKeys[client], TalentTreeValues[client], "is sub menu?") == 1) {

							LoadPos[client]++;
							continue;
						}

						theresult						= GetKeyValueInt(TalentTreeKeys[client], TalentTreeValues[client], "talent type?");
						if (theresult <= 0) {

							LoadPos[client]++;
							continue;
						}
						else break;
					}
				}
				else {

					for (new i = LoadPos[client]; i < size; i++) {

						TalentTreeKeys[client]			= GetArrayCell(a_Menu_Talents, i, 0);
						TalentTreeValues[client]		= GetArrayCell(a_Menu_Talents, i, 1);

						if (GetKeyValueInt(TalentTreeKeys[client], TalentTreeValues[client], "is sub menu?") == 1) continue; //||
							//GetKeyValueInt(TalentTreeKeys[client], TalentTreeValues[client], "is survivor class role?") == 1) continue;
						LoadPos[client] = i;
						break;
					}
				}
				if (LoadPos[client] < GetArraySize(a_Database_Talents)) {

					GetArrayString(Handle:a_Database_Talents, LoadPos[client], text, sizeof(text));

					//TalentTreeKeys[client]			= GetArrayCell(a_Menu_Talents, LoadPos[client], 0);
					//TalentTreeValues[client]		= GetArrayCell(a_Menu_Talents, LoadPos[client], 1);

					if (!bIsTalentTwo[client]) Format(tquery, sizeof(tquery), "SELECT `steam_id`, `%s` FROM `%s` WHERE (`steam_id` = '%s');", text, TheDBPrefix, key);
					else Format(tquery, sizeof(tquery), "SELECT `steam_id`, `%s`, `%s xp` FROM `%s` WHERE (`steam_id` = '%s');", text, text, TheDBPrefix, key);
					SQL_TQuery(hDatabase, QueryResults_LoadTalentTrees, tquery, client);

					return;
				}
			}
		}
		b_IsLoadingTrees[client] = false;
		if (!bIsTalentTwo[client]) {

			//iLevel = GetPlayerLevel(client);
			//if (iLevel < iPlayerStartingLevel) iLevel = iPlayerStartingLevel;
			//if (PlayerLevel[client] != iLevel) SetTotalExperienceByLevel(client, iLevel);

			SetMaximumHealth(client);
			GiveMaximumHealth(client);
			LoadStoreData(client, key);
			
			LoadPos[client] = 0;
			LoadTalentTrees(client, key, true);
		}
		else {

			//IsLoadingClassData[client] = false;

			//b_IsLoadingTrees[client] = false;
			bIsTalentTwo[client] = false;

		}
		CreateTimer(1.0, Timer_LoggedUsers, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	else {
		
		SetFailState("Error: %s", error);
		return;
	}
}

stock LoadTalentTrees(client, String:key[], bool:IsTalentTwo = false, String:profilekey[] = "none") {

	//client = FindClientWithAuthString(key, true);
	if (!IsLegitimateClient(client)) return;

	b_IsLoadingTrees[client] = true;
	new size = GetArraySize(a_Menu_Talents);
	new theresult = 0;

	if (!IsTalentTwo) {

		bIsTalentTwo[client] = false;
	}
	else bIsTalentTwo[client] = true;

	decl String:text[64];
	decl String:tquery[1024];
	//decl String:key[64];
	//GetClientAuthString(client, key, sizeof(key));

	if (bIsTalentTwo[client]) {

		while (LoadPos[client] < size) {

			TalentTreeKeys[client]			= GetArrayCell(a_Menu_Talents, LoadPos[client], 0);
			TalentTreeValues[client]		= GetArrayCell(a_Menu_Talents, LoadPos[client], 1);

			if (GetKeyValueInt(TalentTreeKeys[client], TalentTreeValues[client], "is sub menu?") == 1) {

				LoadPos[client]++;
				continue;
			}
			theresult						= GetKeyValueInt(TalentTreeKeys[client], TalentTreeValues[client], "talent type?");
			if (theresult <= 0) {

				LoadPos[client]++;
				continue;
			}
			break;
		}
	}
	else {

		for (new i = LoadPos[client]; i < size; i++) {

			TalentTreeKeys[client]			= GetArrayCell(a_Menu_Talents, i, 0);
			TalentTreeValues[client]		= GetArrayCell(a_Menu_Talents, i, 1);

			if (GetKeyValueInt(TalentTreeKeys[client], TalentTreeValues[client], "is sub menu?") == 1) continue;// ||
				//GetKeyValueInt(TalentTreeKeys[client], TalentTreeValues[client], "is survivor class role?") == 1) continue;
			LoadPos[client] = i;
			break;
		}
	}

	if (LoadPos[client] < size) {

		GetArrayString(Handle:a_Database_Talents, LoadPos[client], text, sizeof(text));
		// !bIsTalentTwo[client]
		if (!IsTalentTwo) Format(tquery, sizeof(tquery), "SELECT `steam_id`, `%s` FROM `%s` WHERE (`steam_id` = '%s');", text, TheDBPrefix, key);
		else Format(tquery, sizeof(tquery), "SELECT `steam_id`, `%s`, `%s xp` FROM `%s` WHERE (`steam_id` = '%s');", text, text, TheDBPrefix, key);
		//PrintToChat(client, "FULL STOP %s", tquery);
		SQL_TQuery(hDatabase, QueryResults_LoadTalentTrees, tquery, client);
	}
	if (IsTalentTwo) {

		new ActionSlots = iActionBarSlots;
		Format(tquery, sizeof(tquery), "SELECT `steam_id`");
		for (new i = 0; i < ActionSlots; i++) {

			Format(tquery, sizeof(tquery), "%s, `aslot%d`", tquery, i+1);
		}
		Format(tquery, sizeof(tquery), "%s, `disab`, `primarywep`, `secondwep`", tquery);

		if (StrEqual(profilekey, "none")) Format(tquery, sizeof(tquery), "%s FROM `%s` WHERE (`steam_id` = '%s');", tquery, TheDBPrefix, key);
		else Format(tquery, sizeof(tquery), "%s FROM `%s` WHERE (`steam_id` = '%s');", tquery, TheDBPrefix, profilekey);
		SQL_TQuery(hDatabase, QueryResults_LoadActionBar, tquery, client);
	}
}


public QueryResults_LoadActionBar(Handle:owner, Handle:hndl, const String:error[], any:client) {

	if (hndl != INVALID_HANDLE) {

		decl String:text[512];
		decl String:key[64];
		new IsDisab = 0;
		new ActionSlots = iActionBarSlots;
		new bool:IsFound = false;

		if (client == -1 || !IsLegitimateClient(client) || IsLegitimateClient(client) && GetClientTeam(client) != TEAM_SURVIVOR && IsFakeClient(client)) return;
		if (GetArraySize(Handle:ActionBar[client]) != ActionSlots) ResizeArray(Handle:ActionBar[client], ActionSlots);

		while (SQL_FetchRow(hndl)) {

			SQL_FetchString(hndl, 0, key, sizeof(key));
			//client = FindClientWithAuthString(key);
			//if (client == -1 || IsLegitimateClient(client) && GetClientTeam(client) != TEAM_SURVIVOR && IsFakeClient(client)) return;
			for (new i = 0; i < ActionSlots; i++) {

				SQL_FetchString(hndl, i+1, text, sizeof(text));
				SetArrayString(Handle:ActionBar[client], i, text);
			}
			IsDisab = SQL_FetchInt(hndl, ActionSlots+1);
			if (IsDisab == 0) DisplayActionBar[client] = false;
			else DisplayActionBar[client] = true;

			SQL_FetchString(hndl, ActionSlots+2, text, sizeof(text));
			SetArrayString(Handle:hWeaponList[client], 0, text);
				
			SQL_FetchString(hndl, ActionSlots+3, text, sizeof(text));
			SetArrayString(Handle:hWeaponList[client], 1, text);

			GiveProfileItems(client);

			IsFound = true;
		}

		if (IsFound && !IsFakeClient(client)) PrintToChat(client, "\x04!~ Data Loaded ~!"); //PrintToChat(client, "%T", "Action Bar Loaded", client, orange, blue);
		b_IsLoading[client] = false;
		bIsTalentTwo[client] = false;
	}
	else {
		
		SetFailState("Error: %s", error);
		return;
	}
}

stock TotalPointsAssigned(client) {

	new count = 0;
	new MaxTalents = PlayerLevel[client];
	new currentValue = 0;
	//decl String:TalentName[64];

	new size = GetArraySize(a_Database_PlayerTalents[client]);
	for (new i = 0; i < size; i++) {

		TalentsAssignedKeys[client]		= GetArrayCell(a_Menu_Talents, i, 0);
		TalentsAssignedValues[client]	= GetArrayCell(a_Menu_Talents, i, 1);

		if (GetKeyValueInt(TalentsAssignedKeys[client], TalentsAssignedValues[client], "talent type?") == 1) continue;
		//if (GetKeyValueInt(TalentsAssignedKeys[client], TalentsAssignedValues[client], "is survivor class role?") == 1) continue;
		if (GetKeyValueInt(TalentsAssignedKeys[client], TalentsAssignedValues[client], "is sub menu?") == 1) continue;
		currentValue = GetArrayCell(Handle:a_Database_PlayerTalents[client], i);
		if (currentValue > 0) count += currentValue;
	}
	if (count > MaxTalents) ChallengeEverything(client);
	else return count;
	return 0;
}

stock LoadStoreData(client, String:key[]) {

	/*client = FindClientWithAuthString(key, true);
	if (!IsLegitimateClient(client)) return;

	if (GetArraySize(a_Store_Player[client]) != GetArraySize(a_Store)) ResizeArray(a_Store_Player[client], GetArraySize(a_Store));

	decl String:text[64];
	decl String:tquery[1024];

	decl String:dbpref[64];
	GetConfigValue(dbpref, sizeof(dbpref), "database prefix?");
	//decl String:key[64];
	//GetClientAuthString(client, key, sizeof(key));

	b_IsLoadingStore[client] = true;
	LoadPosStore[client] = 0;

	LoadStoreSection[client]		=	GetArrayCell(a_Store, 0, 2);
	GetArrayString(Handle:LoadStoreSection[client], 0, text, sizeof(text));
	Format(tquery, sizeof(tquery), "SELECT `steam_id`, `%s` FROM `%s` WHERE (`steam_id` = '%s');", text, dbpref, key);
	SQL_TQuery(hDatabase, QueryResults_LoadStoreData, tquery, client);*/
}

/*public QueryResults_LoadStoreData(Handle:owner, Handle:hndl, const String:error[], any:client) {

	if (hndl != INVALID_HANDLE) {

		decl String:text[512];
		decl String:tquery[1024];
		decl String:dbpref[64];
		decl String:key[64];
		GetConfigValue(dbpref, sizeof(dbpref), "database prefix?");

		while (SQL_FetchRow(hndl)) {

			SQL_FetchString(hndl, 0, key, sizeof(key));
			client = FindClientWithAuthString(key, true);
			if (!IsLegitimateClient(client)) return;

			if (LoadPosStore[client] == 0) {

				for (new i = 0; i < GetArraySize(a_Store); i++) {

					SetArrayString(a_Store_Player[client], i, "0");
				}
			}

			if (LoadPosStore[client] < GetArraySize(a_Store)) {

				SQL_FetchString(hndl, 1, text, sizeof(text));
				SetArrayString(a_Store_Player[client], LoadPosStore[client], text);

				LoadPosStore[client]++;
				if (LoadPosStore[client] < GetArraySize(a_Store)) {

					LoadStoreSection[client]		=	GetArrayCell(a_Store, LoadPosStore[client], 2);
					GetArrayString(Handle:LoadStoreSection[client], 0, text, sizeof(text));
					Format(tquery, sizeof(tquery), "SELECT `steam_id`, `%s` FROM `%s` WHERE (`steam_id` = '%s');", text, dbpref, key);
					SQL_TQuery(hDatabase, QueryResults_LoadStoreData, tquery, client);
				}
				else {

					b_IsLoadingStore[client] = false;
				}
			}
			else {

				b_IsLoadingStore[client] = false;
			}
		}
	}
	else {
		
		SetFailState("Error: %s", error);
		return;
	}
}*/

/*bool:HasIdlePlayer(client) {

	if (IsSurvivorBot(client)) {

		new SpectatorSurvivor = GetClientOfUserId(GetEntData(client, FindSendPropInfo("SurvivorBot", "m_humanSpectatorUserID"))); 
		if (IsLegitimateClient(SpectatorSurvivor)) return true;
	}
	return false;
}*/

public OnClientDisconnect(client)
{
	if (IsClientInGame(client)) {

		if (ISEXPLODE[client] != INVALID_HANDLE) {

			KillTimer(ISEXPLODE[client]);
			ISEXPLODE[client] = INVALID_HANDLE;
		}
		fOnFireDebuff[client] = 0.0;
		IsGroupMemberTime[client] = 0;

		ChangeHook(client);

		/*if (IsValidEntity(iChaseEnt[client])) {

			AcceptEntityInput(iChaseEnt[client], "Kill");
		}*/
		if(iChaseEnt[client] && EntRefToEntIndex(iChaseEnt[client]) != INVALID_ENT_REFERENCE) AcceptEntityInput(iChaseEnt[client], "Kill");
		iChaseEnt[client] = -1;
		bIsHideThreat[client] = true;
		iThreatLevel[client] = 0;
		//IsLoadingClassData[client] = false;
		bRushingNotified[client] = false;
		ClientActiveStance[client] = 0;
		ExperienceLevel[client] = 0;
		ExperienceOverall[client] = 0;
		//bIsNewClass[client] = false;
		b_IsLoadingTrees[client] = false;
		b_IsLoadingStore[client] = false;
		b_IsLoading[client] = false;
		bIsTalentTwo[client] = false;
		b_IsLoaded[client] = false;
		bIsMeleeCooldown[client] = false;
		shotgunCooldown[client] = false;
		b_IsInSaferoom[client] = false;
		b_IsArraysCreated[client] = false;
		ResetData(client);
		PlayerLevel[client] = 0;
		Rating[client] = 0;
		RatingHandicap[client] = 0;
		bIsHandicapLocked[client] = false;
		BestRating[client] = 0;
		DisplayActionBar[client] = false;
		MyBirthday[client] = 0;
		Format(ProfileLoadQueue[client], sizeof(ProfileLoadQueue[]), "none");
		//Format(ClassLoadQueue[client], sizeof(ClassLoadQueue[]), "none");
		IsGroupMember[client] = false;
		if (IsPlayerAlive(client) && eBackpack[client] > 0 && IsValidEntity(eBackpack[client])) {

			AcceptEntityInput(eBackpack[client], "Kill");
			eBackpack[client] = 0;
		}
		//ToggleTank(client, true);
	}
}

public ReadyUp_IsClientLoaded(client) {

	//ChangeHook(client, true);	// we re-hook new players to the server.
	RUP_IsClientLoaded(client);
	CheckDifficulty();
}

stock RUP_IsClientLoaded(client) {

	CreateTimer(5.0, Timer_InitializeClientLoad, client, TIMER_FLAG_NO_MAPCHANGE);
}

public Action:Timer_InitializeClientLoad(Handle:timer, any:client) {
	if (!IsLegitimateClient(client)) return Plugin_Stop;
	new Float:teleportIntoSaferoom[3];
	if (StrEqual(TheCurrentMap, "zerowarn_1r", false)) {
		teleportIntoSaferoom[0] = 4087.998291;
		teleportIntoSaferoom[1] = 11974.557617;
		teleportIntoSaferoom[2] = -300.968750;
		TeleportEntity(client, teleportIntoSaferoom, NULL_VECTOR, NULL_VECTOR);
	}
	if (b_IsLoaded[client]) return Plugin_Stop;
	//ToggleTank(client, true);
	//ChangeHook(client);
	b_IsLoaded[client] = false;
	b_IsInSaferoom[client] = true;
	bIsInCheckpoint[client] = false;
	eBackpack[client] = 0;
	ClientActiveStance[client] = 0;
	//bIsNewClass[client] = false;
	bIsNewPlayer[client] = false;
	IsPvP[client] = 0;
	b_IsLoaded[client] = false;
	b_IsLoadingTrees[client] = false;
	b_IsLoadingStore[client] = false;
	b_IsLoading[client] = false;
	bIsInCombat[client] = false;
	RatingHandicap[client] = 0;
	bIsHandicapLocked[client] = false;
	DisplayActionBar[client] = false;
	bRushingNotified[client] = false;
	MyBirthday[client] = 0;
	//IsLoadingClassData[client] = false;
	Format(ProfileLoadQueue[client], sizeof(ProfileLoadQueue[]), "none");
	//Format(ClassLoadQueue[client], sizeof(ClassLoadQueue[]), "none");
	bIsGiveProfileItems[client] = false;
	ClearArray(Handle:InfectedHealth[client]);
	ResizeArray(Handle:ActionBar[client], iActionBarSlots);
	IsClientLoadedEx(client);
	return Plugin_Stop;
}

stock IsClientLoadedEx(client) {

	/*decl String:ClientName[64];
	GetClientName(client, ClientName, sizeof(ClientName));*/
	if (GetClientTeam(client) == TEAM_INFECTED && IsFakeClient(client)) return;	// only human players.
	//LogToFile(LogPathDirectory, "%N is loaded.", client);

	/*if (!b_IsHooked[client] && GetClientTeam(client) == TEAM_SURVIVOR) {

		b_IsHooked[client] = true;
		SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	}*/
	//ChangeHook(client, true);
	OnClientLoaded(client);
}

stock OnClientLoaded(client, bool:IsHooked = false) {

	//if (!IsClientConnected(client)) return;
	if (b_IsLoaded[client]) return;
	b_IsLoaded[client] = true;
	IsGroupMemberTime[client] = 0;
	Format(ProfileLoadQueue[client], sizeof(ProfileLoadQueue[]), "none");
	/*if (!b_IsHooked[client]) {

		b_IsHooked[client] = true;
		SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	}*/
	ClearArray(ApplyDebuffCooldowns[client]);
	FreeUpgrades[client] = 0;
	bIsHideThreat[client] = true;
	iThreatLevel[client] = 0;
	iChaseEnt[client] = -1;
	MyStatusEffects[client] = 0;
	ExperienceLevel[client] = 0;
	ExperienceOverall[client] = 0;
	iIsLevelingPaused[client] = 0;
	iIsBulletTrails[client] = 0;

	RatingHandicap[client] = 0;
	Rating[client] = 0;
	BestRating[client] = 0;
	bIsDisconnecting[client] = false;
	bJetpack[client] = false;
	bEquipSpells[client] = false;
	IsPvP[client] = 0;
	//ToggleTank(client, true);

	//bIsClassAbilities[client] = false;
	LoadTarget[client] = -1;
	bIsTalentTwo[client] = false;
	//CheckGamemode();
	LoadDelay[client] = false;
	b_IsLoading[client] = false;
	b_IsLoadingStore[client] = false;
	b_IsLoadingTrees[client] = false;
	HealImmunity[client] = false;
	LastAttackedUser[client] = -1;
	if (b_IsActiveRound) b_IsInSaferoom[client] = false;
	else b_IsInSaferoom[client] = true;
	bIsSurvivorFatigue[client] = true;
	//b_ActiveThisRound[client] = false;
	PreviousRoundIncaps[client] = 1;
	Points[client] = 0.0;
	b_HasDeathLocation[client] = false;
	PlayerLevel[client] = 0;
	UpgradesAvailable[client] = 0;
	UpgradesAwarded[client] = 0;
	SurvivorStamina[client] = 0;
	SurvivorStaminaTime[client] = 0.0;
	CombatTime[client] = 0.0;
	bIsInCombat[client] = false;
	MovementSpeed[client] = 1.0;
	UseItemTime[client] = 0.0;
	AmmoTriggerCooldown[client] = false;
	ExplosionCounter[client][0] = 0.0;
	ExplosionCounter[client][1] = 0.0;
	HealingContribution[client] = 0;
	TankingContribution[client] = 0;
	DamageContribution[client] = 0;
	PointsContribution[client] = 0.0;
	HexingContribution[client] = 0;
	BuffingContribution[client] = 0;
	RespawnImmunity[client] = false;
	b_IsFloating[client] = false;
	ISDAZED[client] = 0.0;
	bIsCrushCooldown[client] = false;
	bIsBurnCooldown[client] = false;
	b_IsInSaferoom[client] = true;

	Format(ActiveSpecialAmmo[client], sizeof(ActiveSpecialAmmo[]), "none");
	if (!b_IsCheckpointDoorStartOpened) {

		bIsEligibleMapAward[client] = false;
	}
	else {

		bIsEligibleMapAward[client] = true;
	}
	CreateTimer(1.0, Timer_LoadData, client, TIMER_FLAG_NO_MAPCHANGE);

	if (!IsSurvivorBot(client)) {	// unfortunately, survivor bots triggering in this way seem to cause a server crash

		decl String:thetext[64];
		GetConfigValue(thetext, sizeof(thetext), "enter server flags?");

		if (StrContains(thetext, "-", false) == -1) {

			if (!HasCommandAccess(client, thetext)) KickClient(client, "\nYou do not have the privileges\nto access this server.\n");
		}
	}
	/*if (StrEqual(TheCurrentMap, "zerowarn_1r", false)) {
		new Float:teleportIntoSaferoom[3];
		teleportIntoSaferoom[0] = 4087.998291;
		teleportIntoSaferoom[1] = 11974.557617;
		teleportIntoSaferoom[2] = -269.968750;
		TeleportEntity(client, teleportIntoSaferoom, NULL_VECTOR, NULL_VECTOR);
	}*/
}

public Action:Timer_LoadData(Handle:timer, any:client) {

	if (IsClientInGame(client)) {

		ResetData(client);
		decl String:key[512];
		decl String:TheName[64];

		ChangeHook(client, true);

		if (IsSurvivorBot(client)) {

			GetSurvivorBotName(client, TheName, sizeof(TheName));
			Format(key, sizeof(key), "%s%s", sBotTeam, TheName);
		}
		else GetClientAuthString(client, key, sizeof(key));
		LogMessage("Client is loaded, %N of %s", client, key);

		CreateNewPlayer(client);	// it only creates a new player if one doesn't exist.
	}
	else if (IsClientConnected(client)) return Plugin_Continue;
	return Plugin_Stop;
}

public Action:Timer_LoggedUsers(Handle:timer, any:client) {

	if (!IsLegitimateClient(client)) return Plugin_Stop;
	
	//CheckGroupStatus(client);
	if (IsPlayerAlive(client) && (GetClientTeam(client) == TEAM_SURVIVOR || IsSurvivorBot(client))) {

		VerifyAllActionBars(client);	// in case they don't have the gear anymore to support it?
		//IsLogged(client, true);		// Only log them if the player isn't alive.
		return Plugin_Stop;
	}
	if (IsLogged(client)) {

		if (!IsFakeClient(client)) {

			if (ReadyUp_GetGameMode() != 3) PrintToChat(client, "%T", "rejoining too fast", client, orange);
			else PrintToChat(client, "%T", "rejoining too fast survival", client, orange);
		}
		return Plugin_Stop;
	}
	IsLogged(client, true);
	return Plugin_Stop;
}

stock bool:IsLogged(client, bool:InsertID = false) {

	decl String:SteamID[512];
	decl String:TheName[64];
	decl String:text[64];
	if (IsSurvivorBot(client)) {

		GetSurvivorBotName(client, TheName, sizeof(TheName));
		Format(SteamID, sizeof(SteamID), "%s%s", sBotTeam, TheName);
	}
	else {

		GetClientAuthString(client, SteamID, sizeof(SteamID));
	}
	//if (IsLegitimateClientAlive(client) && GetClientTeam(client) == TEAM_SURVIVOR) return true;
	if (!InsertID) {

		new size = GetArraySize(LoggedUsers);
		for (new i = 0; i < size; i++) {

			GetArrayString(LoggedUsers, i, text, sizeof(text));
			if (StrEqual(SteamID, text)) return true;
		}
		return false;
	}
	PushArrayString(LoggedUsers, SteamID);
	FindARespawnTarget(client);
	return true;
}

public Action:CMD_RespawnYumYum(client, args) {

	if (GetClientTeam(client) == TEAM_SURVIVOR && !IsPlayerAlive(client)) {

		for (new i = 1; i <= MaxClients; i++) {

			if (IsSurvivorBot(i) && IsPlayerAlive(i)) {

				IncapacitateOrKill(i, _, _, true);
				FindARespawnTarget(client, i);
				break;
			}
		}
	}
}

stock FindARespawnTarget(client, sacrifice = -1) {

	if (!IsPlayerAlive(client)) {

		SDKCall(hRoundRespawn, client);
		if (b_HasDeathLocation[client]) {

			TeleportEntity(client, Float:DeathLocation[client], NULL_VECTOR, NULL_VECTOR);
			b_HasDeathLocation[client] = false;
		}
		else {

			for (new i = 1; i <= MaxClients; i++) {

				if (!IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_SURVIVOR || i == client) continue;
				MyRespawnTarget[client] = i;
				CreateTimer(1.0, TeleportToMyTarget, client, TIMER_FLAG_NO_MAPCHANGE);
				break;
			}
		}
		if (IsLegitimateClient(sacrifice)) {

			decl String:MyName[64];
			GetClientName(client, MyName, sizeof(MyName));
			PrintToChatAll("%t", "sacrificed a bot to respawn", white, blue, MyName, orange);
		}
	}
}

public Action:TeleportToMyTarget(Handle:timer, any:client) {

	if (!IsLegitimateClientAlive(client) || !IsLegitimateClientAlive(MyRespawnTarget[client])) return Plugin_Stop;
	new Float:TeleportPos[3];
	GetClientAbsOrigin(MyRespawnTarget[client], TeleportPos);
	TeleportEntity(client, TeleportPos, NULL_VECTOR, NULL_VECTOR);

	return Plugin_Stop;
}