/*
 * Havoc AI - Play Ambient Animation
 * File: fn_playAmbientAnim.sqf
 */
params ["_unit"];
if (!local _unit || !alive _unit) exitWith {};

// Daftar animasi idle vanilla (bisa ditambah/dikurangi)
private _idleAnims = [
    "AmovPercMstpSnonWnonDnon", // Berdiri diam
    "AmovPercMstpSrasWpstDnon_gear", // Cek gear
    "AmovPercMstpSrasWpstDnon_details", // Lihat sekitar
    "AmovPercMstpSnonWnonDnon_exercisePushup", // Pushup (jika cocok)
    "AmovPsitMstpSnonWnonDnon_ground", // Duduk di tanah
    "AmovPknlMstpSnonWnonDnon_idle", // Berlutut diam
    "AmovPercMstpSnonWnonDnon_stretch", // Peregangan
    "Acts_CivilTalking_1" // Gestur bicara (efeknya mungkin kurang terlihat tanpa suara)
    // Tambahkan animasi lain yang sesuai...
];

// Daftar animasi bergerak pelan (jika ingin sedikit variasi)
// private _walkAnims = ["AmovPercMwlkSnonWnonDnon"];

// Pilih animasi acak
private _chosenAnim = selectRandom _idleAnims;

// Mainkan animasi
_unit switchMove _chosenAnim;

// Set timer kapan harus kembali ke normal atau ganti animasi
private _duration = 15 + random 20; // Diam selama 15-35 detik
_unit setVariable ["HAVOCAI_AmbientEndTime", time + _duration];
_unit setVariable ["HAVOCAI_IsInAmbientAnim", true]; // Tandai sedang animasi

// Jika ingin AI lain di dekatnya ikut bereaksi (misal gestur bicara)
/*
private _nearbyGroup = units group _unit select {alive _x && _x distance _unit < 5 && _x != _unit};
{
    if !(_x getVariable ["HAVOCAI_IsInAmbientAnim", false]) then {
        // AI teman ikut mainkan animasi idle/gesture lain
        _x switchMove (selectRandom ["Acts_CivilTalking_2", "AmovPercMstpSnonWnonDnon"]);
        _x setVariable ["HAVOCAI_AmbientEndTime", time + _duration - (random 5)];
        _x setVariable ["HAVOCAI_IsInAmbientAnim", true];
    };
} forEach _nearbyGroup;
*/

true;