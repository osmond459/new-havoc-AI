// cba_settings.sqf - Pengaturan untuk Havoc AI Addon Options

// Pastikan hanya dijalankan sekali
if !(isNil "havocai_settings_defined") exitWith {};
havocai_settings_defined = true;

// --- Kategori Utama ---
force forceSettingsCategory "HAVOCAI_Settings_Category";
// Berikan nama yang akan muncul di daftar kategori utama Addon Options
// Anda bisa tambahkan displayName di sini jika kategori lain juga menggunakan force forceSettingsCategory
// Contoh: ["HAVOCAI_Settings_Category", "Havoc AI Settings"] call CBA_fnc_addSettingsCategory;
// Tapi jika hanya satu kategori utama, nama addon biasanya cukup.

// --- Sub Kategori: AI Support System ---
force forceSettingsSubcategory "HAVOCAI_Settings_Support";
// Berikan nama untuk sub-kategori ini
["HAVOCAI_Settings_Support", "AI Support System"] call CBA_fnc_addSettingsSubcategory;

// Aktifkan/Nonaktifkan Sistem Bantuan AI
["havocai_enableSupportCalls", "CHECKBOX", ["Enable AI Automatic Support Calls", "Allow Havoc AI units to automatically request support when under pressure."], "Havoc AI", false, true] call CBA_fnc_addSetting;

// Cooldown Panggilan Bantuan (detik)
["havocai_supportCallCooldown", "SLIDER", ["Support Call Cooldown (seconds)", "Minimum time between support requests by the same AI unit."], "Havoc AI", [60, 1800, 300, 0], true] call CBA_fnc_addSetting;

// Radius Pencarian Unit Bantuan (meter)
["havocai_supportSearchRadius", "SLIDER", ["Support Search Radius (meters)", "How far the AI looks for available support units."], "Havoc AI", [1000, 10000, 5000, 0], true] call CBA_fnc_addSetting;

// Prioritas Jenis Bantuan
["havocai_supportPriority", "COMBO", ["Support Type Priority", "Which type of support AI prefers if multiple are available."], "Havoc AI", [["CAS", "Helicopter", "Armor", "Artillery/Mortar"], ["CAS", "Helicopter", "Armor", "Artillery"], 0], true] call CBA_fnc_addSetting;


// --- Sub Kategori: AI Enhancements (Sway & Stamina) ---
force forceSettingsSubcategory "HAVOCAI_Settings_AI_Enhance";
["HAVOCAI_Settings_AI_Enhance", "AI Enhancements"] call CBA_fnc_addSettingsSubcategory;

["havocai_aiNoSwayLevel", "COMBO", ["AI Weapon Sway Reduction", "Reduces weapon sway for all AI affected by Havoc AI module or global settings.\n0% = Normal Sway\n50% = Reduced Sway (Recoil Only)\n100% = No Sway (Aim Coef)"], "Havoc AI", [["0% (Normal)", "50% (Reduced Recoil)", "100% (No Aim Sway)"], [0, 1, 2], 0], true] call CBA_fnc_addSetting; // Dihilangkan scriptOnChange sementara

["havocai_aiRemoveStamina", "CHECKBOX", ["Enable AI Remove Stamina", "Removes stamina limitations for all AI affected by Havoc AI module or global settings."], "Havoc AI", false, true] call CBA_fnc_addSetting; // Dihilangkan scriptOnChange sementara


// --- Sub Kategori: Player Enhancements (Sway & Stamina) ---
force forceSettingsSubcategory "HAVOCAI_Settings_Player_Enhance";
["HAVOCAI_Settings_Player_Enhance", "Player Enhancements"] call CBA_fnc_addSettingsSubcategory;

["havocai_playerNoSwayLevel", "COMBO", ["Player Weapon Sway Reduction", "Reduces weapon sway for the Player.\n0% = Normal Sway\n50% = Reduced Sway (Recoil Only)\n100% = No Sway (Aim Coef)"], "Havoc AI", [["0% (Normal)", "50% (Reduced Recoil)", "100% (No Aim Sway)"], [0, 1, 2], 0], false, { // false = setting per client
    // Jalankan fungsi untuk apply ke player saat setting diubah
    [player, _this] call HAVOCAI_fnc_applyNoSway;
}] call CBA_fnc_addSetting;

["havocai_playerRemoveStamina", "CHECKBOX", ["Enable Player Remove Stamina", "Removes stamina limitations for the Player."], "Havoc AI", false, false, { // false = setting per client
    // Trigger update pada HandleDamage EH (biasanya otomatis terbaca saat EH jalan)
     if (_this) then {
         hintSilent "Player No Stamina: ON"; // Feedback
     } else {
         hintSilent "Player No Stamina: OFF";
         player setStamina 1; // Kembalikan stamina jika dimatikan
     };
}] call CBA_fnc_addSetting;


// --- Sub Kategori: Cheats ---
force forceSettingsSubcategory "HAVOCAI_Settings_Cheats";
["HAVOCAI_Settings_Cheats", "Cheat System"] call CBA_fnc_addSettingsSubcategory;

["havocai_cheatEnableKeybind", "CHECKBOX", ["Enable Cheat Menu Keybind", "Allows opening the cheat menu using the configured keybind when the map is open."], "Havoc AI", true, false] call CBA_fnc_addSetting; // Default aktif, per client


// Kembali ke kategori default (jika perlu di akhir)
// force forceSettingsCategory "Default";