/****************************************************************************
 *																			*
 *							L4D2 Shop SF Laser Tag							*
 *						Author: Whosat (modified by pan0s)					*
 *								Version: v1.0								*
 *																			*
 ****************************************************************************/
 
/******************************/
/*     [L4D(2)] Laser Tag     */
/*       By KrX/ Whosat       */
/* -------------------------- */
/* Creates a laser beam from  */
/*  player to bullet impact   */
/*  point.                    */
/* -------------------------- */
/*  Version 0.2 (12 Jan 2011) */
/* -------------------------- */
/******************************/

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
#include <pan0s>

// ====================================================================================================
//					pan0s | Native function call
// ====================================================================================================
#include <shop_fn>
#include <shop_cv>
#define SHOP_LIB "l4d2_shop"
// ====================================================================================================

#define PLUGIN_VERSION "v1.0"
#define DEFAULT_FLAGS FCVAR_NOTIFY

#pragma tabsize 0
#pragma newdecls required

//Laser tag
#define WEAPONTYPE_PISTOL   6
#define WEAPONTYPE_RIFLE    5
#define WEAPONTYPE_SNIPER   4
#define WEAPONTYPE_SMG      3
#define WEAPONTYPE_SHOTGUN  2
#define WEAPONTYPE_MELEE    1
#define WEAPONTYPE_UNKNOWN  0

float g_LaserOffset;
float g_LaserWidth;
float g_LaserLife;
bool b_TagWeapon[7];
int g_LaserColor[4];
int g_Sprite;

ConVar cvar_pistols;
ConVar cvar_rifles;
ConVar cvar_snipers;
ConVar cvar_smgs;
ConVar cvar_shotguns;

ConVar cvar_laser_life;
ConVar cvar_laser_width;
ConVar cvar_laser_offset;

// ====================================================================================================

bool g_isShopLoaded;

public Plugin myinfo =
{
	name = "[L4D2] Shop SF - Laser Tag",
	author = "KrX/Whosat modified by pan0s",
	description = "Shows a laser for straight-flying fired projectiles",
	version = PLUGIN_VERSION,
	url = "http://forums.alliedmods.net/showthread.php?p=1203196"
};


public void OnPluginStart()
{
	// /*Laser Tag Convars */
	cvar_pistols 							= CreateConVar("l4d_lasertag_pistols", "1", "LaserTagging for Pistols. 0=disable, 1=enable", DEFAULT_FLAGS, true, 0.0, true, 1.0);
	cvar_rifles 							= CreateConVar("l4d_lasertag_rifles", "1", "LaserTagging for Rifles. 0=disable, 1=enable", DEFAULT_FLAGS, true, 0.0, true, 1.0);
	cvar_snipers 							= CreateConVar("l4d_lasertag_snipers", "1", "LaserTagging for Sniper Rifles. 0=disable, 1=enable", DEFAULT_FLAGS, true, 0.0, true, 1.0);
	cvar_smgs 								= CreateConVar("l4d_lasertag_smgs", "1", "LaserTagging for SMGs. 0=disable, 1=enable", DEFAULT_FLAGS, true, 0.0, true, 1.0);
	cvar_shotguns 							= CreateConVar("l4d_lasertag_shotguns", "1", "LaserTagging for Shotguns. 0=disable, 1=enable", DEFAULT_FLAGS, true, 0.0, true, 1.0);

	cvar_laser_life 						= CreateConVar("l4d_lasertag_life", "0.8", "Seconds Laser will remain", DEFAULT_FLAGS, true, 0.1);
	cvar_laser_width 						= CreateConVar("l4d_lasertag_width", "1.0", "Width of Laser", DEFAULT_FLAGS, true, 1.0);
	cvar_laser_offset 						= CreateConVar("l4d_lasertag_offset", "36", "Lasertag Offset", DEFAULT_FLAGS);

	HookEvent("bullet_impact", Event_BulletImpact);

	// ConVars that change whether the plugin is enabled
	HookConVarChange(cvar_pistols, CheckWeapons);
	HookConVarChange(cvar_rifles, CheckWeapons);
	HookConVarChange(cvar_snipers, CheckWeapons);
	HookConVarChange(cvar_smgs, CheckWeapons);
	HookConVarChange(cvar_shotguns, CheckWeapons);

	HookConVarChange(cvar_laser_life, UselessHooker);
	HookConVarChange(cvar_laser_width, UselessHooker);
	HookConVarChange(cvar_laser_offset, UselessHooker);

	/* Config Creation*/
	AutoExecConfig(true,"l4d2_shop_lasertag");
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


// |------------------------------ Laser tag ------------------------------|
public void UselessHooker(Handle convar, const char[] oldValue, const char[] newValue)
{
	OnConfigsExecuted();
}

public void OnConfigsExecuted()
{
	CheckWeapons(INVALID_HANDLE, "", "");

	g_LaserLife = GetConVarFloat(cvar_laser_life);
	g_LaserWidth = GetConVarFloat(cvar_laser_width);
	g_LaserOffset = GetConVarFloat(cvar_laser_offset);
}

public void CheckWeapons(Handle convar, const char[] oldValue, const char[] newValue)
{
	b_TagWeapon[WEAPONTYPE_PISTOL] = GetConVarBool(cvar_pistols);
	b_TagWeapon[WEAPONTYPE_RIFLE] = GetConVarBool(cvar_rifles);
	b_TagWeapon[WEAPONTYPE_SNIPER] = GetConVarBool(cvar_snipers);
	b_TagWeapon[WEAPONTYPE_SMG] = GetConVarBool(cvar_smgs);
	b_TagWeapon[WEAPONTYPE_SHOTGUN] = GetConVarBool(cvar_shotguns);
}

public int GetWeaponType(int userid)
{
	// Get current weapon
	char weapon[32];
	GetClientWeapon(userid, weapon, 32);

	if(StrEqual(weapon, "weapon_hunting_rifle") || StrContains(weapon, "sniper") >= 0) return WEAPONTYPE_SNIPER;
	if(StrContains(weapon, "weapon_rifle") >= 0) return WEAPONTYPE_RIFLE;
	if(StrContains(weapon, "pistol") >= 0) return WEAPONTYPE_PISTOL;
	if(StrContains(weapon, "smg") >= 0) return WEAPONTYPE_SMG;
	if(StrContains(weapon, "shotgun") >=0) return WEAPONTYPE_SHOTGUN;

	return WEAPONTYPE_UNKNOWN;
}

public Action Event_BulletImpact(Handle event, const char[] name, bool dontBroadcast)
{
	// Get Shooter's Userid
	int client = GetClientOfUserId(GetEventInt(event, "userid"));

	int colorIndex = Shop_GetEanbledAmmoColorIndex(client);
	if(colorIndex == -1 || !Shop_IsSFOn(client, colorIndex)) return Plugin_Continue;

	// Check if is Survivor
 	if(!IsSurvivor(client)) return Plugin_Continue;
	// Check if is Bot and enabled
	// int bot = 0;
	// if(IsFakeClient(client)) { if(!g_Bots) return Plugin_Continue; bot = 1; }

	// Check if the weapon is an enabled weapon type to tag
	if(b_TagWeapon[GetWeaponType(client)])
	{
		// Bullet impact location
		float x = GetEventFloat(event, "x");
		float y = GetEventFloat(event, "y");
		float z = GetEventFloat(event, "z");

		float startPos[3];
		startPos[0] = x;
		startPos[1] = y;
		startPos[2] = z;

		/*float bulletPos[3];
		bulletPos[0] = x;
		bulletPos[1] = y;
		bulletPos[2] = z;*/

		float bulletPos[3];
		bulletPos = startPos;

		// Current player's EYE position
		float playerPos[3];
		GetClientEyePosition(client, playerPos);

		float lineVector[3];
		SubtractVectors(playerPos, startPos, lineVector);
		NormalizeVector(lineVector, lineVector);

		// Offset
		ScaleVector(lineVector, g_LaserOffset);
		// Find starting point to draw line from
		SubtractVectors(playerPos, lineVector, startPos);

		switch(colorIndex)
		{
			case GRAY_AMMO:
			{
				g_LaserColor[0] = 108;//red
				g_LaserColor[1] = 108;//greem
				g_LaserColor[2] = 108;//blue
				g_LaserColor[3] = 20; // alpha
			}
			case RED_AMMO:
			{
				g_LaserColor[0] = 214;//red
				g_LaserColor[1] = 31;//greem
				g_LaserColor[2] = 31;//blue
				g_LaserColor[3] = 40; // alpha
			}
			case GOLD_AMMO:
			{
				g_LaserColor[0] = 255;//red
				g_LaserColor[1] = 234;//greem
				g_LaserColor[2] = 0;//blue
				g_LaserColor[3] = 40; // alpha
			}
			case BLUE_AMMO:
			{
				g_LaserColor[0] = 0;//red
				g_LaserColor[1] = 168;//greem
				g_LaserColor[2] = 255;//blue
				g_LaserColor[3] = 40; // alpha
			}
			case GREEN_AMMO:
			{
				g_LaserColor[0] = 101;//red
				g_LaserColor[1] = 244;//greem
				g_LaserColor[2] = 68;//blue
				g_LaserColor[3] = 40; // alpha
			}
		}

		// char text[255];
		// Format(text, sizeof(text), "Color: %d / %d", colorIndex, GRAY_AMMO);

		// Draw the line
		TE_SetupBeamPoints(startPos, bulletPos, g_Sprite, 0, 0, 0, g_LaserLife, g_LaserWidth, g_LaserWidth, 1, 0.0, g_LaserColor, 0);


		TE_SendToAll();
	}

 	return Plugin_Continue;
}

public void OnMapStart()
{
	// Laser tag
	g_Sprite = PrecacheModel("materials/sprites/laserbeam.vmt");
}