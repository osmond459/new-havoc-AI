/*
 * Havoc AI - Module Initialization Function
 * File: fn_initModule.sqf
 * Author: Osmond_A
 * (Deskripsi lainnya...)
 */

params ["_module", "_units", "_activated"];

if (!isServer) exitWith {}; // Pastikan hanya dijalankan di server/host

// --- Baca Pengaturan Dropdown dari Argumen Modul ---
private _difficultyIndex = _module get3DENAttribute "Difficulty";
private _tacticalStyleIndex = _module get3DENAttribute "TacticalStyle";
private _aiNoSwayOverride = _module get3DENAttribute "AI_NoSwayOverride"; // Baca override sway
private _aiRemoveStaminaOverride = _module get3DENAttribute "AI_RemoveStaminaOverride"; // Baca override stamina

// Fallback defaults jika atribut tidak ditemukan
if (isNil "_difficultyIndex") then { _difficultyIndex = 0; }; // Default Medium
if (isNil "_tacticalStyleIndex") then { _tacticalStyleIndex = 0; }; // Default Default
if (isNil "_aiNoSwayOverride") then { _aiNoSwayOverride = -1; }; // Default Use Global
if (isNil "_aiRemoveStaminaOverride") then { _aiRemoveStaminaOverride = -1; }; // Default Use Global


// Konversi index ke nama string (untuk Difficulty & Style)
private _difficultyLevels = ["Medium", "Hard", "Insane"];
private _tacticalStyles = ["Default", "Guerilla", "Blitzkrieg", "Kamikaze", "SunTzu"];
private _difficulty = _difficultyLevels select _difficultyIndex;
private _tacticalStyle = _tacticalStyles select _tacticalStyleIndex;

// --- Baca Pengaturan Dropdown (True/False) dari Argumen Modul ---
// Nilai sekarang 0 (False) atau 1 (True)
private _enableLootingVal = _module get3DENAttribute "EnableLooting";
private _enableRepairVal = _module get3DENAttribute "EnableRepair";
private _enableDriverDismountVal = _module get3DENAttribute "EnableDriverDismount";
private _forceNoRetreatVal = _module get3DENAttribute "ForceNoRetreat";
private _enableModuleSupportCallsVal = _module get3DENAttribute "EnableModuleSupportCalls";
private _enableAmbientAnimsVal = _module get3DENAttribute "EnableAmbientAnims";
private _enableWindowBreakingVal = _module get3DENAttribute "EnableWindowBreaking";
private _enableCampfireVal = _module get3DENAttribute "EnableCampfireCreation";
private _enableLeaderRestVal = _module get3DENAttribute "EnableSimpleLeaderRest";
private _enableMovementHookVal = _module get3DENAttribute "EnableAdvancedMovementHook";

// Fallback defaults jika atribut tidak ditemukan (sesuaikan dengan defaultValue di config)
if (isNil "_enableLootingVal") then { _enableLootingVal = 1; }; // Default True
if (isNil "_enableRepairVal") then { _enableRepairVal = 1; }; // Default True
if (isNil "_enableDriverDismountVal") then { _enableDriverDismountVal = 1; }; // Default True
if (isNil "_forceNoRetreatVal") then { _forceNoRetreatVal = 0; }; // Default False
if (isNil "_enableModuleSupportCallsVal") then { _enableModuleSupportCallsVal = 1; }; // Default True
if (isNil "_enableAmbientAnimsVal") then { _enableAmbientAnimsVal = 1; }; // Default True
if (isNil "_enableWindowBreakingVal") then { _enableWindowBreakingVal = 1; }; // Default True
if (isNil "_enableCampfireVal") then { _enableCampfireVal = 0; }; // Default False
if (isNil "_enableLeaderRestVal") then { _enableLeaderRestVal = 1; }; // Default True
if (isNil "_enableMovementHookVal") then { _enableMovementHookVal = 0; }; // Default False

// Konversi nilai 0/1 ke Boolean (true/false) untuk disimpan di HashMap
private _enableLooting = (_enableLootingVal == 1);
private _enableRepair = (_enableRepairVal == 1);
private _enableDriverDismount = (_enableDriverDismountVal == 1);
private _forceNoRetreat = (_forceNoRetreatVal == 1);
private _enableModuleSupportCalls = (_enableModuleSupportCallsVal == 1);
private _enableAmbientAnims = (_enableAmbientAnimsVal == 1);
private _enableWindowBreaking = (_enableWindowBreakingVal == 1);
private _enableCampfire = (_enableCampfireVal == 1);
private _enableLeaderRest = (_enableLeaderRestVal == 1);
private _enableMovementHook = (_enableMovementHookVal == 1);


// --- Buat HashMap _settingsCheckboxes HANYA SEKALI dengan SEMUA nilai --- <<< BAGIAN SEKITAR BARIS 39
// Pastikan sintaks Array [...] benar: [Key1, Value1, Key2, Value2, ...]
private _settingsCheckboxes = createHashMapFromArray [
    // Nilai Boolean dari argumen modul
    "EnableLooting", _enableLooting,
    "EnableRepair", _enableRepair,
    "EnableDriverDismount", _enableDriverDismount,
    "ForceNoRetreat", _forceNoRetreat,
    "EnableModuleSupportCalls", _enableModuleSupportCalls,
    "EnableAmbientAnims", _enableAmbientAnims,
    "EnableWindowBreaking", _enableWindowBreaking,
    "EnableCampfireCreation", _enableCampfire,
    "EnableSimpleLeaderRest", _enableLeaderRest,
    "EnableAdvancedMovementHook", _enableMovementHook,

    // Nilai Override (disimpan sebagai angka -1, 0, 1, atau 2)
    "AI_NoSwayOverride", _aiNoSwayOverride,
    "AI_RemoveStaminaOverride", _aiRemoveStaminaOverride,

    // Key default lama (bisa dihapus jika tidak dipakai lagi di skrip lain)
    "useCompliance", true,
    "useCourage", true,
    "useAdaptability", true,
    "useROE", true,
    "useMorale", true,
    "useCommunication", true,
    "useCooperation", true,
    "useProportionalForce", false,
    "useStressControl", true,
    "useLawsOfWar", false
];
// HashMap ini sekarang berisi SEMUA pengaturan yang relevan


// --- Identifikasi Unit Target ---
private _targetUnits = [];
if (count _units > 0) then {
    // Unit disinkronkan langsung
    _targetUnits = _units select {alive _x && !isPlayer _x && local _x};
} else {
    // Jika diaktifkan oleh trigger
    if (_activated) then {
        private _trigger = objNull; // Inisialisasi _trigger
        _trigger = vehicle _module; // Asumsi modul di dalam trigger
        if !(_trigger isKindOf "EmptyDetector") then { _trigger = objNull; };

        if (!isNull _trigger) then {
            _targetUnits = list _trigger select {alive _x && !isPlayer _x && local _x};
        };
    } else {
        // Modul tanpa sync/trigger: Terapkan global (Contoh: OPFOR lokal)
         _targetUnits = allUnits select {side _x == east && alive _x && !isPlayer _x && local _x};
         // diag_log "Havoc AI: Applying globally to OPFOR (no sync/trigger)";
    };
};


// --- Terapkan Pengaturan ke Setiap Unit Target ---
diag_log format ["Havoc AI: Initializing module. Difficulty: %1, Style: %2. Settings Applied: %3. Affecting %4 units.", _difficulty, _tacticalStyle, _settingsCheckboxes, count _targetUnits];

{
    // Panggil applyAISettings dengan HashMap yang sudah benar
    [_x, _difficulty, _tacticalStyle, _settingsCheckboxes] call HAVOCAI_fnc_applyAISettings;
    sleep 0.01; // Jeda kecil
} forEach _targetUnits;


true // Fungsi modul harus return true