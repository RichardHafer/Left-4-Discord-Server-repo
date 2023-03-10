// This file contains commands and functions to bind to most used game keys
// Examples present in this file includes new features introduced in v1.5.0
// Keys are checked every ~33ms, meaning roughly every frame of a ~30fps game, the keys are checked if they are/were pressed.
// Available keys:
//		o MOVEMENT KEYS: 
//			+ FORWARD
//			+ BACK
//			+ LEFT
//			+ RIGHT
//			+ JUMP
//			+ DUCK
//			+ WALK
//		o COMBAT KEYS:
//			+ ATTACK
//			+ SHOVE
//			+ ZOOM
//			+ RELOAD
//		o MISCELLANEOUS KEYS:
//			+ USE
//			+ SCORE
//			+ ALT1
//			+ ALT2
// Characters // indicate the start of a comment, which are ignored while reading the file
// Binds are unique to STEAM IDs, so each admin can have their own binds
// Check out the examples below to see how it works
//
// Start by finding the admin's steam id, use user_levels.txt or check https://steamidfinder.com/ 
// You can use "all" instead of a steam ID to create the binds inside for all admins
"STEAM_1:X:XXXXXX":
{
	// Use a key name given above (FORWARD, ATTACK, USE, etc.)
	// Key names can be combined with | character
	// Combining keys will make the bind require all keys in combination to be pressed
	"KEY_NAME_HERE":
	{
		// Add "!" before the command names to bind them
		"!command_name":
		{
			// Decide how its gonna be used with "Usage" key
			//		PS_WHEN_PRESSED = Calls once everytime this button gets pressed
			//		PS_WHEN_UNPRESSED = Calls once everytime this button gets unpressed; use this with caution
			//		PS_WHILE_PRESSED = Keeps calling while this button is pressed; SKIPS the first press input to let PS_WHEN_PRESSED work
			//		PS_WHILE_UNPRESSED = Keeps calling while this button is not pressed; SKIPS the first unpress input to let PS_WHEN_UNPRESSED work
			//		0 = Disables this bind (Constants above has values 1,2,4,8 respectively)
			Usage = PS_WHEN_PRESSED

			// Pass arguments with "Arguments" key
			Arguments =
			{
				arg_1 = "argument_1"
				arg_2 = "argument_2"  
				// Follow "arg_X" format for Xth argument
			}
		}

		// If you want to create a custom function, use its name directly
		"my_function_name":
		{
			// Decide how its gonna be used with "Usage" key
			// 		o You can combine the usages with "|" operator
			Usage = PS_WHEN_PRESSED | PS_WHEN_UNPRESSED

			// Create the function which takes 2 parameters:
			//		1. player : Player's entity as PS_VSLib.Player object
			//		2. press_info: A table containing:
			//			o usage_type : Use this value to differentiate the combined "Usage" values, compare it to each usage value you used to understand which call was fired
			//			o press_time : Time() value when this button was last pressed.
			//			o unpress_time : Time() value when this button was last unpressed.
			//			o press_count: How many times this button was pressed since this bind was bound, starts from 1, increments after releasing the key
			//			o press_length: How long last pressing duration was in seconds. Until first press-unpress, it will be 0
			Function = function(player, press_info)
			{
				local usage_type = press_info.usage_type
				local press_time = press_info.press_time
				local unpress_time = press_info.unpress_time
				local count = press_info.press_count
				local duration = press_info.press_length

				// If you have combined "Usage" values, use something similar to expression below
				switch(usage_type)
				{
					case PS_WHEN_PRESSED:
						// Write instructions for "pressing" event
						break;
					case PS_WHEN_UNPRESSED:
						// Write instructions for "unpressing" event
						break;
				}

				// If you don't have combined usage values, just write the rest of the instructions here
			}
		}
	}
} 