private ["_meleeNum","_magType","_oldUnit","_idc","_charidchanged","_charID","_weapons","_backpackWpn","_backpackMag","_currentWpn","_isWeapon","_backpackWpnTypes","_backpackWpnQtys","_countr","_model","_position","_dir","_currentAnim","_tagSetting","_playerUID","_countMags","_magazines","_primweapon","_secweapon","_newBackpackType","_muzzles","_group","_newUnit","_melee","_oldGroup"];

if (gear_done) then { disableUserInput true; };

_model 			= _this select 0;

if(count _this > 1) then {
	_charID			= _this select 1;
	_charidchanged 	= true;
} else {
	_charidchanged 	= false;
};

_position 		= [player] call FNC_GetPos;
_dir 			= getDir player;
_currentAnim 	= animationState player;
_tagSetting 	= player getVariable["DZE_display_name",false];
_playerUID 		= getPlayerUID player;
_weapons 		= weapons player;
_countMags 		= call player_countMagazines; 
_magazines 		= _countMags select 0;
_backpackMag	= [];

if ((_playerUID == dayz_playerUID) && (count _magazines == 0) && (count (magazines player) > 0 )) exitWith {cutText [(localize "str_epoch_player_17"),"PLAIN DOWN"]};

_primweapon	= primaryWeapon player;
_secweapon	= secondaryWeapon player;

if(!(_primweapon in _weapons) && _primweapon != "") then {
	_weapons set [(count _weapons),_primweapon];
};

if(!(_secweapon in _weapons) && _secweapon != "") then {
	_weapons set [(count _weapons),_secweapon];
};

//BackUp Backpack
dayz_myBackpack = unitBackpack player;
_newBackpackType = (typeOf dayz_myBackpack);
if(_newBackpackType != "") then {
	_backpackWpn = getWeaponCargo unitBackpack player;
	_backpackMag = _countMags select 1;
};

//Get Muzzle
_currentWpn = currentWeapon player;
_muzzles = getArray(configFile >> "cfgWeapons" >> _currentWpn >> "muzzles");

//Secure Player for Transformation
player SetPos dayz_spawnPos;

_oldUnit 	= player;
_oldGroup 	= group player;

/**********************************/
//DONT USE player AFTER THIS POINT//
/**********************************/

//Create New Character
_group 		= createGroup WEST;
_newUnit 	= _group createUnit [_model,dayz_spawnPos,[],0,"NONE"];

_newUnit 	SetPos _position;
_newUnit 	setDir _dir;
[_newUnit]	joinSilent createGroup WEST;
_newUnit	removeAllMPEventHandlers "MPHit";
_newUnit	addMPEventHandler ["MPHit",{_this spawn fnc_plyrHit;}];

//Clear New Character
{_newUnit removeMagazine _x;} count  magazines _newUnit;
removeAllWeapons _newUnit;	

//Equip New Charactar
{
	if (typeName _x == "ARRAY") then {if ((count _x) > 0) then {_newUnit addMagazine [(_x select 0),(_x select 1)]; }; } else { _newUnit addMagazine _x; };
} count _magazines;

{
	_newUnit addWeapon _x;
} count _weapons;

//Check && Compare it
if(str(_weapons) != str(weapons _newUnit)) then {
	//Get Differecnce
	{
		_weapons = _weapons - [_x];
	} count (weapons _newUnit);
	
	//Add the Missing
	{
		_newUnit addWeapon _x;
	} count _weapons;
};

if(_primweapon !=  (primaryWeapon _newUnit)) then {
	_newUnit addWeapon _primweapon;		
};
if (_primweapon == "MeleeCrowbar") then {
	_newUnit addMagazine 'crowbar_swing';
};
if (_primweapon == "MeleeSledge") then {
	_newUnit addMagazine 'sledge_swing';
};
if (_primweapon == "MeleeHatchet_DZE") then {
	_newUnit addMagazine 'Hatchet_Swing';
};
if (_primweapon == "MeleeMachete") then {
	_newUnit addMagazine 'Machete_swing';
};
if (_primweapon == "MeleeFishingPole") then {
	_newUnit addMagazine 'Fishing_Swing';
};

if(_secweapon != (secondaryWeapon _newUnit) && _secweapon != "") then {
	_newUnit addWeapon _secweapon;		
};

//Add && Fill BackPack
if ((!isNil "_newBackpackType") && (_newBackpackType != "")) then {

	_newUnit 		addBackpack _newBackpackType;

	//Weapons
	_backpackWpnTypes 	= [];
	_backpackWpnQtys 	= [];

	if (count _backpackWpn > 0) then {
		_backpackWpnTypes = _backpackWpn select 0;
		_backpackWpnQtys = _backpackWpn select 1;
	};
		
	addSwitchableUnit		_newUnit;
	setPlayable 			_newUnit;
	selectPlayer 			_newUnit;
	
	if(_charidchanged) then {
		player setVariable["CharacterID",_charID,true];
		player setVariable["inTransit",true,true];
	};

	if (gear_done) then {sleep 0.001;};
	["1"] call gearDialog_create;
	if (gear_done) then {sleep 0.001;};
		
	//magazines
	_countr = 0;
	{
		if ((typeName _x) != "STRING") then {
			_isWeapon = (isClass(configFile >> "CfgWeapons" >> (_x select 0)));
		} else {
			_isWeapon = (isClass(configFile >> "CfgWeapons" >> _x));
		};
		
		if (!_isWeapon) then {
			_countr = _countr + 1;
			if ((typeName _x) != "STRING") then {
				(unitBackpack player) addMagazineCargoGlobal [(_x select 0),1];
				_idc = (4999 + _countr);
				_idc setIDCAmmoCount (_x select 1);
			} else {
				(unitBackpack player) addMagazineCargoGlobal [_x,1];
			};
		};
	} count _backpackMag;
		
	(findDisplay 106) closeDisplay 0;
	
	if (gear_done) then {
		sleep 0.001;
		disableUserInput false;
	};
		
	_countr = 0;
	{
		(unitBackpack player) addWeaponCargoGlobal [_x,(_backpackWpnQtys select _countr)];
		_countr = _countr + 1;
	} count _backpackWpnTypes;
		
} else { 

	addSwitchableUnit		_newUnit;
	setPlayable 			_newUnit;
	selectPlayer 			_newUnit;
	
	if(_charidchanged) then {
		player setVariable["CharacterID",_charID,true];
		player setVariable["inTransit",true,true];
	};
	
	if (gear_done) then {
		sleep 0.001;
		disableUserInput false;
	};

};

removeSwitchableUnit _oldUnit;
removeAllWeapons _oldUnit;
{
	_oldUnit removeMagazine _x;
} count  magazines _oldUnit;
deleteVehicle _oldUnit;

if (count units _oldGroup < 1) then {
	deleteGroup _oldGroup;
};
 
if (count _muzzles > 1) then {
	player selectWeapon (_muzzles select 0);
} else {
	player selectWeapon _currentWpn;
};

[objNull,player,rSwitchMove,_currentAnim] call RE;

player disableConversation true;

if (_tagSetting) then {
	DZE_ForceNameTags = true;
};

if(_primweapon != "") then {
	_melee = (gettext (configFile >> "CfgWeapons" >> _primweapon >> "melee"));
	
	if (_melee == "true") then {		
		_magType = ([] + getArray (configFile >> "CfgWeapons" >> _primweapon >> "magazines")) select 0;
		_meleeNum = ({_x == _magType} count magazines player);
		if (_meleeNum < 1) then {
			player addMagazine _magType;
		};
		
	};
};

{
	player reveal _x;
} forEach (nearestObjects [[player] call FNC_GetPos,dayz_reveal,50]);