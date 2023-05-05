/****************************************************************************
 *																			*
 *							L4D2 Shop SF China Qing Gong					*
 *						Author: n491 (modified by pan0s)					*
 *								Version: v1.0								*
 *																			*
 ****************************************************************************/


#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION "v1.0"
#pragma tabsize 0
#pragma newdecls required

float g_fJumpTime[MAXPLAYERS+1];
bool g_bJumpEnabled[MAXPLAYERS+1];
bool g_bJumped[MAXPLAYERS+1];
int g_iLastButton[MAXPLAYERS+1];
int g_iVelocity;

int g_iCountJump[MAXPLAYERS+1];

ConVar g_cvInitEnabled, g_cvXymult, g_cvZmult, g_cvDamage, g_cvXymult2, g_cvZmult2, g_cvDamage2, g_cvTick, g_cvJunpLimit;
 

public Plugin myinfo = 
{
	name = "[L4D2] Shop SF - China Qing Gong",
	author = "pan xiaohai modified by pan0s",
	description = "China Qing Gong",
	url = "https://forums.alliedmods.net/showthread.php?p=1118287",
	version = PLUGIN_VERSION,
}

// ====================================================================================================
//					pan0s | Native function call
// ====================================================================================================
#include <shop_fn>
#include <shop_cv>
#include <pan0s>
#define SHOP_LIB "l4d2_shop"
bool g_isShopLoaded;

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


public void OnPluginStart()
{
	LoadTranslations("l4d2_shop.phrases");
	CreateConVar("l4d_jump_version", PLUGIN_VERSION, "   ", FCVAR_NOTIFY);
	
	// g_cvEnabled = CreateConVar("l4d_jump_enabled", "1", " 1 : China Qing Gong enable , 0: China Qing Gong disable ", FCVAR_NOTIFY);
	g_cvInitEnabled = CreateConVar("l4d_jump_init", "1", " 1 : enable for everyone, 0: enable by say !qg ", FCVAR_NOTIFY);

	g_cvZmult = CreateConVar("l4d_jump_zmult", "2.2", "Vertical Acceleration", FCVAR_NOTIFY);
	g_cvZmult2 = CreateConVar("l4d_jump_zmult2", "4.0", "supper Qing Gong Vertical Acceleration", FCVAR_NOTIFY);

	g_cvXymult = CreateConVar("l4d_jump_xymult", "2.5", "Horizontal Acceleration", FCVAR_NOTIFY);
	g_cvXymult2 = CreateConVar("l4d_jump_xymult2", "4.0", "supper Qing Gong Horizontal Acceleration", FCVAR_NOTIFY);

	g_cvDamage = CreateConVar("l4d_jump_damage", "0", "how many health lost when use supper Qing Gong", FCVAR_NOTIFY);
	g_cvDamage2 = CreateConVar("l4d_jump_damage2", "0", "how many health lost when supper use Qing Gong", FCVAR_NOTIFY);

	g_cvDamage2 = CreateConVar("l4d_jump_damage2", "0", "how many health lost when supper use Qing Gong", FCVAR_NOTIFY);
	g_cvDamage2 = CreateConVar("l4d_jump_damage2", "0", "how many health lost when supper use Qing Gong", FCVAR_NOTIFY);

	g_cvJunpLimit = CreateConVar("l4d_jump_limit", "50", "Count limit for supper Qing Gong and Qing Gong for each round.", FCVAR_NOTIFY);
	

	g_cvTick = CreateConVar("l4d_jump_tick", "0.2", "use difficulty more small more difficult ", FCVAR_NOTIFY);
	// g_cvMsgTime = CreateConVar("l4d_jump_showtime", "0", "message time", FCVAR_NOTIFY);
 	
	AutoExecConfig(true, "l4d2_shop_jump");
	
	g_iVelocity = FindSendPropInfo("CBasePlayer", "m_vecVelocity[0]");
    	
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("mission_lost", Event_RoundEnd);
	HookEvent("finale_win", Event_RoundEnd);
 	
	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_jump", Event_PlayerJump);
 	//RegConsoleCmd("sm_qg", Cmd_Drop);
	reset();
}
public Action Msg(Handle timer, any data)
{
	PrintToChatAll("\x05[Qing Gong]\x01say \x03 !qg or !qinggong \x01 to learn Qing Gong");
 	return Plugin_Continue;
}
// public Action Cmd_Drop(int client, int args)
// {
// 	if (client == 0 || GetClientTeam(client) != 2 || !IsPlayerAlive(client))
// 		return Plugin_Handled;
// 	g_bJumpEnabled[client]=!g_bJumpEnabled[client];
// 	if(	g_bJumpEnabled[client])
// 	{
// 		PrintToChat(client, "\x05[Qing Gong]\x03You have learned Qing Gong, use it by press jump twice quickly( you can hold duck at the same time");
// 	}
// 	else
// 	{
// 		PrintToChat(client, "\x05[Qing Gong]\x03You have forgetted Qing Gong");
// 	}

//   	return Plugin_Handled;
// }
public Action Event_PlayerJump(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (!client) return Plugin_Continue;
	if (!IsClientInGame(client)) return Plugin_Continue;
	if (!IsPlayerAlive(client)) return Plugin_Continue;
	g_iLastButton[client] = GetClientButtons(client);
	g_fJumpTime[client] = GetEngineTime();
	g_bJumped[client] = true;

	return Plugin_Continue;
}

// public Action OnPlayerRunCmd(int client, int& buttons, int& impuls, float vel[3], float angles[3], int& weapon)
// {
// 	float time = GetEngineTime();
// 	CPrintToChat(client, "%d", impuls)
// 	if(impuls == 100)
// 	{
// 		if(time - g_fPressTime[client]<0.3)
// 			FakeClientCommand(client, "sm_light");	 
// 		g_fPressTime[client] = time;
// 	}
// 	return Plugin_Continue;
// }

public Action OnPlayerRunCmd(int client, int &button)
{

	float time=GetEngineTime();
	float tick=GetConVarFloat(g_cvTick);
	if (g_bJumpEnabled[client] && g_bJumped[client] && IsClientInGame(client) && GetClientTeam(client)==2 && IsPlayerAlive(client))
	{
		if(g_iCountJump[client] >= g_cvJunpLimit.IntValue || !Shop_IsSFOn(client, QING_GONG)) return Plugin_Continue;
		
		if(Shop_IsSFOn(client, AUTO_BHOP))
		{
			int ids[] = {QING_GONG, AUTO_BHOP};
			Shop_SetSFOffWhenSFOn(client, ids);
			Shop_SetSFOn(client, AUTO_BHOP, false);
			return Plugin_Continue;
		}

		if(g_fJumpTime[client]>=time+tick)
		{	 
			g_bJumped[client]=false;
			return Plugin_Continue;
		}
		int buttons = GetClientButtons(client);
		int suppermode=false;
 		if( (buttons & IN_JUMP) && !(g_iLastButton[client] & IN_JUMP) )
		{
			if  ((buttons & IN_DUCK) || (buttons & IN_USE))
			{
				suppermode=true;
			}
 			if(g_fJumpTime[client]<time)
			{
				float velocity[3];
				GetEntDataVector(client, g_iVelocity, velocity);
				if(velocity[2]<0.0)
				{
					g_bJumped[client]=false;
					return Plugin_Continue;
				}
					
				float zmult = g_cvZmult.FloatValue;
				float xymult = g_cvXymult.FloatValue;
				float zmult2 = g_cvZmult2.FloatValue;
				float xymult2 = g_cvXymult2.FloatValue;
				int damage = g_cvDamage.IntValue;
				int damage2 = g_cvDamage2.IntValue;

				char sdemage[10];
				Format(sdemage, sizeof(sdemage),  "%i", damage);
				char sdemage2[10];
				Format(sdemage2, sizeof(sdemage2),  "%i", damage2); 


				if  (suppermode)
				{
					velocity[0]=velocity[0]*xymult2;
					velocity[1]=velocity[1]*xymult2;
					velocity[2]=velocity[2]*zmult2;
				}
				else
				{
					velocity[0]=velocity[0]*xymult;
					velocity[1]=velocity[1]*xymult;
					velocity[2]=velocity[2]*zmult;
				}
				TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
				SetEntDataVector(client, g_iVelocity, velocity);
				g_bJumped[client]=false;
				 
				if(damage>0)
				{
					if(suppermode)DamageEffect(client, sdemage2);
					else DamageEffect(client, sdemage);
				}
				g_iCountJump[client]++;
				PrintHintText(client, "%T: %d / %d", suppermode? "SUPER_QING_GONG_ACTIVE": "QING_GONG_ACTIVE", client, g_iCountJump[client], g_cvJunpLimit.IntValue);
			}
 		}
		g_iLastButton[client]=buttons;
	}
	return Plugin_Continue;
}

stock void DamageEffect(int target, char[] demage)
{
	int pointHurt = CreateEntityByName("point_hurt");			// Create point_hurt
	DispatchKeyValue(target, "targetname", "hurtme");			// mark target
	DispatchKeyValue(pointHurt, "Damage", demage);					// No Damage, just HUD display. Does stop Reviving though
	DispatchKeyValue(pointHurt, "DamageTarget", "hurtme");		// Target Assignment
	DispatchKeyValue(pointHurt, "DamageType", "65536");			// Type of damage
	DispatchSpawn(pointHurt);									// Spawn descriped point_hurt
	AcceptEntityInput(pointHurt, "Hurt"); 						// Trigger point_hurt execute
	AcceptEntityInput(pointHurt, "Kill"); 						// Remove point_hurt
	DispatchKeyValue(target, "targetname",	"cake");			// Clear target's mark
}
 

public Action Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{

	reset();
	return Plugin_Continue;
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	reset();
	return Plugin_Continue;
}

public void reset()
{
	bool e=GetConVarInt(g_cvInitEnabled)>0;
	for (int x = 1; x <=MAXPLAYERS ; x++)
	{
 		g_bJumpEnabled[x] = e;
 		g_iCountJump[x] = 0;
	}
}