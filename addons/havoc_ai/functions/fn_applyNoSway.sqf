/*
 * Havoc AI - Apply No Sway Effect
 * File: fn_applyNoSway.sqf
 * Author: Osmond_A
 *
 * Description:
 * Applies weapon sway reduction effect to a unit based on level.
 * Level 0: Normal, 1: Reduced Recoil (50%), 2: No Aim Sway (100%)
 *
 * Params:
 * _unit: Object - The unit to affect.
 * _level: Number - The sway reduction level (0, 1, or 2).
 *
 * Execution: Client (for player), Server/HC (for AI if running locally)
 */
params ["_unit", "_level"];

// Pastikan level valid
if !(_level in [0, 1, 2]) exitWith { diag_log format ["Havoc AI: Invalid sway level %1 for unit %2", _level, _unit]; };

// Hapus EH lama jika ada untuk mencegah duplikasi (jika pakai EH per frame)
// _unit removeAllEventHandlers "EachFrame";

// Terapkan efek berdasarkan level
switch (_level) do {
    case 0: { // Normal Sway
        _unit setUnitRecoilCoefficient 1;
        _unit setCustomAimCoef 1;
        if (_unit == player) then { hintSilent "Weapon Sway: Normal"; };
        diag_log format ["Havoc AI: Sway Normal applied to %1", _unit];
    };
    case 1: { // Reduced Recoil (50%)
        _unit setUnitRecoilCoefficient 0.5; // Kurangi recoil
        _unit setCustomAimCoef 1;          // Aim sway normal
         if (_unit == player) then { hintSilent "Weapon Sway: Reduced Recoil (50%)"; };
         diag_log format ["Havoc AI: Sway Reduced Recoil applied to %1", _unit];
    };
    case 2: { // No Aim Sway (100%)
        _unit setUnitRecoilCoefficient 0;   // Hilangkan recoil juga
        _unit setCustomAimCoef 0;           // Hilangkan aim sway (mungkin terasa aneh)
         if (_unit == player) then { hintSilent "Weapon Sway: Removed (100%)"; };
         diag_log format ["Havoc AI: Sway Removed applied to %1", _unit];
    };
};

// Jika perlu update terus menerus (misal jika ada mod lain yg reset):
// if (_level > 0) then {
//     _unit addEventHandler ["EachFrame", {
//         params ["_unit"];
//         private _lvl = _unit getVariable ["HAVOCAI_SwayLevel", 0]; // Simpan level di unit
//         if (_lvl == 1) then { _unit setUnitRecoilCoefficient 0.5; _unit setCustomAimCoef 1; };
//         if (_lvl == 2) then { _unit setUnitRecoilCoefficient 0; _unit setCustomAimCoef 0; };
//     }];
//     _unit setVariable ["HAVOCAI_SwayLevel", _level, true];
// };