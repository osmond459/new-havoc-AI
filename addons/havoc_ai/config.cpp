// config.cpp
class CfgPatches {
    class Havoc_AI {
        units[] = {"Havoc_ModuleAIBehavior"}; // Declare module class name
        weapons[] = {};
        requiredVersion = 1.60; // Example required version
        requiredAddons[] = {
            "A3_Modules_F",       // Required for module framework
            "A3_UI_F",            // Required for potential UI elements
            "cba_main",           // DIREKOMENDASIKAN AKTIF
            "cba_settings"        // DIREKOMENDASIKAN AKTIF
        };
        author = "Osmond_A";
        url = "https://your_optional_website_or_steam_workshop_link.com"; // Optional
        version = "1.0";
    };
};

// --- Function Definitions ---
#include "functions\CfgFunctions.hpp" // Include function definitions

// --- Zeus Module Category ---
class CfgFactionClasses {
    class HavocAI_Modules {
        displayName = "Havoc AI"; // Category name in Eden Editor
        priority = 2; // Display order priority
        side = 7; // Neutral (no specific side)
    };
};

// --- Custom Waypoint Definitions ---
class CfgWaypoints {
    class Placement; // Base waypoint class
    class HAVOC_SearchBuilding : Placement { // Nama unik waypoint Anda
        displayName = "Havoc: Search Building"; // Nama di editor
        icon = "\a3\ui_f\data\map\waypoints\move_ca.paa"; // Contoh ikon
        script = "\havoc_ai\functions\fn_onWaypointScript.sqf"; // Sesuaikan path jika perlu
    };
    class HAVOC_ParachuteCargo : Placement {
        displayName = "Havoc: Parachute Cargo";
        icon = "\a3\ui_f\data\map\waypoints\transport_unload_ca.paa"; // Contoh ikon
        script = "\havoc_ai\functions\fn_onWaypointScript.sqf"; // Sesuaikan path jika perlu
    };
};

// --- Zeus/Eden Module Definition ---
class CfgVehicles {
    class Logic; // Base class for modules
    class Module_F: Logic {};

    class Havoc_ModuleAIBehavior: Module_F {
        scope = 2; // Visible in Eden Editor (0=hidden, 1=virtual, 2=visible)
        displayName = "Havoc AI Behavior Initializer"; // Module name in Eden
        icon = "havoc_ai\module_logo.paa"; // Pastikan file ini ada atau ganti path
        category = "HavocAI_Modules"; // Assign to custom category

        // --- Module Execution ---
        function = "HAVOCAI_fnc_initModule";
        functionPriority = 1;
        isGlobal = 1;
        isTriggerActivated = 1;
        isDisposable = 0;
        curatorCanAttach = 1;

        // --- Module Arguments ---
        class Arguments {
            // --- Pengaturan Inti (Tetap Dropdown) ---
            class Difficulty {
                displayName = "AI Difficulty";
                description = "Sets the core skill level and aggression.";
                typeName = "NUMBER";
                class values {
                    class Medium { name = "Medium"; value = 0; default = 0; };
                    class Hard   { name = "Hard";   value = 1; };
                    class Insane { name = "Insane (Brutal)"; value = 2; };
                };
            };
             class TacticalStyle {
                displayName = "Tactical Style";
                description = "Influences AI overall combat approach (subtle effects).";
                typeName = "NUMBER";
                class values {
                    class Default   { name = "Default Balanced"; value = 0; default = 0; };
                    class Guerilla  { name = "Guerilla Tactics"; value = 1; };
                    class Blitzkrieg{ name = "Blitzkrieg Assault"; value = 2; };
                    class Kamikaze  { name = "Kamikaze Charge"; value = 3; };
                    class SunTzu    { name = "Sun Tzu Inspired"; value = 4; };
                };
            };

            // --- Pengaturan Perilaku Dasar (Diubah ke Dropdown Enabled/Disabled) ---
            class EnableLooting {
                displayName = "Enable Looting";
                description = "Allow AI to loot weapons, ammo, or gear from enemy corpses.";
                typeName = "NUMBER"; // <<< DIUBAH
                class values {
                    class Disabled { name = "Disabled"; value = 0; };
                    class Enabled  { name = "Enabled";  value = 1; default = 1; }; // Default: Enabled
                };
            };
            class EnableRepair {
                displayName = "Enable Vehicle Repair";
                description = "Allow AI with Toolkits to attempt repairs on nearby friendly damaged vehicles.";
                typeName = "NUMBER"; // <<< DIUBAH
                class values {
                    class Disabled { name = "Disabled"; value = 0; };
                    class Enabled  { name = "Enabled";  value = 1; default = 1; }; // Default: Enabled
                };
            };
            class EnableDriverDismount {
                displayName = "Enable Driver Combat Dismount";
                description = "Allow AI vehicle drivers to dismount and engage nearby enemies.";
                typeName = "NUMBER"; // <<< DIUBAH
                class values {
                    class Disabled { name = "Disabled"; value = 0; };
                    class Enabled  { name = "Enabled";  value = 1; default = 1; }; // Default: Enabled
                };
            };
            class EnableModuleSupportCalls {
                displayName = "Enable AI Support Calls (Module Specific)";
                description = "Enable/disable automatic support calls specifically for units affected by THIS module instance. Overrides global Addon Option if unchecked.";
                typeName = "NUMBER"; // <<< DIUBAH
                class values {
                    class Disabled { name = "Disabled"; value = 0; };
                    class Enabled  { name = "Enabled";  value = 1; default = 1; }; // Default: Enabled
                };
            };
            class ForceNoRetreat {
                displayName = "Force No Retreat/Fleeing";
                description = "Force AI to never retreat or flee, overriding Courage/Difficulty settings. Uncheck to allow normal fleeing behavior.";
                typeName = "NUMBER"; // <<< DIUBAH
                class values {
                    class Disabled { name = "Disabled (Allow Fleeing)"; value = 0; default = 0; }; // Default: Disabled (boleh kabur)
                    class Enabled  { name = "Enabled (Force No Retreat)";  value = 1; };
                };
            };

            // --- Pengaturan Ambient AI Behavior (Diubah ke Dropdown Enabled/Disabled) ---
            class EnableAmbientAnims {
                displayName = "Enable Ambient Animations";
                description = "Allow AI to play idle animations (sit, chat gestures) when not in combat or moving.";
                typeName = "NUMBER"; // <<< DIUBAH
                class values {
                    class Disabled { name = "Disabled"; value = 0; };
                    class Enabled  { name = "Enabled";  value = 1; default = 1; }; // Default: Enabled
                };
            };
            class EnableWindowBreaking {
                displayName = "Enable Window Breaking";
                description = "Allow AI to attempt breaking windows for entry/shooting (basic implementation).";
                typeName = "NUMBER"; // <<< DIUBAH
                class values {
                    class Disabled { name = "Disabled"; value = 0; };
                    class Enabled  { name = "Enabled";  value = 1; default = 1; }; // Default: Enabled
                };
            };
             class EnableCampfireCreation {
                displayName = "Enable Campfire Creation";
                description = "Allow AI to create a campfire when idle at night in safe conditions (simple implementation).";
                typeName = "NUMBER"; // <<< DIUBAH
                class values {
                    class Disabled { name = "Disabled"; value = 0; default = 0; }; // Default: Disabled
                    class Enabled  { name = "Enabled";  value = 1; };
                };
            };
            class EnableSimpleLeaderRest {
                displayName = "Enable Simple Leader Rest at Waypoint";
                description = "At certain waypoints, leader may briefly rest while subordinates 'patrol' nearby.";
                typeName = "NUMBER"; // <<< DIUBAH
                class values {
                    class Disabled { name = "Disabled"; value = 0; };
                    class Enabled  { name = "Enabled";  value = 1; default = 1; }; // Default: Enabled
                };
            };
            class EnableAdvancedMovementHook {
                displayName = "[HOOK] Enable Advanced Movement";
                description = "ATTENTION: Requires separate movement mod (e.g., Enhanced Movement)! Attempts to use external mod functions for climbing/vaulting if detected. Havoc AI does NOT provide this movement itself.";
                typeName = "NUMBER"; // <<< DIUBAH
                class values {
                    class Disabled { name = "Disabled"; value = 0; default = 0; }; // Default: Disabled
                    class Enabled  { name = "Enabled";  value = 1; };
                };
            };

            // --- Pengaturan Override Global (Tetap Dropdown) ---
            class AI_NoSwayOverride {
                displayName = "AI No Sway (Module Override)";
                description = "Override global Addon Option for AI No Sway specifically for units affected by THIS module instance.";
                typeName = "NUMBER";
                class values {
                    class Default { name = "Use Global Setting"; value = -1; default = -1;};
                    class Normal  { name = "0% (Normal)"; value = 0; };
                    class Reduced { name = "50% (Reduced Recoil)"; value = 1; };
                    class NoSway  { name = "100% (No Aim Sway)"; value = 2; };
                };
            };
            class AI_RemoveStaminaOverride {
                displayName = "AI Remove Stamina (Module Override)";
                description = "Override global Addon Option for AI Remove Stamina specifically for units affected by THIS module instance.";
                typeName = "NUMBER";
                 class values {
                    class Default { name = "Use Global Setting"; value = -1; default = -1;};
                    class Off     { name = "Stamina Normal"; value = 0; };
                    class On      { name = "Remove Stamina"; value = 1; };
                };
            };

        }; // <- Penutup class Arguments

        // --- Module Description ---
        class ModuleDescription {
            description = "Initializes Havoc AI behavior enhancements on synced units or trigger-activated units. Configure difficulty and tactical style.";
            sync[] = {"AnyUnit", "EmptyDetector"}; // Can sync to Units or Triggers/Area Markers
        }; // <- Penutup class ModuleDescription

    }; // <- Penutup class Havoc_ModuleAIBehavior
}; // <- Penutup class CfgVehicles

// --- Addon Settings (Example using custom class, CBA is better) ---
class CfgHavocAISettings {
    // ... (isi CfgHavocAISettings) ...
};

// --- (Optional) UI Dialog Definition ---
// #include "ui\settings_dialog.hpp" // Baris ini dibiarkan sesuai permintaan Anda