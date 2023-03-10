// All files in this directory will be read as strings and then get compiled, so be careful with the formatting!
// Follow this example's format for hooking new functions to game events
// Check out the game event names that can be used: 
//		1. In source code (these names should be used as a hook's base): https://github.com/semihM/project_smok/blob/c3f631100a80913c6ad5f49fe74a24a772a03f40/2229460523/scripts/vscripts/admin_system/ps_vslib/easylogic.nut#L194
//		2. More detailed (these names can't be referred directly, but their representative names can be found in the link above ): https://wiki.alliedmods.net/Left_4_dead_2_events
//
// If you are a beginner to Squirrel scripting language, check out: http://squirrel-lang.org/squirreldoc/
// If you don't know how to use the PS_VSLib library, check out: https://l4d2scripters.github.io/ps_vslib/docs/index.html
// !!!!!!!!!!!!!!
// MAKE SURE FILE SIZE IS LESS THAN 16.5 KB 
// !!!!!!!!!!!!!!
//
// All the global tables and methods can be accessed via these files, but it is NOT recommended to update them
// It is recommended to create 1 game event with multiple hooks per file
//
// Some useful global tables:
//      1. ::PS_VSLib.Utils
//          o Basic common manipulation methods for all data types
//          o https://github.com/semihM/project_smok/blob/master/2229460523/scripts/vscripts/admin_system/ps_vslib/utils.nut
//
//      2. ::PS_VSLib.Timers
//          o Adding and managing timers for concurrent execution
//          o https://github.com/semihM/project_smok/blob/master/2229460523/scripts/vscripts/admin_system/ps_vslib/timer.nut
//
//      3. ::PS_VSLib.EasyLogic
//          o Easier handling of game events
//          o https://github.com/semihM/project_smok/blob/master/2229460523/scripts/vscripts/admin_system/ps_vslib/easylogic.nut
//
//      4. ::AdminSystem
//          o Managing player restrictions, storing session variables and reading/writing configuration files
//          o https://github.com/semihM/project_smok/blob/master/2229460523/scripts/vscripts/admin_system.nut
//
//      5. ::Messages
//          o Message printing methods for printing to a player's or to everybody's chat(s) or console(s)
//          o https://github.com/semihM/project_smok/blob/master/2229460523/scripts/vscripts/project_smok/messages.nut
//          o File in the link above includes most of the messages displayed by the addon, you can update them in these script files if you want, but be careful with formatting 
//
// Commonly used entity classes:
//      1. Ent
//          o Allows you to access to a game entity with given index, name or a similar reference. Same class as the game's script scope allows for entities, only has some basic methods
//          o Only used with script function of which the game presents
//          o https://github.com/semihM/project_smok/blob/c3f631100a80913c6ad5f49fe74a24a772a03f40/2229460523/scripts/vscripts/scriptedmode.nut#L467
//      2. PS_Entity
//          o Has most of the Ent class's methods and hundreds more for easier use. Can be used as the main entity reference class.
//          o Used with all the PS_VSLib methods and other custom classes, stores it's base class reference as an attribute named "_ent"
//          o https://github.com/semihM/project_smok/blob/master/2229460523/scripts/vscripts/admin_system/ps_vslib/entity.nut
//      3. PS_Player
//          o Extends Entity class, has more methods which can used for a player entity
//          o Used with all the PS_VSLib methods and other custom classes
//          o https://github.com/semihM/project_smok/blob/master/2229460523/scripts/vscripts/admin_system/ps_vslib/player.nut
//
// Steps to create a new hook for a game event:
// 		1. Name the file however you like
// 		2. Include it's name in the "file_list.txt" to make the project_smok is aware of it's existance
//		3. Write the actual hook following the example format given in this file!
//
// Example for hooking a function called VeryCoolHook to OnPlayerConnected event, which is called when a player completes connecting process to the game and takes 2 arguments:
//		1. Create a file named "my_hooks.nut"
//		2. Open up the "file_list.txt" and add "my_hooks"
//		3. Write hooks following the format below
::PS_Hooks.OnPlayerConnected.VeryCoolHook <- function(player,args)
{
	// Tell a welcome message to a connected non-admin player
	// Check admin status, in this case make sure it's quiet=true so no other message will be displayed 
	if(!AdminSystem.IsPrivileged(player,true))	
		::Messages.InformPlayer(player,"Welcome! This is a modded server and the admins are very reasonable people :) Enjoy the madness!") 
}
::PS_Hooks.OnPlayerConnected.AnotherCoolHook <- function(player,args)
{
	// Tell everyone a semi-colored message when an admin is connected
	// Check admin status, in this case make sure it's quiet=true so no other message will be displayed 
	if(AdminSystem.IsPrivileged(player,true))
		::Messages.InformAll(COLOR_ORANGE + player.GetName() + COLOR_DEFAULT + " is here to smok- some boomers!");	
} 