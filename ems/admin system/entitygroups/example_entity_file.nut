// This file contains entity group tables to be registered in the games
// Examples present in this file includes new features introduced in v1.4.0
//
// These entity groups are used with the "prop" command.
//		- Example(from chat): Spawn the ExampleGnome present in this file
//			!prop >ExampleGnome
//
// For more examples, download L4D2 Authoring Tools and check out the directory: "Left 4 Dead 2\sdk_content\scripting\scripts\vscripts\entitygroups"
// If you wish to use those examples:
//		1. Remove the line with the "RegisterEntityGroup" function call, this call is done internally later.
//		2. Replace "<-" with "=" after the entity group name	
//
// Characters // indicate the start of a comment, which are ignored while reading the file
// !!!!!!!
// >>> FILE SIZE SHOULD NOT EXCEED 16.5 KB, OR FILE WILL NOT BE READ
// !!!!!!!
// If the file size is bigger than 16.5 KB:
// 		1. Create a new file named however you like
//		2. Add the file name to "file_list.txt" to make sure project_smok knows it exists

// The name declared here will be used with the commands
ExampleGnome =
{
	//-------------------------------------------------------
	// Required Interface functions
	// - These following functions are REQUIRED to register an entity group
	//-------------------------------------------------------
	// - Add references of entities which has a model in this
	function GetPrecacheList()
	{
		local precacheModels =
		[
			EntityGroup.SpawnTables.gnome,
		]
		return precacheModels
	}

	//-------------------------------------------------------
	// - Add references of entities here to spawn them 
	function GetSpawnList()
	{
		local spawnEnts =
		[
			EntityGroup.SpawnTables.gnome,
		]
		return spawnEnts
	}

	//-------------------------------------------------------
	// - Don't change this, although make sure it exists
	function GetEntityGroup()
	{
		return EntityGroup
	}

	//-------------------------------------------------------
	// Table of entities that make up this group
	//-------------------------------------------------------
	EntityGroup =
	{
		// Entities to spawn
		SpawnTables =
		{
			// Name of the this entity's table, refer to this on the functions above
			// "targetname" is used to name the spawned entity
			gnome = 
			{
				// Key value pairs for this entity
				SpawnInfo =
				{
					classname = "$classname"
					angles = QAngle( 0, 180, 0 )
					glowcolor = "56 150 58"
					glowrange = "0"
					glowrangemin = "0"
					glowstate = "3"
					massScale = "5"
					model = "models/props_junk/gnome.mdl"
					spawnflags = "0"
					targetname = "$targetname"	// Keep the replacing parameter named same(especially for targetname)!
					origin = Vector( -6, 8, 11 )
				}
			}
		} // SpawnTables
		// Add a table named ReplaceParmDefaults to change values in key-value pairs
		// Use $[expression] format to evaluate expressions for every single spawn call
		//  - If $[expression] is used in an entity group, it will require SCRIPT AUTHORIZATION for players to use this entity group
		//	- With the $[expression] format, you can access to some external variables:
		//		1. To get the command caller player as PS_VSLib.Player use "player" variable
		//		2. To get the table of arguments used with the command use "GetArg(idx)" for idx'th argument
		ReplaceParmDefaults =
		{
			"$classname" : "prop_physics_multiplayer"
			// By default, any parameter name starting with "$targetname" is taken as a targetname while printing messages, so be reasonable while naming the parameters!
			"$targetname" : "$[\"gnome_spawned_by_\"+player.GetCharacterNameLower()]"	
		}
	} // EntityGroup
} // ExampleGnome 