/*
 * Havoc AI - Main Behavior Loop Function
 * File: fn_mainBehaviorLoop.sqf
 * Author: Osmond_A
 * (Deskripsi lainnya...)
 */

#include "\a3\ui_f\hpp\definedikcodes.inc" // Optional: For key codes if needed later

params ["_unit"];

// --- Basic Checks ---
if (!local _unit) exitWith {};
if (!alive _unit) exitWith {};
if (isPlayer _unit) exitWith {};
if !(isNull (_unit getVariable "HAVOCAI_BehaviorHandle")) then {
    // Prevent script running twice if spawn called again accidentally
    // diag_log format ["Havoc AI: Loop already exists for %1, exiting new instance.", _unit];
    // exitWith {}; // Be careful with this, might prevent restart if needed
};


// --- Get Settings Stored on Unit ---
private _difficulty = _unit getVariable ["HAVOCAI_Difficulty", "Hard"];
private _tacticalStyle = _unit getVariable ["HAVOCAI_Style", "Default"];
// Ambil HashMap pengaturan, default ke map kosong jika belum ada
private _settings = _unit getVariable ["HAVOCAI_Settings", createHashMap];


// --- Debug: Log settings being used ---
// diag_log format ["Havoc AI Loop Start %1: Diff: %2, Style: %3, Looting: %4, Repair: %5, Dismount: %6", _unit, _difficulty, _tacticalStyle, (_settings getOrDefault ["EnableLooting", "N/A"]), (_settings getOrDefault ["EnableRepair", "N/A"]), (_settings getOrDefault ["EnableDriverDismount", "N/A"])];


// --- Initial Behavior Settings (can be influenced by style/settings) ---
_unit setCombatMode "RED";
_unit setBehaviour "COMBAT"; // Start aggressive
_unit setUnitPos "UP";

// Apply settings influence (Examples)
if (_tacticalStyle == "Guerilla") then {
    _unit setBehaviour "STEALTH"; // Prioritize stealth initially
    _unit setSkill ["camouflage", 0.9]; // Higher camo for guerilla
};
// Note: Pengaturan allowFleeing berdasarkan ForceNoRetreat sebaiknya dihandle di fn_applyAISettings


// --- Event Handlers (Attach ONCE per unit) ---
if (isNil {_unit getVariable "HAVOCAI_EH_Initialized"}) then {
    _unit setVariable ["HAVOCAI_EH_Initialized", true, true];

    // KnownEnemy EH
    _unit addEventHandler ["KnownEnemy", { /* ... (Kode EH KnownEnemy seperti sebelumnya) ... */ }];

    // FiredNear EH (Counter Sniper / Sound Reaction)
    _unit addEventHandler ["FiredNear", { /* ... (Kode EH FiredNear seperti sebelumnya) ... */ }];

    // MineDetected EH
    _unit addEventHandler ["MineDetected", { /* ... (Kode EH MineDetected seperti sebelumnya) ... */ }];
    // GetOut EH (Pilot Eject/Crash)
    _unit addEventHandler ["GetOut", { /* ... (Kode EH GetOut seperti sebelumnya) ... */ }];
    // GetIn EH (Pilot Rescue / Driver Return)
    _unit addEventHandler ["GetIn", { /* ... (Kode EH GetIn seperti sebelumnya) ... */ }];
     // Killed EH (Optional: for looting trigger or group notification)
     _unit addEventHandler ["Killed", { /* ... (placeholder) ... */ }];

}; // End of EH Initialization Check


// --- Main Behavior Loop ---
while {alive _unit && local _unit && (_unit getVariable ["HAVOCAI_Active", false])} do { // Check flag
    // --- Deklarasi Variabel Awal Loop ---
    private _currentBehavior = behaviour _unit;
    private _currentTarget = currentTarget _unit; // <<< PERBAIKAN DI SINI
    private _knowsAboutEnemy = knowsAbout _unit > 1.5;
    private _enemiesNear = _unit nearEntities ["Man", 150]; // Adjust radius based on performance/needs
    private _visibleEnemy = objNull;
    _enemiesNear = _enemiesNear select {side _x != side _unit && alive _x};

    // Find best visible enemy
    { if (_unit knowsAbout _x > 3.5) exitWith { _visibleEnemy = _x; }; } forEach _enemiesNear;


    // --- Combat Logic ---
    if !(isNull _visibleEnemy) then {
        if (_currentBehavior != "COMBAT") then { _unit setBehaviour "COMBAT"; };

        // --- Logika Panggil Bantuan Otomatis ---
        private _enableSystem = ["havocai_enableSupportCalls", false] call CBA_fnc_getSetting; // Baca dari Addon Options CBA
        private _moduleSettingEnabled = _settings getOrDefault ["EnableModuleSupportCalls", true]; // Baca dari Modul Spesifik
        private _isCallSystemEnabled = _enableSystem && _moduleSettingEnabled; // Aktif jika global & modul mengizinkan

        private _shouldCall = false;
        if (_isCallSystemEnabled && _knowsAboutEnemy > 2.5 && {count _enemiesNear > 3}) then { // Jika sistem aktif & kondisi terpenuhi
             private _cooldown = ["havocai_supportCallCooldown", 300] call CBA_fnc_getSetting; // Ambil cooldown global
             private _lastCall = _unit getVariable ["HAVOCAI_LastSupportCall", 0];
             if (time >= _lastCall + _cooldown && {random 100 < 15}) then { // 15% chance per loop jika cooldown selesai
                 _shouldCall = true;
             };
        };

         // Jika kondisi terpenuhi, panggil fungsi request support
         if (_shouldCall) then {
            // Tentukan posisi target
            private _targetPosition = getPos _visibleEnemy;
            // Panggil fungsi request support
            [_unit, _targetPosition] spawn HAVOCAI_fnc_requestSupport;
            _unit setVariable ["HAVOCAI_LastSupportCall", time, true];
        };
         // --- Akhir Logika Panggil Bantuan ---

        // --- CQB Logic ---
        // ... (Kode logika CQB Anda di sini) ...

        // --- Outdoor Combat / Shoot & Scoot ---
        // ... (Kode logika tempur outdoor Anda di sini) ...

        // --- Vehicle/Pilot Targeting ---
        // ... (Kode logika target kendaraan/pilot Anda di sini) ...

        // --- Air Combat Logic ---
        // ... (Kode logika tempur udara Anda di sini) ...

    } else { // No visible enemy
        if (_knowsAboutEnemy) then { // Knows enemy exists nearby but not visible
            if (_currentBehavior != "AWARE") then { _unit setBehaviour "AWARE"; };
            // --- Searching Logic ---
            // ... (Kode logika mencari Anda di sini) ...
        } else { // No known enemies
             // --- Patrol Logic ---
             if (_currentBehavior != "SAFE" && _currentBehavior != "AWARE" && _tacticalStyle != "Guerilla") then {
                 _unit setBehaviour "AWARE"; // Default non-contact behavior
             };
            // ... (Kode logika patroli Anda di sini) ...

             // --- Logika Animasi Ambient --- <<< DIPINDAHKAN KE SINI (HANYA JIKA AMAN/PATROLI)
             if (_settings getOrDefault ["EnableAmbientAnims", true]) then {
                 private _isIdle = (behaviour _unit == "SAFE" || behaviour _unit == "AWARE") && // Mode aman/waspada
                                  {vectorMagnitude velocity _unit < 0.5} && // Hampir tidak bergerak
                                  {!(_unit getVariable ["HAVOCAI_IsInAmbientAnim", false])}; // Belum sedang animasi

                 if (_isIdle) then {
                     private _idleTimer = _unit getVariable ["HAVOCAI_IdleStartTime", -1];
                     if (_idleTimer == -1) then {
                          _unit setVariable ["HAVOCAI_IdleStartTime", time];
                     } else {
                         if (time > _idleTimer + (10 + random 10)) then { // Jika sudah idle 10-20 detik
                             [_unit] call HAVOCAI_fnc_playAmbientAnim; // Panggil fungsi animasi
                             _unit setVariable ["HAVOCAI_IdleStartTime", -1]; // Reset timer
                         };
                     };
                 } else {
                      _unit setVariable ["HAVOCAI_IdleStartTime", -1]; // Reset timer jika tidak idle
                      // Hentikan animasi jika sudah waktunya atau tidak idle lagi
                      if (_unit getVariable ["HAVOCAI_IsInAmbientAnim", false]) then {
                          if (time > (_unit getVariable ["HAVOCAI_AmbientEndTime", 0]) || behaviour _unit == "COMBAT" || vectorMagnitude velocity _unit >= 0.5) then {
                              _unit switchMove ""; // Kembali ke animasi default
                              _unit setVariable ["HAVOCAI_IsInAmbientAnim", false];
                          };
                      };
                 };
             };
             // --- Akhir Logika Animasi Ambient ---

             // --- Logika Buat Api Unggun (Contoh, hanya jika aman & malam) ---
             if (_settings getOrDefault ["EnableCampfireCreation", false] && (daytime < 6 || daytime > 18)) then {
                 if (random 100 < 0.5) then { // Peluang sangat kecil per loop jika idle
                     [_unit] call HAVOCAI_fnc_createCampfire;
                 };
             };
             // --- Akhir Logika Api Unggun ---

        }; // End else (No known enemies)
    }; // End else (No visible enemy)


    // --- Logika di luar Combat Utama (Looting, Repair, Driver Dismount) ---

    // --- Looting Logic ---
    if (_settings getOrDefault ["EnableLooting", true]) then {
        if (random 100 < 5) then { /* ... (Kode looting) ... */ };
    };

    // --- Driver Dismount Logic ---
    if (_unit == driver (vehicle _unit) && vehicle _unit != _unit) then {
         if !(isNull _visibleEnemy) && {_unit distance _visibleEnemy < 75} && {!(_unit getVariable ["DRIVER_DISMOUNTED", false])} && (_settings getOrDefault ["EnableDriverDismount", true]) then {
             /* ... (Kode driver turun) ... */
         } else {
             if (isNull _visibleEnemy && (_unit getVariable ["DRIVER_DISMOUNTED", false])) then {
                 /* ... (Kode driver naik lagi) ... */
             };
         };
    };

    // --- Repair Logic ---
    if (_settings getOrDefault ["EnableRepair", true]) then {
         if (random 100 < 3 && {"ToolKit" in items _unit}) then { /* ... (Kode repair) ... */ };
    };


    // --- Loop Delay ---
    private _sleepTime = 1.5 + random 1;
    if !(isNull _visibleEnemy) then { _sleepTime = 0.5 + random 0.5; }; // Faster checks in combat
    sleep _sleepTime;

}; // End of Main Loop

// --- Cleanup ---
diag_log format ["Havoc AI: Behavior loop ending for %1.", _unit];
_unit removeAllEventHandlers "KnownEnemy";
_unit removeAllEventHandlers "FiredNear";
_unit removeAllEventHandlers "MineDetected";
_unit removeAllEventHandlers "GetOut";
_unit removeAllEventHandlers "GetIn";
_unit removeAllEventHandlers "Killed";
_unit setVariable ["HAVOCAI_EH_Initialized", nil, true];
_unit setVariable ["HAVOCAI_BehaviorHandle", nil, true]; // Clear handle
_unit setVariable ["HAVOCAI_Active", false, true]; // Set inactive flag