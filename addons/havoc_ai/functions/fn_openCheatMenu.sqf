/*
 * Havoc AI - Open Cheat Menu
 * File: fn_openCheatMenu.sqf
 */
#define HAVOC_CHEAT_IDD 84100 // IDD Dialog (Pastikan sama dengan di HPP)
// Jangan include HPP di sini, cukup gunakan IDD

if !(isNull (uiNamespace getVariable ["HAVOCAI_CheatDialog", displayNull])) exitWith {}; // Jangan buka jika sudah ada

// Buat dialog
private _display = createDialog "HAVOC_CheatMenu";
if (isNull _display) exitWith { diag_log "Havoc AI: Failed to create Cheat Menu dialog."; };

// --- Logika Kontrol Dialog ---

// Referensi kontrol God Mode
private _ctrlGodMode = _display displayCtrl 2001; // IDC Checkbox GodMode

// Variabel untuk menyimpan ID event handler God Mode
private _godModeEHVar = "HAVOCAI_GodModeEH_ID";

// Set status awal checkbox sesuai variabel player
private _godModeActive = player getVariable ["HAVOCAI_GodMode", false];
_ctrlGodMode cbSetChecked _godModeActive;

// --- Sinkronisasi EH God Mode saat dialog dibuka ---
// Pastikan status EH sesuai dengan status variabel (jika player mati/respawn/dll)
private _currentEHIndex = player getVariable [_godModeEHVar, -1];
if (_godModeActive && _currentEHIndex == -1) then { // God mode harusnya ON tapi EH tidak ada
    private _index = player addEventHandler ["HandleDamage", { 0 }]; // Hanya blok semua damage
    player setVariable [_godModeEHVar, _index, true];
    diag_log format ["Havoc AI: God Mode EH re-added (Index: %1)", _index];
} else {
    if (!_godModeActive && _currentEHIndex != -1) then { // God mode harusnya OFF tapi EH masih ada
        player removeEventHandler ["HandleDamage", _currentEHIndex];
        player setVariable [_godModeEHVar, nil, true]; // Hapus variabel index
        diag_log format ["Havoc AI: God Mode EH removed (Index: %1)", _currentEHIndex];
    };
};


// Tambahkan action ke checkbox God Mode
_ctrlGodMode ctrlAddEventHandler ["CheckedChanged", {
    params ["_control", "_checked"];
    private _ehVarName = "HAVOCAI_GodModeEH_ID"; // Nama variabel penyimpan index EH

    player setVariable ["HAVOCAI_GodMode", _checked, true]; // Simpan status ON/OFF

    // Hapus EH lama (jika ada) sebelum menambah/tidak menambah yang baru
    private _existingEH = player getVariable [_ehVarName, -1];
    if (_existingEH != -1) then {
        player removeEventHandler ["HandleDamage", _existingEH];
        player setVariable [_ehVarName, nil, true]; // Selalu hapus variabel index saat EH dihapus
        diag_log format ["Havoc AI: Previous God Mode EH removed (Index: %1)", _existingEH];
    };

    // Jika dicentang (God Mode ON)
    if (_checked) then {
        // Tambahkan EH baru dan simpan index-nya
        private _index = player addEventHandler ["HandleDamage", {
            // Script EH God Mode: Langsung return 0 untuk semua damage
            0
        }];
        player setVariable [_ehVarName, _index, true]; // Simpan index EH baru
        hint "Player God Mode: ON";
        diag_log format ["Havoc AI: God Mode EH added (Index: %1)", _index];
    } else {
        // Jika tidak dicentang (God Mode OFF)
        hint "Player God Mode: OFF";
        // EH sudah dihapus di atas
    };
}];

// --- Anda bisa tambahkan logika untuk set status awal checkbox faksi AI di sini jika perlu ---
// Contoh:
// (findDisplay HAVOC_CHEAT_IDD displayCtrl 3001) cbSetChecked true; // Default centang BLUFOR

true;