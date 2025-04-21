/*
 * Havoc AI - Create Campfire
 * File: fn_createCampfire.sqf
 */
params ["_unit"];
if (!local _unit || !alive _unit) exitWith {};

private _settings = _unit getVariable ["HAVOCAI_Settings", createHashMap];
if !(_settings getOrDefault ["EnableCampfireCreation", false]) exitWith {}; // Keluar jika fitur dimatikan

// Hanya buat jika malam hari dan aman?
if (daytime > 6 && daytime < 18) exitWith {}; // Keluar jika siang
if (behaviour _unit == "COMBAT" || knowsAbout _unit > 1) exitWith {}; // Keluar jika ada musuh

// Cari posisi aman dan datar di dekat AI
private _searchPos = getPos _unit;
private _spawnPos = _searchPos findEmptyPosition [1, 5, "Land_Campfire_F"]; // Cari radius 5m

if (count _spawnPos > 0) then {
    // Cek apakah sudah ada api unggun lain di dekatnya
    if (count (nearestObjects [_spawnPos, ["Land_Campfire_F"], 10]) == 0) then {
        private _campfire = createVehicle ["Land_Campfire_F", _spawnPos, [], 0, "CAN_COLLIDE"];
        if !(isNull _campfire) then {
            diag_log format ["Havoc AI: %1 created campfire at %2", _unit, _spawnPos];
            // AI bisa diperintahkan duduk dekat api?
            // _unit doMove (getPos _campfire);
            // [_unit] call HAVOCAI_fnc_playAmbientAnim; // Mainkan animasi duduk?
        };
    };
};
true;