/**************************************************************************
 *                                                                        *
 *                L4D2 Statistaic And Ranking System (SRS) 		     	  *
 *                            Author: pan0s                               *
 *                            Version: v1.0                               *
 *                                                                        *
 **************************************************************************/

 /*
										Update LOG
====================================================================================================
v1.0
	- Initial project
====================================================================================================
*/

#include <sdktools>
#include <sourcemod>
#include <adminmenu>
#include <pan0s>
#include <srs_fn>
#include <srs_cv>

#define PLUGIN_VERSION "v1.0"
#define SRS_LIB "l4d2_srs"

#pragma tabsize 0
#pragma newdecls required

bool g_isSRSLoaded;

public Plugin Info =
{
	name = "L4D2 Statistaic And Ranking System using Native functions",
	description = "Record almost all l4d2 game data, and make a rank system.",
	author = "pan0s",
	version = PLUGIN_VERSION,
	url = ""
};


public void OnPluginStart()
{

	RegConsoleCmd("sm_mvp", HandleCmdTestSRS);
	RegConsoleCmd("sm_srs", HandleCmdTestSRS);

	char gameName[64];
	GetGameFolderName(gameName, sizeof(gameName));
	if (!StrEqual(gameName, "left4dead2", false))
	{
		SetFailState("Plugin supports Left 4 Dead 2 only.");
	}
}

public void OnPluginEnd()
{
	if(LibraryExists(SRS_LIB) && g_isSRSLoaded)
		g_isSRSLoaded = false;
}
	
public void OnSRSLoaded()
{
	if(LibraryExists(SRS_LIB))
		g_isSRSLoaded = true;
	else
		SetFailState("%T", "Module: Error 2", LANG_SERVER);
}

public void OnSRSUnloaded()
{
	g_isSRSLoaded = false;
}


public Action HandleCmdTestSRS(int client, int args) 
{
	int clients[4];
	float scores[4];
	SRS_GetMvp(clients, scores);
	CPrintToChat(client, "Test SRS");
	for(int i=0; i<4; i++)
	{
		if(IsValidClient(client))
			CPrintToChat(client, "%d: {BLUE}%N{DEFAULT} Score - {GREEN}%.1f{DEFAULT} points.", i+1, clients[i], scores[i]);
	}
	return Plugin_Handled;
}