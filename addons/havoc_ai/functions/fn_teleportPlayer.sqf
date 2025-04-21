/*
 * Havoc AI - Teleport Player
 * File: fn_teleportPlayer.sqf
 */
params ["_unit", "_targetPos"];

if !(local _unit) exitWith {}; // Hanya jalankan lokal

// Cek jika di dalam kendaraan, teleport kendaraan
_vehicle = vehicle _unit;
if (_vehicle != _unit) then {
    _vehicle setPosATL _targetPos;
} else {
    _unit setPosATL _targetPos;
};

true;