/*
 * Havoc AI - Custom Waypoint Execution
 * File: fn_onWaypointScript.sqf
 */
params ["_unit", "_waypoint"]; // Unit yang mencapai WP, objek Waypoint

if (!local _unit || !alive _unit) exitWith {};

private _group = group _unit;
private _wpPos = waypointPosition _waypoint;
private _wpType = type _waypoint; // Dapatkan tipe waypoint dari config

diag_log format ["Havoc AI: Unit %1 (Group %2) reached waypoint %3 of type %4", _unit, _group, waypointIndex _waypoint, _wpType];

switch (_wpType) do {
    case "HAVOC_SearchBuilding": {
        // --- LOGIKA SUPER KOMPLEKS UNTUK AI CLEARING GEDUNG DI SINI ---
        diag_log "Havoc AI: Search Building logic needs implementation!";
    };
    case "HAVOC_ParachuteCargo": {
        // --- LOGIKA SUPER KOMPLEKS UNTUK EJECT KARGO DI SINI ---
        diag_log "Havoc AI: Parachute Cargo logic needs implementation!";
        // ... (Contoh logika parasut dari jawaban sebelumnya bisa dimasukkan di sini) ...
    };
    case "MOVE": { // Contoh: Modifikasi waypoint MOVE standar
        private _settings = _unit getVariable ["HAVOCAI_Settings", createHashMap];
        if (_settings getOrDefault ["EnableSimpleLeaderRest", true]) then {
            // Hanya lakukan jika ini leader dan grup punya > 1 anggota
            if (leader _group == _unit && count units _group > 1) then {
                 // Peluang acak untuk istirahat
                 if (random 100 < 30) then { // 30% chance
                     _unit switchMove "AmovPsitMstpSnonWnonDnon_ground"; // Leader duduk
                     _unit setVariable ["HAVOCAI_LeaderIsResting", true];
                     diag_log format ["Havoc AI: Leader %1 resting at WP %2.", _unit, waypointIndex _waypoint];

                     // Beri waypoint CYCLE sementara ke anggota lain
                     private _subordinates = units _group select {_x != _unit};
                     {
                         private _patrolWP = group _x addWaypoint [_wpPos, 0.1]; // WP baru setelah WP leader
                         _patrolWP setWaypointType "CYCLE";
                         _patrolWP setWaypointStatements ["true", ""]; // Selalu cycle
                         _patrolWP setWaypointCompletionRadius 30; // Radius patroli kecil
                         _patrolWP setWaypointBehaviour "AWARE";
                         _patrolWP setWaypointSpeed "LIMITED";
                         setCurrentWaypoint group _x; // Langsung jalankan WP cycle
                     } forEach _subordinates;

                     // Tunggu beberapa saat
                     private _restTime = 20 + random 25;
                     sleep _restTime;

                     // Leader berdiri lagi
                     _unit switchMove "";
                     _unit setVariable ["HAVOCAI_LeaderIsResting", false];
                     diag_log format ["Havoc AI: Leader %1 finished resting.", _unit];

                     // Hapus waypoint CYCLE anggota & perintahkan kembali ke WP grup utama
                     // (Ini bisa rumit, mungkin lebih mudah membiarkan grup lanjut ke WP berikutnya saja)
                     // Contoh hapus WP anggota (perlu hati-hati):
                     // {
                     //    if (currentWaypoint group _x != -1) then {
                     //        if (waypointType [group _x, currentWaypoint group _x] == "CYCLE") then {
                     //             deleteWaypoint (waypoints group _x select (currentWaypoint group _x));
                     //         };
                     //     };
                     //     // Perintahkan kembali ke formasi? Atau biarkan lanjut?
                     // } forEach _subordinates;

                     // Grup akan otomatis lanjut ke waypoint berikutnya setelah leader selesai & WP ini tercapai
                 };
            };
        };
    };
    default {
        // diag_log format ["Havoc AI: Default waypoint type %1 reached", _wpType];
    };
};

// Kembalikan true jika waypoint ini dianggap selesai oleh skrip
// Jika false, AI mungkin akan menunggu instruksi selanjutnya
true