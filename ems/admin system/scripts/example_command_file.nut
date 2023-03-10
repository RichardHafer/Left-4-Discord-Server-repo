// All files in this directory will be read as strings and then get compiled, so be careful with the formatting!
// Follow this example's format for creating new commands and documentation for them

// If you are a beginner to Squirrel scripting language, check out: http://squirrel-lang.org/squirreldoc/
// If you don't know how to use the PS_VSLib library, check out: https://l4d2scripters.github.io/ps_vslib/docs/index.html
// !!!!!!!!!!!!!!
// MAKE SURE FILE SIZE IS LESS THAN 16.5 KB 
// !!!!!!!!!!!!!!
//
// All the global tables and methods can be accessed via these files, but it is NOT recommended to update them
// It is recommended to create 1 new command per file
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
// Steps to create a new command:
// 		1. Name the file however you like
// 		2. Include it's name in the "file_list.txt" to make the project_smok is aware of it's existance
//		3. Decide for a command name(in these steps MyCommand is used)
//		4. Decide for the minimum user level required to access the command(check user_levels.txt or user_level command for information about these levels)
//		5. Prepare the command following the example format given in this file!
//			o Initialize the table: ::PS_Scripts.MyCommand <- {}
//			o Write documentation: ::PS_Scripts.MyCommand.Help <- {}
//			o Write the actual function: ::PS_Scripts.MyCommand.Main <- function(player,args,text){}
//		6. Command is ready to use via !MyCommand, /MyCommand, ?MyCommand or scripted_user_func MyCommand
//
// ----BELOW HERE IS HOW THE SCRIPTS SHOULD BE CREATED----

// Commands should be created under PS_Scripts table

// -> Initialize a table using the name of your command
// -> If "CommandName" already exists, this will overwrite it!
::PS_Scripts.CommandName <- {}

// -> Decide the minimum user level required to call this command
::PS_Scripts.CommandName.MinimumUserLevel <- PS_USER_ADMIN

// Create some documentation for your command
// -> This information can be accessed in-game using ?CommandName in chat 
::PS_Scripts.CommandName.Help <- 
{
    docs = "Write an explanation for this command"
    param_1 = 
    {
        name = "first parameter's name"
        docs = "what is expected as an argument"
        when_null = "what happens if no argument is passed"
    }
    // ... follow this format to create documents for xth parameter param_x and so on ... 
}

// Create the function you want called when the command is called named "Main"
// This function will get 3 arguments passed to it:
//      1. Caller player as PS_VSLib.Player object
//      2. Arguments in a table with integer keys and string/null values
//      3. Text used while calling this function as string if further manipulation needed
::PS_Scripts.CommandName.Main <- function(player,args,text)
{
	// Accessing arguments easily
	local argument_1 = GetArg(1)	// This is same as args[0], but it is fail-safe, returns null if no argument is passed
	local argument_2 = GetArg(2)	// But GetArg method uses a copy of arguments stored in ::PS_VSLib.EasyLogic.LastArgs, which only gets updated when the command is called from chat/console
	local argument_3 = GetArg(3)	// If you expect the command to be called within a compilestring function, make sure to check args in here too!
	// ...

	// Do null checks if you need
	if(argument_1 == null)
		return;
	if(argument_2 == null)
		argument_2 = "default value for argument 2";

	// Write the rest of the instructions however you like!

	// At the end, print out a message for the player(s) if needed, prints to wherever the given player has his output state set to
	::Printer(player,"Put the message here!")

	// Check out some example functions in the source code: https://github.com/semihM/project_smok/blob/master/2229460523/scripts/vscripts/admin_system.nut 
} 