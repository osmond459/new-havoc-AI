/*
    Enhanced AI Behavior Script for Arma 3
    Filename: enhanced_ai_behavior.sqf
    Description: Aims to make AI more aggressive, tactical, and aware based on user requirements.
    Execution: Spawned per AI unit via init field or init.sqf.
    Example Usage (Unit Init): nul = [this] execVM "scripts\enhanced_ai_behavior.sqf";
*/

params ["_unit"];

// --- Basic Checks ---
if (!local _unit) exitWith {}; // Run only where AI is local
if (!alive _unit) exitWith {};
if (isPlayer _unit) exitWith {}; // Don't run on players

private _group = group _unit;
private _isLeader = leader _group == _unit;

// --- Initial Skill & Settings ---
// Insane Skills (Adjust as needed, 1.0 is max)
_unit setSkill ["aimingAccuracy", 0.9]; // Akurasi bidikan
_unit setSkill ["aimingShake", 0.1];     // Getaran bidikan (lebih rendah lebih baik)
_unit setSkill ["aimingSpeed", 0.95];    // Kecepatan membidik
_unit setSkill ["spottingAbility", 0.9]; // Kemampuan melihat
_unit setSkill ["spottingDistance", 1.0]; // Jarak pandang (relatif terhadap base)
_unit setSkill ["courage", 1.0];          // Keberanian (tidak mudah kabur)
_unit setSkill ["commanding", 0.8];       // Skill memimpin (jika leader)
_unit setSkill ["general", 0.9];        // Skill umum
_unit setSkill ["reloadSpeed", 0.9];    // Kecepatan reload
_unit setSkill ["audible", 1.0];        // Kemampuan mendengar (jarak dengar maks)
_unit setSkill ["camouflage", 0.8];     // Kamuflase (lebih sulit terlihat)

// --- Behavior Settings ---
_unit setCombatMode "RED";          // Selalu engage musuh ("OPEN FIRE")
_unit setBehaviour "COMBAT";        // Perilaku agresif/tempur (menggantikan "AWARE" atau "STEALTH" saat kontak)
_unit setUnitPos "UP";              // Prioritaskan berdiri/berjongkok daripada tiarap kecuali ditekan
_unit allowFleeing 0;               // Larang AI kabur karena moral rendah
_unit enableAttack false;           // Biarkan skrip/engine mengontrol serangan, bukan AI logic default (eksperimental)
_unit setVariable ["NO_RETREAT", true, true]; // Custom flag

// --- Disable Unwanted Commands (Experimental) ---
// Ini sulit untuk sepenuhnya mematikan, tapi kita bisa mencoba membuatnya kurang relevan
// dengan mengatur combat mode & behaviour secara agresif.
// _group enableTeamWatchdog false; // Matikan "pengawasan" leader (bisa berefek aneh)
// _unit enableSentences false;   // Matikan beberapa suara AI (opsional)

// --- Event Handlers (Attached once) ---
if (isNil {_unit getVariable "AI_Behavior_Initialized"}) then {
    _unit setVariable ["AI_Behavior_Initialized", true, true];

    // EH Saat Melihat Musuh
    _unit addEventHandler ["KnownEnemy", {
        params ["_unit", "_target", "_knowledge"];
        _unit setCombatMode "RED";
        _unit setBehaviour "COMBAT";
        // Prioritaskan menembak kepala/badan (simulasi via akurasi tinggi)
        if (alive _target && {_knowledge > 2.5}) then { // Knows target well
             _unit doTarget _target;
             // Coba tembak pilot jika target di kendaraan udara
             _vehicle = vehicle _target;
             if (_vehicle isKindOf "Air" && {canFire _unit}) then {
                 private _crew = crew _vehicle;
                 if (count _crew > 0) then {
                     private _pilot = _crew select 0;
                     if (alive _pilot) then {
                          _unit forceTarget _pilot; // Paksa target pilot
                          _unit doFire _pilot; // Langsung tembak jika memungkinkan
                     };
                 } else {
                    // Jika tidak ada crew terlihat/mati, target mesin/badan
                     _unit doTarget _vehicle;
                     _unit doFire _vehicle;
                 };
             } else {
                 _unit doFire _target; // Tembak target biasa
             };
        };
    }];

    // EH Saat Musuh Terbunuh di Dekat
    _unit addEventHandler ["EnemyDetected", { /* Placeholder if needed */ }]; // Jarang dipakai
    _unit addEventHandler ["Killed", {
        params ["_unit", "_killer", "_instigator", "_useEffects"];
        // Bisa tambahkan logika jika AI dibunuh (misal notifikasi grup)
    }];

    // EH Saat Mendengar Tembakan Dekat (Untuk Counter Sniper / Reaksi)
    _unit addEventHandler ["FiredNear", {
        params ["_unit", "_shooter", "_distance", "_weapon", "_muzzle", "_ammo", "_gunner"];
        private _soundRange = 50; // Default range AI akan bereaksi secara konsisten
        private _silentThreshold = 2; // Jarak di mana silencer efektif total

        private _isSilent = (_weapon getNumber (configFile >> "CfgWeapons" >> _weapon >> "soundSilencer[]" select 1)) > 0.1; // Cek kasar apakah senjata punya peredam

        if (_isSilent && _distance <= _silentThreshold) then {
            // Sangat dekat & pakai peredam, mungkin AI tidak dengar (engine based)
        } else {
            if (!_isSilent && _distance > 20 && _distance <= _soundRange) then {
                 // Suara tidak jelas, AI bereaksi tapi mungkin tidak tahu arah pasti
                 _unit setCombatMode "YELLOW"; // Waspada
                 _unit setBehaviour "AWARE";
                 if (random 1 > 0.4) then { // 60% chance to look around/seek cover without pinpointing
                     _unit findCover;
                 };
                 // Script AI untuk "asal mencari" bisa ditambahkan di loop utama
            } else {
                 // Dengar jelas atau sangat dekat
                 _unit setCombatMode "RED";
                 _unit setBehaviour "COMBAT";
                 if (alive _shooter && knowsAbout _shooter < 2) then { // Jika tahu penembak tapi lokasi tdk pasti
                     _unit doSuppressiveFire (getPosATL _shooter); // Tembak ke arah umum
                 } else {
                     if (alive _shooter) then {
                         _unit doTarget _shooter; // Target jika tahu lokasi
                         _unit doFire _shooter;
                     };
                 };
                 _unit findCover; // Cari perlindungan
            };
        };
    }];

     // EH Untuk Mendeteksi Ranjau
     _unit addEventHandler ["MineDetected", {
         params ["_unit", "_mine", "_detector"];
         if (typeOf _unit in ["DemoSpecialist", "Engineer", "MineSpecialist"]) then { // Hanya role tertentu
             if ("ToolKit" in items _unit) then {
                 _unit revealMine _mine;
                 // Pergi dan jinakkan (bisa perlu pathfinding lebih baik)
                 _unit doMove (getPos _mine);
                 _unit action ["Defuse", _mine];
             };
         } else {
             _unit revealMine _mine; // Tandai di map saja
             // Unit lain hindari ranjau (default engine behavior)
         };
     }];

     // EH Untuk Pilot Keluar Kendaraan (Eject/Crash)
     _unit addEventHandler ["GetOut", {
         params ["_unit", "_vehicle", "_role", "_turret"];
         if (_vehicle isKindOf "Air" && {!alive _vehicle || damage _vehicle > 0.9}) then {
             // Pilot baru saja keluar dari pesawat/heli jatuh/rusak
             if (side _unit == side player) then { // Jika kawan
                 _unit setVariable ["NEEDS_RESCUE", true, true];
                 _unit sideChat "Pilot down! Requesting immediate evac at my position!";
                 // Script untuk mencari tempat sembunyi atau bergerak ke rally point
                 [_unit] spawn {
                     params ["_pilot"];
                     sleep 5; // Waktu untuk menjauh dari reruntuhan
                     private _hidePos = _pilot findEmptyPosition [10, 150, "LandVehicle"]; // Cari tempat sembunyi
                     if !(isNull _hidePos) then { _pilot doMove _hidePos; };
                     _pilot setBehaviour "STEALTH";
                     // Tunggu atau cari waypoint "rescue"
                     // Bisa tambahkan request radio periodik
                 };
             } else { // Jika musuh
                 // AI lain akan memburu pilot ini (default behavior jika terlihat)
                 // Bisa ditambahkan skrip pemburu khusus jika diperlukan
             };
         };
     }];

     // EH Untuk Naik Kendaraan (Pilot AI naik heli rescue)
     _unit addEventHandler ["GetIn", {
          params ["_unit", "_vehicle", "_role", "_turret"];
          if ((_unit getVariable ["NEEDS_RESCUE", false]) && (_vehicle isKindOf "Helicopter") && (_role == "Cargo")) then {
              _unit setVariable ["NEEDS_RESCUE", false, false]; // Sudah diselamatkan
              _unit sideChat "Boarding rescue chopper. Thanks for the lift!";
              // AI Pilot akan ikut heli (default behavior)
          };
          // Logika untuk driver kembali naik setelah clear
          if ((_unit getVariable ["DRIVER_DISMOUNTED", false]) && (_role == "Driver")) then {
                _unit setVariable ["DRIVER_DISMOUNTED", false, false];
          };
     }];
};


// --- Main Behavior Loop ---
while {alive _unit && local _unit} do {
    private _currentBehavior = behaviour _unit;
    private _currentTarget = currentTarget _unit;
    private _knowsAboutEnemy = knowsAbout _unit > 1.5; // Cek jika AI tahu ada musuh di sekitar
    private _enemiesNear = _unit nearEntities ["Man", 150]; // Cek musuh dalam radius 150m
    private _visibleEnemy = objNull;
    _enemiesNear = _enemiesNear select {side _x != side _unit && alive _x};

    // Cek musuh yang terlihat
    {
        if (_unit knowsAbout _x > 3.5) exitWith { _visibleEnemy = _x; }; // Tahu lokasi pasti
    } forEach _enemiesNear;

    // --- Combat Logic ---
    if !(isNull _visibleEnemy) then {
        _unit setCombatMode "RED";
        _unit setBehaviour "COMBAT";

        // --- CQB Logic (Basic) ---
        private _buildings = nearestObjects [getPos _unit, ["House", "Building"], 50];
        if (count _buildings > 0 && _unit distance _visibleEnemy < 50) then {
            // Jika ada musuh dekat dan ada bangunan
            private _currentBuilding = nearestBuilding _unit;
            if !(_currentBuilding isEqualTo objNull) && {!(_unit isInside _currentBuilding)} then {
                // Jika tidak di dalam gedung, coba masuk gedung terdekat *yang berbeda* dari anggota grup lain
                private _targetBuilding = objNull;
                {
                    private _occupied = false;
                    {
                        if (vehicle _x == _unit && {nearestBuilding _x isEqualTo _forEachIndex}) then { // Cek jika anggota grup lain sudah di gedung itu
                             _occupied = true; exitWith {};
                        };
                    } forEach units _group;

                    if (!_occupied) exitWith { _targetBuilding = _x; }; // Pilih gedung ini jika kosong
                } forEach _buildings;

                if !(isNull _targetBuilding) then {
                    // _unit moveInAny (selectRandom (_targetBuilding buildingPos -1)); // Pindah ke posisi random di dalam
                    _unit doMove (selectRandom (_targetBuilding buildingPos -1)); // Bergerak ke arah gedung
                    _unit setVariable ["CQB_MODE", true, true];
                } else {
                     _unit findCover; // Cari cover biasa jika semua gedung dekat terisi
                };

            } else { // Jika sudah di dalam gedung
                 // Cari posisi menembak (jendela, pintu) atau tunggu di tangga
                 private _buildingPositions = _currentBuilding buildingPos -1; // Semua posisi di dalam gedung
                 if (count _buildingPositions > 2) then {
                     private _ambushPos = selectRandom (_buildingPositions select {(_unit distance _x > 2) && // Jangan terlalu dekat posisi lama
                                                                                (lineIntersects [eyePos _unit, getPosATL _visibleEnemy, _unit, _currentBuilding] )}); // Cari posisi yg ada LoS tapi terhalang sedikit
                     if !(isNull _ambushPos) then {
                         _unit doMove _ambushPos;
                     } else {
                         // Tunggu di dekat tangga jika ada musuh di lantai berbeda? (Logika kompleks)
                         // Atau tembak dari jendela
                         _unit doFire _visibleEnemy;
                     };
                 } else {
                    _unit doFire _visibleEnemy; // Tembak saja jika posisi terbatas
                 };
            };
        } else { // Pertempuran di luar gedung / Jarak Menengah-Jauh
            _unit setVariable ["CQB_MODE", false, false];
            // Perilaku Tembak dan Sembunyi (Shoot and Scoot)
            if (random 1 > 0.4) then { // 60% chance to find new cover after firing
                _unit findCover;
                _unit doMove (getPos _unit findCover [getPos _unit, getPos _visibleEnemy]);
                sleep 2 + random 2; // Jeda simulasi
            };
             _unit doFire _visibleEnemy; // Tembak musuh

             // Gunakan AT/AA pada infantri? (Sangat situasional & berbahaya bagi kawan)
             // Ini tidak direkomendasikan tapi bisa dipaksa:
             // if (_unit hasWeapon "launch_RPG32_F" && _unit ammo "RPG32_F" > 0 && _unit distance _visibleEnemy > 30) then {
             //     _unit selectWeapon "launch_RPG32_F";
             //     _unit forceWeaponFire ["RPG32_F", ""]; // Tembak RPG (MODE KOSONGKAN!)
             // };
        };

        // Target Pilot / Mesin jika musuh di kendaraan udara
        _vehicle = vehicle _visibleEnemy;
        if (_vehicle isKindOf "Air" && canFire _unit) then {
             if (random 1 > 0.6) then { // 40% chance to prioritize pilot
                 private _crew = crew _vehicle;
                 if (count _crew > 0 && alive (_crew select 0)) then {
                     _unit forceTarget (_crew select 0);
                 } else {
                     _unit doTarget _vehicle; // Target badan jika pilot tidak bisa ditarget
                 };
             } else { // 60% chance target vehicle (engine etc implicitly)
                 _unit doTarget _vehicle;
             };
             _unit doFire (currentTarget _unit);
        };

         // Tembak target darat jika di kendaraan udara (Pesawat/Heli AI)
         if (_unit isKindOf "Air") then {
             if !(isNull _visibleEnemy) then {
                 _unit doTarget _visibleEnemy;
                 // Jika punya roket/bom dan target cocok (infantry/kendaraan/bangunan)
                 // Perlu logika tambahan untuk memilih senjata yg tepat
                 // _unit forceWeaponFire ["weapon_name", "mode"];
                 _unit doFire _visibleEnemy;

                 // Manuver terbang rendah/hindaran (Sangat Dasar)
                 if (terrainHeight ASL (getPosATL _unit) < 50 && speed _unit > 100) then {
                      // Coba terbang rendah jika sudah rendah & cepat
                      _unit flyInHeight (15 + random 15);
                 } else {
                      // Manuver hindaran dasar jika ada ancaman misil (perlu deteksi ancaman)
                      // if (incomingMissile _unit) then { _unit move (position _unit vectorAdd ((vectorDir _unit vectorCrossProduct [0,0,1]) vectorMultiply (200 * (selectRandom [-1,1])))); };
                 };
             };
         };


    } else { // Tidak ada musuh terlihat langsung
        _unit setVariable ["CQB_MODE", false, false];
        if (_knowsAboutEnemy) then { // Tahu ada musuh TAPI tidak terlihat
            _unit setCombatMode "YELLOW"; // Waspada
            _unit setBehaviour "AWARE";
            // Mencari penembak jitu / musuh tersembunyi
            if (isNil {_unit getVariable "lastKnownPos"}) then {
                 _unit setVariable ["lastKnownPos", [0,0,0]];
            };
            private _lastEnemyPos = locationPosition (selectBest (_unit call BIS_fnc_knownTargets)); // Dapatkan posisi musuh terakhir diketahui
            if (_lastEnemyPos distance (_unit getVariable "lastKnownPos") > 10) then { // Jika posisinya baru
                 _unit setVariable ["lastKnownPos", _lastEnemyPos];
                 // Bergerak hati-hati ke arah posisi terakhir atau cari cover lebih baik
                 if (random 1 > 0.5) then {
                    _unit doMove _lastEnemyPos;
                 } else {
                    _unit findCover;
                 };
            } else {
                // Tetap waspada atau patroli area dekat
                 if (random 1 > 0.7) then { _unit findCover; };
            };

        } else { // Tidak tahu ada musuh sama sekali
            // Kembali ke mode patroli normal atau waypoint
            if (_currentBehavior != "SAFE" && _currentBehavior != "AWARE") then {
                _unit setBehaviour "AWARE"; // Default behavior saat tidak kontak
            };
             // Jika patroli di hutan/malam
             if (surfaceIsWater (getPosATL _unit) == false && !isNil {vegetation _unit}) then { // Cek jika di darat & ada vegetasi? (Perlu fungsi cek vegetasi yg lebih baik)
                 if (daytime < 6 || daytime > 18) then { // Malam hari
                     if (hmd _unit == "") then { // Jika tidak punya NVG/TI
                         // Patroli lebih hati-hati & menyebar (jika leader, atur formasi WEDGE/ECHELON)
                         if (_isLeader) then { _group setFormation (selectRandom ["WEDGE", "ECHELON LEFT", "ECHELON RIGHT"]); };
                         _unit setSpeedMode "LIMITED"; // Jalan pelan
                     };
                 };
             };

             // Perilaku waypoint: Masuk rumah (Jika waypoint di dalam rumah)
             // Ini lebih baik dihandle dengan trigger atau skrip waypoint
             // Contoh dasar: if (currentWaypoint _group != -1 && {nearestBuilding (waypointPosition [_group, currentWaypoint _group]) distance (waypointPosition [_group, currentWaypoint _group]) < 5}) then { ... logika masuk rumah ... }
        };
    };

    // --- Logika Looting ---
    if (random 100 < 5) then { // Cek looting sesekali (5% chance per loop)
        private _nearbyCorpses = nearestObjects [_unit, ["Man"], 15] select {!alive _x && side _x != side _unit};
        if (count _nearbyCorpses > 0) then {
            private _corpse = selectRandom _nearbyCorpses;
            private _needsBetterWeapon = (primaryWeapon _unit == ""); // Atau cek jika senjata kurang bagus
            private _needsAmmo = (_unit ammo (currentWeapon _unit)) < 10;
            private _needsAT = count (weapons _unit select {_x isKindOf "LauncherCore"}) == 0 && {true}; // Cek jika ada ancaman kendaraan? (perlu logika tambahan)
            private _needsVest = (vest _unit == "");

            if (_needsVest && vest _corpse != "") then {
                 _unit removeVest _unit;
                 _unit addVest (vest _corpse);
                 //diag_log format ["%1 looted vest from %2", _unit, _corpse];
            };
             if (_needsBetterWeapon || _needsAmmo || _needsAT) then {
                 // Ambil senjata utama jika perlu ATAU jika itu AT/AA yg dibutuhkan
                 private _corpseWeapon = primaryWeapon _corpse;
                 if (_corpseWeapon != "" && (_needsBetterWeapon || (_needsAT && _corpseWeapon isKindOf "LauncherCore"))) then {
                     _unit addWeapon _corpseWeapon;
                     // Ambil magazine yang cocok
                     { if (_x in magazines _corpse) then { _unit addMagazine _x; } } forEach (getArray (configFile >> "CfgWeapons" >> _corpseWeapon >> "magazines"));
                     //diag_log format ["%1 looted weapon %2 from %2", _unit, _corpseWeapon, _corpse];
                 } else {
                     // Ambil amunisi untuk senjata saat ini jika perlu
                     if (_needsAmmo) then {
                         { if (_x isKindOf getText(configFile >> "CfgWeapons" >> currentWeapon _unit >> "magazines" select 0)) then { _unit addMagazine _x; } } forEach (magazines _corpse);
                         //diag_log format ["%1 looted ammo for %2 from %3", _unit, currentWeapon _unit, _corpse];
                     };
                 };
             };
        };
    };

    // --- Logika Driver Dismount ---
    if (_unit == driver (vehicle _unit) && vehicle _unit != _unit) then { // Jika AI adalah driver dan sedang di dalam kendaraan
        if !(isNull _visibleEnemy) && {_unit distance _visibleEnemy < 75} && {!(_unit getVariable ["DRIVER_DISMOUNTED", false])} then { // Jika lihat musuh dekat
             private _vehicle = vehicle _unit;
             unassignVehicle _unit;
             _unit leaveVehicle _vehicle;
             _unit setVariable ["DRIVER_DISMOUNTED", true, true]; // Tandai driver sudah turun
             // Cari perlindungan dekat kendaraan
             _unit findCover;
             _unit doMove (getPos _unit findCover [getPos _unit, getPos _visibleEnemy]);
        } else {
             // Jika musuh hilang/jauh dan driver tadi turun, kembali ke mobil
             if (isNull _visibleEnemy && (_unit getVariable ["DRIVER_DISMOUNTED", false])) then {
                 private _vehicle = _unit getVariable ["LAST_VEHICLE", objNull]; // Perlu simpan kendaraan terakhir saat turun
                 if !(isNull _vehicle) && {alive _vehicle} then {
                     _unit assignAsDriver _vehicle;
                     _unit moveInDriver _vehicle;
                     // Variabel DRIVER_DISMOUNTED akan direset oleh EH GetIn
                 };
             };
        };
    } else {
         // Simpan kendaraan terakhir jika driver baru saja turun
         if (_unit getVariable ["DRIVER_DISMOUNTED", false] && isNull (_unit getVariable ["LAST_VEHICLE", objNull])) then {
             _unit setVariable ["LAST_VEHICLE", vehicle _unit];
         };
    };

    // --- Logika Repair Kendaraan ---
    if (random 100 < 3 && {"ToolKit" in items _unit}) then { // Cek sesekali jika punya toolkit
        private _nearbyDamagedVehicles = nearestObjects [_unit, ["LandVehicle", "Air", "Ship"], 25] select {damage _x > 0.1 && damage _x < 0.9 && side _x == side _unit}; // Kendaraan kawan yg rusak tapi bisa diperbaiki
        if (count _nearbyDamagedVehicles > 0) then {
             private _vehicleToRepair = _nearbyDamagedVehicles select 0;
             if (isNull (crew _vehicleToRepair) || count (crew _vehicleToRepair) == 0) then { // Perbaiki jika kosong
                 _unit doMove getPos _vehicleToRepair;
                 _unit action ["Repair", _vehicleToRepair];
                 sleep 5; // Tunggu sebentar untuk aksi repair
                 // Setelah repair, bisa diprogram untuk menggunakannya jika kosong
                 // if (damage _vehicleToRepair < 0.2 && count (crew _vehicleToRepair) == 0) then { _unit moveInDriver _vehicleToRepair; };
             };
        };
    };


    sleep (1 + random 1); // Penundaan utama loop untuk performa
};

// --- Cleanup (jika diperlukan) ---
// Hapus EH jika unit mati atau skrip dihentikan
_unit removeAllEventHandlers "KnownEnemy";
_unit removeAllEventHandlers "FiredNear";
_unit removeAllEventHandlers "MineDetected";
// ... Hapus EH lainnya ...