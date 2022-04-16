
[compileScript ["core\init.sqf"]] call CBA_fnc_directCall;

addMissionEventHandler ["EntityKilled", 
{
	params ["_killed", "_killer"];
	
	if (_killed isKindOf "CAManBase" && {side group _killed isEqualTo civilian}) then
	{
		systemChat format ["Player %1 killed a civilian and has been logged. Ensure it is included in your AAR", name _killer];
	};
}];

private _availableLanguages = [
    ["ar", "Arabic"],
    ["ru", "Russian"],
    ["en", "English"]
];

{
    _x call acre_api_fnc_babelAddLanguageType;
} forEach _availableLanguages;

if (hasInterface) then {
    [] spawn {
        waitUntil {!isNull player};

        private _playerLanguages = player getVariable ["mission_languages", []];
        if (_playerLanguages isEqualTo []) then {
            private _defaultLanguages = [
                ["en"], // west
                ["ru"], // east
                ["ar"], // resistance
                ["ru"] // civilian
            ];

            _playerLanguages = _defaultLanguages param [[west,east,resistance,civilian] find playerSide, ["ru"]];
        };

        [acre_api_fnc_babelSetSpokenLanguages, _playerLanguages] call CBA_fnc_directCall;
    };
}