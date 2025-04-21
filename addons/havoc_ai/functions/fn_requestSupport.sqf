/*
 * Havoc AI - Request Support Function
 * File: fn_requestSupport.sqf
 * Author: Osmond_A
 *
 * Description:
 * Attempts to find and task an available support unit.
 *
 * Params:
 * _unit: Object - The AI unit requesting support.
 * _targetPos: Position - The target location for the support.
 *
 * Execution: Server/Host
 */

params ["_unit", "_targetPos"];
if (!local _unit || !alive _unit) exitWith {};

// --- Baca Pengaturan dari CBA Settings ---
private _enableSystem = ["havocai_enableSupportCalls", false] call CBA_fnc_getSetting;
if (!_enableSystem) exitWith { /* systemChat "Havoc AI Support System Disabled."; */ }; // Keluar jika sistem dimatikan

// --- Cek Pengaturan Spesifik Modul (Jika ada) ---
// private _moduleSettings = _unit getVariable ["HAVOCAI_ModuleSettings", createHashMap]; // Asumsi disimpan saat init
// if !(_moduleSettings getOrDefault ["EnableModuleSupportCalls", true]) exitWith {}; // Keluar jika modul ini mematikannya

// --- Cek Cooldown ---
private _cooldown = ["havocai_supportCallCooldown", 300] call CBA_fnc_getSetting;
private _lastCall = _unit getVariable ["HAVOCAI_LastSupportCall", 0];
if (time < _lastCall + _cooldown) exitWith { /* systemChat format ["%1: Support call on cooldown.", _unit]; */ }; // Keluar jika masih cooldown

// --- Cari Unit Bantuan ---
private _radius = ["havocai_supportSearchRadius", 5000] call CBA_fnc_getSetting;
private _foundSupportUnit = objNull;
private _supportPriority = ["havocai_supportPriority", ["CAS", "Helicopter", "Armor", "Artillery"]] call CBA_fnc_getSetting; // Dapatkan urutan prioritas

private _nearbyUnits = (getPos _unit) nearEntities ["AllVehicles", _radius]; // Cari kendaraan dalam radius
// Atau cari unit darat juga: _nearbyUnits = (getPos _unit) nearEntities [["Man", "LandVehicle", "Air", "Ship"], _radius];

// Filter unit kawan, hidup, dan bukan unit pemanggil atau grupnya
_nearbyUnits = _nearbyUnits select {
    alive _x &&
    side _x == side _unit &&
    !(_x isKindOf "Man") && // Fokus pada kendaraan bantuan
    group _x != group _unit &&
    local _x // Pastikan unit support lokal ke server
};

// Logika Pemilihan Bantuan (Sangat Sederhana - Prioritas pertama ditemukan)
// Perlu dibuat JAUH lebih baik untuk memilih yg "terbaik" dan "idle"
{ // Loop melalui prioritas: "CAS", "Helicopter", "Armor", "Artillery"
    private _supportType = _x;
    { // Loop melalui unit terdekat
        private _potentialSupport = _forEachIndex;
        private _isSuitable = false;
        private _isIdle = behaviour _potentialSupport != "COMBAT"; // Cek idle sederhana

        if (_isIdle) then {
            switch (_supportType) do {
                case "CAS": { if (_potentialSupport isKindOf "Plane") then { _isSuitable = true; }; };
                case "Helicopter": { if (_potentialSupport isKindOf "Helicopter") then { _isSuitable = true; }; }; // Perlu dibedakan Attack vs Transport
                case "Armor": { if (_potentialSupport isKindOf "Tank" || {_potentialSupport isKindOf "APC"}) then { _isSuitable = true; }; }; // Atau "Tracked_APC", "Wheeled_APC"
                case "Artillery": { if (_potentialSupport isKindOf "StaticMortar" || {_potentialSupport isKindOf "StaticCannon"}) then { _isSuitable = true; }; }; // Atau cek senjata spesifik
            };
        };

        if (_isSuitable) exitWith { _foundSupportUnit = _potentialSupport; }; // Ambil yang pertama cocok & idle

    } forEach _nearbyUnits;

    if !(isNull _foundSupportUnit) exitWith {}; // Keluar loop prioritas jika sudah ditemukan

} forEach _supportPriority;


// --- Tugaskan Unit Bantuan Jika Ditemukan ---
if !(isNull _foundSupportUnit) then {
    diag_log format ["Havoc AI: Unit %1 requesting support from %2 to %3", _unit, _foundSupportUnit, _targetPos];
    systemChat format ["%1 requesting %2 support at %3!", name _unit, typeOf _foundSupportUnit, mapGridPosition _targetPos]; // Info untuk player

    private _supportGroup = group _foundSupportUnit;

    // Hapus waypoint lama? (Berisiko jika unit sedang ada tugas lain)
    // while {count (waypoints _supportGroup) > 0} do { deleteWaypoint ((waypoints _supportGroup) select 0); };

    // Tambah waypoint Seek and Destroy (SAD)
    private _wp = _supportGroup addWaypoint [_targetPos, 0];
    _wp setWaypointType "SAD";
    _wp setWaypointBehaviour "COMBAT"; // Atau "AWARE" untuk lebih hati-hati?
    _wp setWaypointCombatMode "RED"; // Selalu tembak
    _wp setWaypointSpeed "FULL"; // Kecepatan penuh jika jauh
    _wp setWaypointCompletionRadius 150; // Radius penyelesaian

    // Paksa mode tempur (mungkin redundant dengan waypoint)
    // _supportGroup setCombatMode "RED";
    // _supportGroup setBehaviour "COMBAT";

    // Set cooldown pada unit pemanggil
    _unit setVariable ["HAVOCAI_LastSupportCall", time, true];

} else {
    // diag_log format ["Havoc AI: Unit %1 failed to find available support.", _unit];
    // systemChat format ["%1: No support available!", name _unit];
};