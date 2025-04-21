/*
 * Havoc AI - Apply AI Cheat to Selected Sides
 * File: fn_applyAICheat.sqf
 */
#define HAVOC_CHEAT_IDD 84100 // IDD Dialog

params ["_cheatType"]; // 0=Sway0, 1=Sway50, 2=Sway100, 3=StaminaON, 4=StaminaOFF

// Pastikan dialog ada
private _display = uiNamespace getVariable ["HAVOCAI_CheatDialog", displayNull];
if (isNull _display) exitWith { diag_log "Havoc AI Cheat: Dialog not found."; };

// Dapatkan status checkbox faksi
private _applyBLU = cbChecked (_display displayCtrl 3001);
private _applyOPF = cbChecked (_display displayCtrl 3002);
private _applyIND = cbChecked (_display displayCtrl 3003);

private _sidesToAffect = [];
if (_applyBLU) then { _sidesToAffect pushBack west; };
if (_applyOPF) then { _sidesToAffect pushBack east; };
if (_applyIND) then { _sidesToAffect pushBack independent; };

if (count _sidesToAffect == 0) exitWith { hint "Select at least one side!"; };

// Tentukan variabel dan nilai yang akan diset
private _variableName = "";
private _variableValue = "";
private _hintText = "";

switch (_cheatType) do {
    case 0: { _variableName = "HAVOCAI_SwayLevel"; _variableValue = 0; _hintText = "Normal Sway"; }; // Sway Normal
    case 1: { _variableName = "HAVOCAI_SwayLevel"; _variableValue = 1; _hintText = "Reduced Recoil (50%)"; }; // Sway 50%
    case 2: { _variableName = "HAVOCAI_SwayLevel"; _variableValue = 2; _hintText = "No Aim Sway (100%)"; }; // Sway 100%
    case 3: { _variableName = "HAVOCAI_StaminaEnabled"; _variableValue = false; _hintText = "No Stamina ON"; }; // Stamina OFF = true
    case 4: { _variableName = "HAVOCAI_StaminaEnabled"; _variableValue = true; _hintText = "No Stamina OFF"; }; // Stamina ON = false
};

if (_variableName == "") exitWith { diag_log "Havoc AI Cheat: Invalid Cheat Type."; };

// Loop semua unit dan terapkan jika sisinya cocok dan lokal (jika perlu kontrol lokal)
{
    private _side = _x;
    {
        // Terapkan ke AI lokal di server/HC atau semua AI jika single player
        // Cek local _forEachIndex mungkin diperlukan tergantung bagaimana efek diterapkan
        if (side _forEachIndex == _side && !isPlayer _forEachIndex) then {
            _forEachIndex setVariable [_variableName, _variableValue, true]; // Set variabel di AI
            // diag_log format ["Havoc AI Cheat: Applied %1 = %2 to %3", _variableName, _variableValue, _forEachIndex];
        };
    } forEach allUnits; // Atau allMissionObjects "Man" untuk performa lebih baik?

} forEach _sidesToAffect;

hint format ["Applied AI Cheat '%1' to selected sides.", _hintText];

// Penting: Efek No Sway/Stamina AI perlu dibaca dari variabel unit ini
// di dalam skrip AI yang berjalan (misal fn_mainBehaviorLoop atau EH global AI)
// Contoh penerapan efek sway di loop AI:
// private _swayLvl = _unit getVariable ["HAVOCAI_SwayLevel", 0];
// if (_swayLvl != (_unit getVariable ["HAVOCAI_CurrentSwayApplied", 0])) then {
//     [_unit, _swayLvl] call HAVOCAI_fnc_applyNoSway;
//     _unit setVariable ["HAVOCAI_CurrentSwayApplied", _swayLvl];
// };
// Untuk stamina, EH HandleDamage global AI (jika ada) akan membaca variabel "HAVOCAI_StaminaEnabled"

true;