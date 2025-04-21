# Havoc AI

**Author:** Osmond_A
**Version:** 1.0 (Example)
**Updated:** April 21, 2025 (Example)

## General Description

Havoc AI is a mod for Arma 3 that aims to enhance and add variety to the behavior of AI (Artificial Intelligence) units, providing a more dynamic and challenging gameplay experience. This mod offers various settings configurable through the Eden Editor Module and the Addon Options menu (requires CBA_A3).

In addition to basic behavior enhancements, this mod includes extra features like an automatic AI support call system, options to reduce/eliminate weapon sway and stamina (for AI and Player), and a basic cheat menu for testing or specific scenarios.

**IMPORTANT:** This mod is still under active development. Some features (especially highly advanced AI behaviors and the support system) might still be basic or require further refinement.

## Key Features

* **AI Behavior Enhancements:**
    * Configurable Difficulty (Skill) and Tactical Style (Aggressive, Guerilla, etc.) via Eden Module.
    * Additional Behaviors toggleable via Module: Looting, Vehicle Repair, Driver Combat Dismount, Force No Retreat.
    * (Basic) Ambient Behavior: AI can play idle animations (sit, gestures) when safe.
    * (Basic) Environmental Interaction: AI can attempt to break windows, create campfires (if enabled).
    * (Basic) Waypoint Behavior: Leader can briefly rest at certain waypoints.
* **AI Support Call System (Basic):**
    * AI can automatically attempt to call support units (CAS, Heli, Armor, Artillery) that *already exist in the mission* when under pressure.
    * Configurable via Addon Options (Enable/Disable, Cooldown, Search Radius, Priority).
    * **Note:** The AI's ability to find the *right* and *idle* support units, and their behavior after being called, is still under development and might require manually tagging support units in the mission (e.g., via variable names) for best results.
* **No Sway & Stamina Options:**
    * Separate settings to reduce (50% recoil) or eliminate (100% aim) weapon sway for AI and Player.
    * Separate settings to remove stamina limitations for AI and Player.
    * Configurable via Addon Options (CBA_A3).
* **Basic Cheat Menu ("Havoc Suite"):**
    * Accessible while the map is open by pressing **CTRL + SHIFT + M** (default, configurable).
    * Quick access buttons for Virtual Arsenal and Virtual Garage.
    * Player Teleport to map location with **ALT + Left Click**.
    * Player God Mode toggle.
    * Options to apply No Sway / No Stamina cheats to all AI of specific factions (BLUFOR, OPFOR, INDEPENDENT).
    * **Note:** Does NOT include live world/unit editing features like Zeus or Achilles.
* **Custom Waypoints (Definitions Only):**
    * Adds "Havoc: Search Building" and "Havoc: Parachute Cargo" waypoints to the Eden Editor.
    * **IMPORTANT:** The execution logic for the AI to actually perform these actions **is not implemented** yet and requires advanced scripting in the `fn_onWaypointScript.sqf` file.

## Dependencies

* **Required:**
    * **CBA_A3 (Community Base Addons):** Needed for Addon Options, Keybinds, and other functions. Ensure CBA_A3 is active and loaded *before* Havoc AI.
* **Optional:**
    * **Enhanced Movement (or similar mod):** Required ONLY if you enable the `[HOOK] Enable Advanced Movement` option in the Eden module. Havoc AI mod itself does NOT provide parkour/climbing capabilities. This hook only attempts to call functions from an external movement mod if detected.

## Installation

1.  Download the `@HavocAI` mod folder.
2.  Place the `@HavocAI` folder into your main Arma 3 directory (where `arma3_x64.exe` is located).
3.  Enable `@HavocAI` and `CBA_A3` via the Arma 3 Launcher. Ensure `CBA_A3` is higher in the load order (loaded first).

## Usage

1.  **Eden Editor Module:**
    * In the Eden editor, go to Modules (F5).
    * Find the "Havoc AI" category.
    * Place the "Havoc AI Behavior Initializer" module on the map.
    * Sync (F5) the module to the AI units or groups you want to affect. You can also place it inside a trigger and set the trigger to activate it.
    * Double-click the module to configure specific attributes/settings for the affected units (Difficulty, Tactical Style, other behavioral options).
2.  **Addon Options:**
    * In the game's main menu or pause menu, go to **Options -> Addon Options**.
    * Select the "Havoc AI Settings" tab.
    * Configure global settings like the AI Support System, global No Sway/Stamina options, and cheat keybind activation.
3.  **Cheat Menu:**
    * While in-game, open the map (default M key).
    * Press the **CTRL + SHIFT + M** key combination (ensure the keybind is enabled in Addon Options).
    * Use the buttons in the dialog for VA, VG, God Mode, or applying cheats to AI factions.
    * To teleport, hold **ALT** then **Left Click** on the desired map location.

## Compatibility

* This mod is designed to be compatible with Arma 3 Vanilla units and vehicles.
* In theory, it should be compatible with major content mods like **CUP (Units, Vehicles, Weapons, Terrains)** and **RHS (AFRF, USAF, GREF, SAF)** as it focuses on modifying base AI behavior.
* However, full compatibility testing with all mod combinations has not been performed. Conflicts with other AI behavior mods or complex mission scripts might occur. Please report any incompatibilities found.

## Known Issues / Limitations

* **Advanced AI Behavior:** Implementation of tactics like CQB, sniping, smart cover usage, air maneuvers, and other complex behaviors might be basic compared to dedicated AI overhaul mods (like VCOM AI, LAMBS - though these might conflict).
* **Support Call System:** This feature is basic. The AI's ability to find truly *idle* and *suitable* support units, and task them effectively, needs significant refinement. Using specific variable names for support units in the mission might be recommended.
* **Custom Waypoints:** The "Search Building" and "Parachute Cargo" waypoints **do not function** logically yet. Only their definitions exist to make them appear in the editor.
* **Cheat Menu:** There are **no** live editing features like Zeus/Achilles. Use those mods if needed.
* **Performance:** Enabling many features, especially with a large number of AI, might impact game performance (FPS). Configure settings reasonably.
* **Parkour/Climbing:** This feature is **not provided** by Havoc AI. There is only an optional hook for external mods.

## Future Plans (Example)

* Refinement of AI Support Call logic.
* Basic implementation for custom waypoints.
* Addition of other configuration options.
* Bug fixes and performance optimizations.

## Credits

* **Author:** Osmond_A
* **Thanks To:** The Arma 3 Modding Community, Bohemia Interactive, CBA Team.

---