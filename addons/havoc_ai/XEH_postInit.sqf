/*
 * Havoc AI - Post Initialization Script (CBA XEH)
 * File: XEH_postInit.sqf
 */

// Pastikan hanya dijalankan sekali dan di client yang punya interface atau di server
if !(hasInterface || isServer) exitWith {};
// Hindari init ganda
if !(isNil "havocai_postInit_done") exitWith {};
havocai_postInit_done = true;

diag_log "Havoc AI: Running PostInit.";

// --- Inisialisasi Pengaturan Player Awal ---
if (hasInterface) then { // Hanya untuk client dengan UI (termasuk host)
    // Terapkan No Sway awal saat player join
    private _playerSwaySetting = ["havocai_playerNoSwayLevel", 0] call CBA_fnc_getSetting;
    [player, _playerSwaySetting] call HAVOCAI_fnc_applyNoSway;

    // Daftarkan Event Handler Stamina Player
    player addEventHandler ["HandleDamage", {
        _this call HAVOCAI_fnc_handleStamina;
    }];
    diag_log "Havoc AI: Player Sway/Stamina Handlers Initialized.";

    // --- Inisialisasi Cheat Menu ---
    // Buat Keybind untuk membuka cheat menu
    private _action = {
        // Cek jika map terlihat DAN keybind diaktifkan di Addon Options
        if (visibleMap && (["havocai_cheatEnableKeybind", true] call CBA_fnc_getSetting)) then {
             // Cek jika dialog belum terbuka
             if (isNull (uiNamespace getVariable ["HAVOCAI_CheatDialog", displayNull])) then {
                 [] call HAVOCAI_fnc_openCheatMenu; // Panggil fungsi pembuka dialog
             } else {
                 closeDialog 0; // Tutup jika sudah terbuka saat keybind ditekan lagi
             };
        };
    };
    // ID unik untuk keybind
    private _id = "HAVOCAI_OpenCheatMenu";

    // === BAGIAN KEYBIND YANG DIPERBAIKI ===
    // Key codes: CTRL = true, SHIFT = true, M Key = 50
    private _key = 50;    // DIK Code untuk tombol M
    private _shift = true;  // true = SHIFT harus ditekan
    private _ctrl = true;   // true = CTRL harus ditekan
    private _alt = false;   // false = ALT tidak perlu ditekan
    // Daftarkan keybind via CBA
    [_id, _key, _shift, _ctrl, _alt, _action, {}] call CBA_fnc_addKeybind;
    diag_log "Havoc AI: Cheat Menu Keybind Initialized (CTRL + SHIFT + M on Map)."; // Log sudah diupdate
    // === AKHIR BAGIAN KEYBIND YANG DIPERBAIKI ===

    // Daftarkan Event Handler Teleport Map Click
     (findDisplay 12) displayAddEventHandler ["MapSingleClick", {
         params ["_map", "_pos", "_alt", "_shift", "_ctrl"];
         // Cek jika Alt ditekan saat klik kiri
         if (_alt && ! _shift && ! _ctrl) then {
             // Pastikan cheat menu atau fungsi teleport aktif jika perlu (bisa tambahkan cek di sini)
             hintSilent format ["Teleporting to %1...", mapGridPosition _pos];
             [player, _pos] call HAVOCAI_fnc_teleportPlayer; // Panggil fungsi teleport
             true // Return true untuk override default map click
         } else {
             false // Return false untuk biarkan default map click
         };
     }];
     diag_log "Havoc AI: Map Teleport Handler Initialized (ALT + Left Click).";

};

// --- Inisialisasi Global AI (Jika diperlukan EH global untuk AI) ---
if (isServer) then {
    // Contoh: Jika ingin menerapkan No Stamina ke *semua* AI secara global
    // Ini bisa berat performanya jika banyak AI
    /*
    {
        if (!isPlayer _x && local _x) then {
            _x addEventHandler ["HandleDamage", {
                 // Hanya proses jika AI No Stamina aktif secara global
                 if (["havocai_aiRemoveStamina", false] call CBA_fnc_getSetting) then {
                     _this call HAVOCAI_fnc_handleStamina;
                 } else {
                     _this select 4; // Return damage asli jika setting off
                 };
            }];
        };
    } forEach allUnits;
    addMissionEventHandler ["EntityCreated", {
        params ["_entity"];
        if (!isPlayer _entity && local _entity && _entity isKindOf "Man") then {
             _entity addEventHandler ["HandleDamage", {
                 if (["havocai_aiRemoveStamina", false] call CBA_fnc_getSetting) then {
                     _this call HAVOCAI_fnc_handleStamina;
                 } else {
                     _this select 4;
                 };
            }];
        };
    }];
    diag_log "Havoc AI: Global AI Stamina Handler Initialized (Server).";
    */
    // Pendekatan yang lebih baik mungkin menerapkan EH ini hanya pada AI
    // yang diinisialisasi oleh modul Havoc di fn_applyAISettings.sqf
};