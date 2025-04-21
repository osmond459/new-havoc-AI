// functions/CfgFunctions.hpp
class CfgFunctions {
    class HAVOCAI { // Tag utama mod Anda
        tag = "HAVOCAI"; // Prefix untuk memanggil fungsi (HAVOCAI_fnc_...)

        // Kategori untuk fungsi inti AI Behavior & Inisialisasi Modul
        class AIBehavior {
            file = "havoc_ai\functions"; // Lokasi file .sqf relatif dari root addon
            // Fungsi Inisialisasi & Pengaturan
            class initModule {
                postInit = 1; // Pastikan tersedia setelah init dasar game
                description = "Initializes the Havoc AI module logic.";
            };
            class applyAISettings {
                 description = "Applies Havoc AI settings and behavior script to a unit.";
            };
            // Fungsi Loop Utama AI
             class mainBehaviorLoop {
                 description = "Main loop controlling enhanced AI behavior.";
            };
            // Fungsi Sistem Bantuan
             class requestSupport {
                 description = "Handles the AI logic for requesting support.";
            };
            // Fungsi Efek AI (Sway/Stamina)
             class applyNoSway {
                 description = "Applies No Sway effect to a unit.";
             };
             class handleStamina {
                 description = "Handles damage event for stamina removal.";
             };
            // Fungsi Ambient AI Baru
            class playAmbientAnim {
                description = "Plays random ambient animation for AI.";
            };
            class breakWindow {
                description = "Makes AI attempt to break a nearby window.";
            };
            class createCampfire {
                description = "Makes AI attempt to create a campfire.";
            };
        }; // Akhir Kategori AIBehavior

        // Kategori Baru untuk fungsi terkait Cheat Menu & Player
        class Cheats {
            file = "havoc_ai\functions"; // Path bisa sama jika file .sqf di folder yang sama
            class initPlayerCheats {
                // postInit = 1; // Mungkin perlu postInit jika dipanggil sangat awal
                description = "Initializes player specific cheats and Event Handlers.";
            };
            class openCheatMenu {
                description = "Opens the cheat menu dialog.";
            };
            class teleportPlayer {
                description = "Teleports the player based on map click.";
            };
            class applyAICheat {
                description = "Applies selected cheats (Sway/Stamina) to AI of chosen sides via cheat menu.";
            };
        }; // Akhir Kategori Cheats

        // Kategori Baru untuk fungsi terkait Waypoint Kustom
        class Waypoints {
             file = "havoc_ai\functions";
             class onWaypointScript {
                 description = "Handles execution logic for custom Havoc AI waypoints.";
             };
        }; // Akhir Kategori Waypoints

    }; // Akhir class HAVOCAI
}; // Akhir class CfgFunctions