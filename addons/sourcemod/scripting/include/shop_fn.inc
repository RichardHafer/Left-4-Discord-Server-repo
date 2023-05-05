/**************************************************************************
 *                                                                        *
 *                 		    Shop System Native							  *
 *                            Author: pan0s                               *
 *                            Version: v1.3                               *
 *                                                                        *
 **************************************************************************/

#if defined l4d2_shop
 #endinput
#endif
#define l4d2_shop

/**
 * Gets the version of Shop
 * @param buffer		string buffer
 * @return				current version of rank system in form of a float
 */
native int Shop_GetVersion(char[] buffer);

/**
 *  Get client points
 *
 * @param client			client index
 * @return					client points
 */
native int Shop_GetPoints(int client);

/**
 * Buy item
 *
 * @param client			client index
 * @param buffer			item name
 * @param price				item price
 * @param team				team (default: survivor)
 * @return					true if buying item is successful
 */
native bool Shop_BuyItem(int client, char[] buffer, int price, int team = 2);

/**
 *  Upgrade Weapon
 *
 * @param client			client index
 * @param buffer			item name
 * @param price				item price
 * @return					true if buying item is successful
 */
native bool Shop_UpgradeWeapon(int client, char[] buffer, int price);

/**
 *  Upgrade Weapon
 *
 * @param client			client index
 * @param index				SF index
 * @param price				SF price
 * @param isPermanent		is Permanent
 * @return					true if buying is successful
 */
native bool Shop_BuySF(int client, int index, int price, bool isPermanent);

/**
 *  Check is sf on
 *
 * @param client			client index
 * @param index				SF index
 * @return					true if sf is on
 */
native bool Shop_IsSFOn(int client, int index);

/**
 * Get SF Index by function no.
 *
 * @param functionNo		functionNo (string)
 * @return					index of functionNo
 */
native int Shop_GetFunctionIndex(char[] functionNo);

/**
 *  Check is sf on
 *
 * @param client			client index
 * @param index				SF index
 * @param isPermanent		isPermanent (default: false)
 * @return					true if sf is on
 */
native bool Shop_GetClientSFOn(int client, int index, bool isPermanent = false);

/**
 * Get Eanbled Ammo Color Index 
 *
 * @param client			client index
 * @return					-1 if not found
 */
native int Shop_GetEanbledAmmoColorIndex(int client);

/**
 * Buy function (reduce points)
 *
 * @param client			client index
 * @param item				item name
 * @param price				item price
 * @param bPrint			print purchase is successful?
 * @return					true if reduciing point is successful
 */
native bool Shop_Checkout(const int client, const char[] item, const int price, bool bPrint = true);


/**
 *  Check Shop is off
 *
 * @param client			client index
 * @param shopId			shopId (refer to shop_cv)
 * @return					true if shop is off
 */
native bool Shop_IsShopOff(int client, int shopId);

/**
 * Call an agent to help you buy somethings
 *
 * @param client			client index
 * @param shopId			shopId (refer to shop_cv)
 * @param itemId			itemId (refer to shop_cv)
 * @return					0
 */
native int Shop_CallAgent(int client, int shopId, int itemId);

/**
 * Set SF (round) on/off
 *
 * @param client			client index
 * @param sfId				sf id
 * @param bOn				itemId (refer to shop_cv)
 * @return					0
 */
native int Shop_SetSFOn(int client, int sfId, bool bOn = true);

/**
 * Set first sfid on and set second sfid to false
 *
 * @param client			client index
 * @param sfIds				sfIds
 * @param bSave				Will save to DB?
 * @return					0
 */
native int Shop_SetSFOffWhenSFOn(int client, int[] sfIds, bool bSave = false);

/**
 * Add points to client
 *
 * @param client			client index
 * @param points			amouint of points
 * @param bSave				Will save to DB?
 * @return					0
 */
native int Shop_AddPoints(int client, int points, bool bSave = false);

/**
 * Reduce points to client
 *
 * @param client			client index
 * @param point				sfIds
 * @param bSave				Will save to DB?
 * @return					0
 */
native int Shop_ReducePoints(int client, int points, bool bSave = false);

/**
 * Set client points
 *
 * @param client			client index
 * @param point				sfIds
 * @param bSave				Will save to DB?
 * @return					0
 */
native int Shop_SetPoints(int client, int points, bool bSave = false);
////
//
/**
* Registers a module for points system
*
* @param modulename	String that contains the module to be registered's name
* @return			false if successful true if already registered, true should never happen.
*/
native bool Shop_RegisterModule(const char[] modulename);

/**
* Unregisters a module for points system
*
* @param modulename	String that contains the module to be unregistered's name
* @return			none
*/
native void Shop_UnregisterModule(const char[] modulename);

/**
* Called when Points System is loaded
*
* @return			none
*/
forward void OnShopLoaded();

/**
* Called when Points System is unloaded
*
* @return			none
*/
forward void OnShopUnloaded();

public SharedPlugin L4D2_SHOP = 
{
	name = "l4d2_shop_native",
	file = "l4d2_shop.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};