// ui/settings_dialog.hpp - Example Structure (Requires much more detail)
class HavocAI_SettingsDialog {
    idd = 12345; // Unique IDD
    movingEnable = true;

    class controlsBackground {
        class Background: RscText { /* ... background control ... */ };
        class Title: RscText { text = "Havoc AI Settings"; /* ... title ... */ };
    };

    class controls {
        // --- Difficulty ---
        class DifficultyLabel: RscText { text = "Difficulty:"; /* ... */ };
        class DifficultyCombo: RscCombo { idc = 101; /* ... defines combo box ... */ };

        // --- Tactical Style ---
        class StyleLabel: RscText { text = "Tactical Style:"; /* ... */ };
        class StyleCombo: RscCombo { idc = 102; /* ... */ };

        // --- Checkboxes ---
        class ComplianceLabel: RscText { text = "Behavior Traits:"; /* ... */ };
        class ComplianceCheck: RscCheckbox { idc = 201; tooltip = "Follow orders strictly?"; /* ... */ };
        class ComplianceText: RscText { text = "Compliance"; /* ... next to checkbox ... */ };

        class CourageCheck: RscCheckbox { idc = 202; tooltip = "Resist fleeing?"; /* ... */ };
        class CourageText: RscText { text = "Courage"; /* ... */ };

        // ... (Add ALL other checkboxes: Adaptability, ROE, Morale, etc.) ...

        // --- Buttons ---
        class OkButton: RscButtonMenuOK { /* ... OK button ... */ };
        class CancelButton: RscButtonMenuCancel { /* ... Cancel button ... */ };
    };
};