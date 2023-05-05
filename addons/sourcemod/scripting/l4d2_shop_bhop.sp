/****************************************************************************
 *																			*
 *							L4D2 Shop SF Auto Bunnyhop						*
 *						Author: n491 (modified by pan0s)					*
 *								Version: v1.0								*
 *																			*
 ****************************************************************************/

//SourcePawn

/*			Changelog
*	29/08/2014 Version 1.0 – Released.
*	28/12/2016 Version 1.1 – Changed syntax.
*	22/10/2017 Version 1.2 – Fixed jump after vomitjar-boost and after "TakeOverBot" event.
*	08/11/2018 Version 1.2.1 – Fixed incorrect flags initializing; some changes in syntax.
*	25/04/2019 Version 1.2.2 – Command "sm_autobhop" has fixed for localplayer in order to work properly in console.
*	16/11/2019 Version 1.3.2 – At the moment CBasePlayer specific flags (or rather FL_ONGROUND bit) aren't longer fixed, by reason
*							player's jump animation during boost is incorrect (it's must be ACT_RUN_CROUCH_* sequence always!);
*							removed 'm_nWaterLevel' check (we cannot swim in this game anyway) to avoid problems with jumping
*							on some deep water maps.
*/

 /*
										Update LOG
====================================================================================================
v1.0
	- Modified original plugin to suit l4d2_shop.sp
====================================================================================================
*/

#include <sdktools>
#include <sourcemod>
#include <adminmenu>
#pragma tabsize 0
#pragma newdecls required

// ====================================================================================================
//					pan0s | Native function call
// ====================================================================================================
#include <shop_fn>
#include <shop_cv>
#define SHOP_LIB "l4d2_shop"
bool g_isShopLoaded;
// ====================================================================================================

#define PLUGIN_VERSION "v1.0"


public Plugin myinfo =
{
	name = "[L4D2] Shop SF - Auto Bunnyhop",
	author = "noa1mbot modified by pan0s",
	description = "Allows jump easier.",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/groups/noa1mbot"
};


public void OnPluginStart()
{
	
}


// ====================================================================================================
//					pan0s | Native function call
// ====================================================================================================
public void OnPluginEnd()
{
	if(LibraryExists(SHOP_LIB) && g_isShopLoaded)
		g_isShopLoaded = false;
}
	
public void OnShopLoaded()
{
	if(LibraryExists(SHOP_LIB))
		g_isShopLoaded = true;
	else
		SetFailState("%T", "Module: Error 2", LANG_SERVER);
}

public void OnShopUnloaded()
{
	g_isShopLoaded = false;
}
// ====================================================================================================

public Action OnPlayerRunCmd(int client, int &buttons)
{
	if ( Shop_IsSFOn(client, AUTO_BHOP) && IsPlayerAlive(client))
	{
		if (buttons & IN_JUMP)
		{
			if (GetEntPropEnt(client, Prop_Send, "m_hGroundEntity") == -1)
			{
				if (GetEntityMoveType(client) != MOVETYPE_LADDER)
				{
					buttons &= ~IN_JUMP;
				}
			}
		}
	}
	return Plugin_Continue;
}