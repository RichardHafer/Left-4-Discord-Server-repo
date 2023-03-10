// This file contains custom driveable vehicle tables
// Examples present in this file includes new features introduced in v1.6.0
//
// Start by choosing a name for the vehicle, it's not recommended to overwrite built-in vehicle names: sedan1, sedan2, sedan3, hatchback
// 		- This name will be used with "start_driving" command
//		- From chat: !start_driving vehicle_name 
"vehicle_name":
{
	// A model path is required for the vehicle
	//		- Parented models can be used with & character seperating them, example: "models/props_vehicles/cara_69sedan.mdl&models/props_vehicles/cara_69sedan_glass.mdl"
	MDL = "models/props_vehicles/cara_69sedan.mdl"

	// If you know where to driver seat is, assign it to driver_origin key. This is the local origin of player to vehicle
	//		- If this key is not present, survivor will appear on top of the vehicle
	//driver_origin = Vector(0,0,0)

	// If you know where the driver should get out of the vehicle, assign it to getting_out_point key. This is the local origin of player to vehicle
	//		- If this key is not present, survivor will get out of the vehicle at the right most-forward side of the vehicle
	//getting_out_point = Vector(0,0,0)

	// A parameter table is required for the vehicle. This table defines how the driving will work.
	//		- All parameter names present in the table are required
	parameters =
	{
		// Velocity factor of the impulse to apply every 33ms while holding FORWARD button
		forward_push = 45.0
		// Impulse multiplier to apply to forward_push while holding WALK button
		nitrous_factor = 1.6
		// Velocity factor of the impulse to apply every 33ms while holding BACK button
		back_push = -25.0
		// Downforce multiplier to use with the current speed while holding FORWARD or BACK buttons 
		downforce = -0.1

		// Maximum velocity of the vehicle to stop pushing
		speed_max = 850.0
		// Multiplier to apply to current speed while turning
		turn_factor = 0.86
		
		// Minimum turning angle every 33ms while holding LEFT or RIGHT buttons, this value keeps going higher while turning until it is doubled.
		turn_yaw = 3.3
		// Slight pitch angle to apply while turning, helps suspension-like physics and keeping the vehicle straight
		turn_pitch = 0.1

		// Friction multiplier to apply while holding FORWARD or BACK buttons
		friction = 0.08	
		// Friction multiplier to apply while holding LEFT or RIGHT buttons with FORWARD or BACK buttons
		turn_friction = 0.2
		// Friction multiplier to apply while holding LEFT or RIGHT buttons and no acceleration
		turn_friction_nothrottle = 0.23

		// Some models have rotated models, which confuses the visible forward facing direction
		//		- You can use 4 directions via constants: 
		//			+ DRIVE_DIRECTION_STRAIGHT
		//			+ DRIVE_DIRECTION_REVERSED
		//			+ DRIVE_DIRECTION_LEFT
		//			+ DRIVE_DIRECTION_RIGHT
		//		- Or you can use QAngle(pitch,yaw,roll) angles do decide. DRIVE_DIRECTION_STRAIGHT is QAngle(0,0,0) and DRIVE_DIRECTION_LEFT is QAngle(0,90,0)
		driving_direction = DRIVE_DIRECTION_STRAIGHT
	}
} 