/*
 * Havoc AI - Break Window
 * File: fn_breakWindow.sqf
 */
params ["_unit", "_windowPos"]; // _windowPos bisa posisi target atau jendela spesifik

if (!local _unit || !alive _unit) exitWith {};

private _settings = _unit getVariable ["HAVOCAI_Settings", createHashMap];
if !(_settings getOrDefault ["EnableWindowBreaking", true]) exitWith {}; // Keluar jika fitur dimatikan

private _window = nearestObject [_windowPos, "Window"]; // Cari jendela terdekat dari posisi target

if (isNull _window || damage _window >= 1) exitWith {}; // Keluar jika tidak ada jendela atau sudah pecah

// Perintahkan AI bergerak ke dekat jendela (jika belum)
if (_unit distance _window > 3) then {
    _unit doMove (getPos _window);
    // Mungkin perlu tunggu AI sampai
};

// Cek lagi jaraknya
if (_unit distance _window <= 3) then {
    // Pecahkan kaca
    _window setDamage [1, true]; // Argumen kedua (true) mungkin untuk efek visual/suara? Perlu dites.
    // Atau paksa tembak sekali ke jendela?
    // _unit forceWeaponFire [currentWeapon _unit, currentMuzzle _unit]; // Mungkin kurang tepat
    diag_log format ["Havoc AI: %1 broke window %2", _unit, _window];

    // Logika melompat lewat jendela SANGAT SULIT dan tidak direkomendasikan
    // Membutuhkan setVelocity dan penyesuaian rumit, rawan bug.
};
true;