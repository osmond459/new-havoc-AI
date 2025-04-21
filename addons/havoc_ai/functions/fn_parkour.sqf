private _settings = _unit getVariable ["HAVOCAI_Settings", createHashMap];
if (_settings getOrDefault ["EnableAdvancedMovementHook", false]) then {
     // Cek apakah mod Enhanced Movement (contoh) aktif
     if (isClass (configFile >> "CfgPatches" >> "enh_movement")) then {
         // Coba gunakan fungsi dari mod tersebut (NAMA FUNGSI HANYA CONTOH!)
         // Mungkin ada fungsi untuk mengecek rintangan dan otomatis vault/climb?
         // if ([_unit, _pos] call ENH_fnc_canMoveAdvanced) then {
         //     [_unit, _pos] call ENH_fnc_doMoveAdvanced; // Panggil fungsi move mod tsb
         // } else {
         //     _unit doMove _pos; // Gunakan move biasa jika tidak bisa advanced
         // };
         diag_log "Havoc AI: Enhanced Movement detected, advanced move attempt possible (needs specific function calls).";
         _unit doMove _pos; // Fallback ke move biasa sementara
     } else {
         // Mod tidak aktif, gunakan move biasa
          _unit doMove _pos;
     };
} else {
    // Hook tidak aktif, gunakan move biasa
     _unit doMove _pos;
};