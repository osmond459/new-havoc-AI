/*
 * Havoc AI - Handle Damage Event for Stamina
 * File: fn_handleStamina.sqf
 * Author: Osmond_A
 *
 * Description:
 * Called by HandleDamage EH. Checks if stamina removal is active
 * for the unit and negates stamina damage if true.
 *
 * Params: (Passed from HandleDamage EH)
 * _unit: Object - Unit receiving damage
 * _selection: String - Body part hit
 * _damage: Number - Damage amount
 * _source: Object - Source of damage
 * _projectile: String - Projectile classname
 * _hitIndex: Number - Hit point index
 * _instigator: Object - Instigator (if applicable)
 * _damageType: String - Type of damage ("stamina", "health", etc.)
 *
 * Return: Number - Modified damage value
 *
 * Execution: Client (for player EH), Server/HC (for AI EH)
 */
params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_damageType"];

private _newDamage = _damage; // Default kembalikan damage asli

// Cek apakah ini damage stamina
if (_damageType == "stamina") then {
    private _removeStamina = false;
    // Cek apakah unit adalah player atau AI
    if (_unit == player) then {
        // Baca setting player dari CBA
        _removeStamina = ["havocai_playerRemoveStamina", false] call CBA_fnc_getSetting;
    } else {
        // Untuk AI, cek setting global CBA (jika EH global aktif) ATAU setting dari modul
        // Pendekatan 1: Baca setting global CBA (jika EH global AI di XEH_postInit aktif)
         _removeStamina = ["havocai_aiRemoveStamina", false] call CBA_fnc_getSetting;

        // Pendekatan 2: Baca setting dari variabel unit (jika EH dipasang per unit oleh modul)
        // private _settings = _unit getVariable ["HAVOCAI_Settings", createHashMap];
        // private _globalSetting = ["havocai_aiRemoveStamina", false] call CBA_fnc_getSetting;
        // private _moduleOverride = _settings getOrDefault ["AI_RemoveStaminaOverride", -1]; // Asumsi key ini ada jika pakai override modul
        // if (_moduleOverride == 1) then { _removeStamina = true; };
        // if (_moduleOverride == 0) then { _removeStamina = false; };
        // if (_moduleOverride == -1) then { _removeStamina = _globalSetting; }; // Ikut global jika -1
    };

    // Jika remove stamina aktif, set damage stamina jadi 0
    if (_removeStamina) then {
        _newDamage = 0;
    };
};

_newDamage // Kembalikan nilai damage (0 jika stamina dihapus, asli jika tidak)