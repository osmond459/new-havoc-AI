/*
 * Havoc AI - Apply AI Settings Function
 * File: fn_applyAISettings.sqf
 * Author: Osmond_A
 *
 * Description:
 * Sets skill levels, stores settings as unit variables, handles fatigue setting,
 * and starts the main behavior loop script for a given AI unit.
 *
 * Params:
 * _unit: Object - The AI unit to modify.
 * _difficulty: String - "Medium", "Hard", or "Insane".
 * _tacticalStyle: String - "Default", "Guerilla", etc.
 * _settingsCheckboxes: HashMap - Contains settings read from module arguments.
 *
 * Execution: Server/Host
 */

params ["_unit", "_difficulty", "_tacticalStyle", "_settingsCheckboxes"];

if (!local _unit || !alive _unit || isPlayer _unit) exitWith { false }; // Safety checks

// --- Store Settings on Unit for Behavior Script Access ---
_unit setVariable ["HAVOCAI_Difficulty", _difficulty, true];
_unit setVariable ["HAVOCAI_Style", _tacticalStyle, true];
_unit setVariable ["HAVOCAI_Settings", _settingsCheckboxes, true]; // Store the whole map (termasuk override)
_unit setVariable ["HAVOCAI_Active", true, true]; // Flag that Havoc AI is running

// --- Set Core AI Skills Based on Difficulty ---
private _aiming = 0.6;
private _spotting = 0.6;
private _commanding = 0.6;
private _general = 0.6;
private _courage = 0.7; // Base courage

switch (_difficulty) do {
    case "Medium": {
        _aiming = 0.5; _spotting = 0.5; _commanding = 0.5; _general = 0.5; _courage = 0.6;
    };
    case "Hard": {
        _aiming = 0.75; _spotting = 0.75; _commanding = 0.75; _general = 0.75; _courage = 0.85;
    };
    case "Insane": {
        _aiming = 0.95; _spotting = 0.9; _commanding = 0.9; _general = 0.9; _courage = 1.0;
    };
};

_unit setSkill ["aimingAccuracy", _aiming];
_unit setSkill ["aimingShake", 1 - _aiming];
_unit setSkill ["aimingSpeed", _aiming + 0.1 max 1];
_unit setSkill ["spottingability", _spotting]; // Pastikan lowercase
_unit setSkill ["spottingDistance", _spotting];
_unit setSkill ["commanding", _commanding];
_unit setSkill ["general", _general];
// Courage diatur berdasarkan ForceNoRetreat di bawah

// --- Handle ForceNoRetreat Setting for Courage & allowFleeing ---
private _forceNoRetreat = _settingsCheckboxes getOrDefault ["ForceNoRetreat", false]; // Baca dari map
private _allowFleeingValue = 0.5; // Default: boleh kabur sedikit

if (_forceNoRetreat) then {
    _unit setSkill ["courage", 1.0]; // Keberanian maksimal jika dipaksa tidak mundur
    _allowFleeingValue = 0;       // Tidak boleh kabur
} else {
    // Jika tidak dipaksa, gunakan courage dari difficulty atau setting lain
     // Contoh: Terapkan courage dasar dari difficulty
     _unit setSkill ["courage", _courage];
     // Atur allowFleeing berdasarkan courage akhir
     if ((_unit getSkill "courage") >= 0.85 || _tacticalStyle == "Kamikaze") then { // Contoh batas courage tinggi
         _allowFleeingValue = 0;
     };
     // Anda bisa hapus cek "useCourage" lama jika tidak relevan lagi
     // if !(_settingsCheckboxes getOrDefault ["useCourage", true]) then { ... };
};
_unit allowFleeing _allowFleeingValue; // Terapkan nilai allowFleeing


// --- Handle AI No Sway Override ---
private _swayOverride = _settingsCheckboxes getOrDefault ["AI_NoSwayOverride", -1]; // -1, 0, 1, atau 2
if (_swayOverride != -1) then {
    // Jika ada override dari modul, panggil fungsi applyNoSway dengan nilai override
    [_unit, _swayOverride] call HAVOCAI_fnc_applyNoSway;
    diag_log format ["Havoc AI: Sway Override %1 applied to %2 via Module", _swayOverride, _unit];
} else {
    // Jika override -1 (Use Global), baca setting global CBA dan terapkan
    private _globalSwayLevel = ["havocai_aiNoSwayLevel", 0] call CBA_fnc_getSetting;
    [_unit, _globalSwayLevel] call HAVOCAI_fnc_applyNoSway;
    diag_log format ["Havoc AI: Global Sway Level %1 applied to %2", _globalSwayLevel, _unit];
};


// --- Handle AI Remove Stamina Override (enableFatigue) --- <<< BLOK BARU DISISIPKAN DI SINI
private _removeStaminaSettingValue = -1; // Default -1 = gunakan global
private _removeStaminaModuleOverride = _settingsCheckboxes getOrDefault ["AI_RemoveStaminaOverride", -1]; // Baca override dari modul (-1, 0, atau 1)

if (_removeStaminaModuleOverride != -1) then {
    // Jika ada override dari modul (0 atau 1), gunakan itu
    _removeStaminaSettingValue = _removeStaminaModuleOverride;
} else {
    // Jika override -1 (Use Global), baca setting global CBA
    // CBA_fnc_getSetting mengembalikan true/false untuk CHECKBOX
    if (["havocai_aiRemoveStamina", false] call CBA_fnc_getSetting) then {
        _removeStaminaSettingValue = 1; // True dari CBA -> konversi ke 1
    } else {
        _removeStaminaSettingValue = 0; // False dari CBA -> konversi ke 0
    };
};

// Terapkan enableFatigue berdasarkan nilai akhir (0 atau 1)
if (_removeStaminaSettingValue == 1) then { // Jika Remove Stamina = 1 (AKTIF/True)
    _unit enableFatigue false; // Matikan sistem fatigue (beban tidak berpengaruh)
    // Pastikan EH HandleDamage untuk AI (jika ada) aktif untuk blok stamina bar drop
    // Penambahan/penghapusan EH HandleDamage sebaiknya dihandle lebih terpusat (misal saat AI spawn/despawn atau via cheat)
    // agar tidak terjadi konflik/duplikasi jika fungsi ini dipanggil lagi.
    // Untuk AI, mungkin lebih baik mengandalkan setting global CBA di EH global (jika ada)
    // atau menerapkan EH satu kali saat unit diinisialisasi jika tidak ada EH global.
    _unit setVariable ["HAVOCAI_StaminaRemoved", true, true]; // Tandai status stamina AI
    diag_log format ["Havoc AI: Fatigue DISABLED for %1 (Setting Value: %2)", _unit, _removeStaminaSettingValue];
} else { // Jika Remove Stamina = 0 (TIDAK AKTIF/False)
    _unit enableFatigue true; // Aktifkan kembali sistem fatigue (beban berpengaruh)
    _unit setVariable ["HAVOCAI_StaminaRemoved", false, true]; // Tandai status stamina AI
    diag_log format ["Havoc AI: Fatigue ENABLED for %1 (Setting Value: %2)", _unit, _removeStaminaSettingValue];
};
// --- Akhir Logika Enable Fatigue ---


// --- Start the Main Behavior Loop Script ---
// Check if already running to prevent duplicates
if (isNil {_unit getVariable "HAVOCAI_BehaviorHandle"}) then {
    diag_log format ["Havoc AI: Starting behavior loop for %1 (Difficulty: %2, Style: %3)", _unit, _difficulty, _tacticalStyle];
    private _handle = [_unit] spawn HAVOCAI_fnc_mainBehaviorLoop;
    _unit setVariable ["HAVOCAI_BehaviorHandle", _handle, true];
} else {
    // diag_log format ["Havoc AI: Behavior loop already running for %1", _unit];
};

true