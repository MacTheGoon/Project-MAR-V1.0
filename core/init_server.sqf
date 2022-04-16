[] call compileScript ["core\fnc\city\init.sqf"];

["Initialize"] call BIS_fnc_dynamicGroups;
setTimeMultiplier btc_p_acctime;

["btc_m", -1, objNull, "", false, false] call btc_task_fnc_create;
[["btc_dft", "btc_m"], 0] call btc_task_fnc_create;
[["btc_dty", "btc_m"], 1] call btc_task_fnc_create;

if (btc_db_load && {profileNamespace getVariable [format ["btc_hm_%1_db", worldName], false]}) then {
    if ((profileNamespace getVariable [format ["btc_hm_%1_version", worldName], 1.13]) in [btc_version select 1, 21.1]) then {
        [] call compileScript ["core\fnc\db\load.sqf"];
    } else {
        [] call compileScript ["core\fnc\db\load_old.sqf"];
    };
} else {
    if (btc_hideout_n > 0) then {
        for "_i" from 1 to btc_hideout_n do {[] call btc_hideout_fnc_create;};
    } else {
        [] spawn btc_fnc_final_phase;
    };
    
    [] call btc_cache_fnc_init;

    btc_startDate set [3, btc_p_time];
    setDate btc_startDate;

    {
        _x call btc_veh_fnc_add;
    } forEach (getMissionLayerEntities "btc_vehicles" select 0);
};

[] call btc_eh_fnc_server;
[btc_ied_list] call btc_ied_fnc_fired_near;
[] call btc_chem_fnc_checkLoop;
[] call btc_chem_fnc_handleShower;
[] call btc_spect_fnc_checkLoop;
if (btc_p_db_autoRestart > 0) then {
    [{
        [19] remoteExecCall ["btc_fnc_show_hint", [0, -2] select isDedicated];
        [btc_db_fnc_autoRestart, [], 5 * 60] call CBA_fnc_waitAndExecute;
    }, [], btc_p_db_autoRestartTime * 60 * 60 - 5 * 60] call CBA_fnc_waitAndExecute;
};

{
    [_x, 30] call btc_veh_fnc_addRespawn;
    if (_forEachIndex isEqualTo 0) then {
        missionNamespace setVariable ["btc_veh_respawnable_1", _x, true];
    };
} forEach (getMissionLayerEntities "btc_veh_respawnable" select 0);

if (btc_p_side_mission_cycle > 0) then {
    for "_i" from 1 to btc_p_side_mission_cycle do {
        [true] spawn btc_side_fnc_create;
    };
};

{
    ["btc_tag_remover" + _x, "STR_BTC_HAM_ACTION_REMOVETAG", _x, ["#(rgb,8,8,3)color(0,0,0,0)"], "\a3\Modules_F_Curator\Data\portraitSmoke_ca.paa"] call ace_tagging_fnc_addCustomTag;
} forEach ["ACE_SpraypaintRed"];

if (btc_p_respawn_ticketsAtStart >= 0) then {
    if (btc_p_respawn_ticketsShare) then {
        private _tickets = btc_p_respawn_ticketsAtStart;
        if (btc_p_respawn_ticketsAtStart isEqualTo 0) then {
            _tickets = -1;
        };
        [btc_player_side, _tickets] call BIS_fnc_respawnTickets;
    };
};

if(isServer) then {
// set the civilian types that will act as next-of-kin
GR_CIV_TYPES = ["C_man_polo_1_F_asia","C_man_polo_5_F_asia"];

// set the maximum distance from murder that next-of-kin will be spawned
GR_MAX_KIN_DIST = 20000;

// Chance that a player murdering a civilian will get an "apology" mission
GR_MISSION_CHANCE = 0;

// Delay in seconds after death until player is notified of body delivery mission
GR_TASK_MIN_DELAY=20;
GR_TASK_MID_DELAY=40;
GR_TASK_MAX_DELAY=60;

// Set custom faction names to determine blame when performing an autopsy
GR_FACTIONNAME_EAST = "NFA";
GR_FACTIONNAME_WEST = "NATO";
GR_FACTIONNAME_IND = "Insurgents";

// You can also add/remove custom event handlers to be called upon
// certain events.

// On civilian murder by player:
[yourCustomEvent_OnCivDeath] call GR_fnc_addCivDeathEventHandler; // args [_killer, _killed, _nextofkin]
// (NOTE: _nextofkin will be nil if a body delivery mission wasn't generated.)
[yourCustomEvent_OnCivDeath] call GR_fnc_removeCivDeathEventHandler;

// On body delivery:
[yourCustomEvent_OnDeliverBody] call GR_fnc_addDeliverBodyEventHandler; // args [_killer, _nextofkin, _body]
[yourCustomEvent_OnDeliverBody] call GR_fnc_removeDeliverBodyEventHandler;

// On successful concealment of a death:
[yourCustomEvent_OnConcealDeath] call GR_fnc_addConcealDeathEventHandler; // args [_killer, _nextofkin, _grave]
[yourCustomEvent_OnConcealDeath] call GR_fnc_removeConcealDeathEventHandler;

// On reveal of a concealed death via autopsy:
[yourCustomEvent_OnRevealDeath] call GR_fnc_addRevealDeathEventHandler; // args [_medic, _body, _killerSide]
[yourCustomEvent_OnRevealDeath] call GR_fnc_removeRevealDeathEventHandler;

// NOTE: if your event handler uses _nextofkin or _body, make sure to turn off garbage collection with:
// _nextofkin setVariable ["GR_WILLDELETE",false];
// _body setVariable ["GR_WILLDELETE",false];
};

[] spawn {call compile preprocessFileLineNumbers "EPD\Ied_Init.sqf";};