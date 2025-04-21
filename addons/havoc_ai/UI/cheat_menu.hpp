// ui/cheat_menu.hpp

#include "\a3\ui_f\hpp\defineCommon.inc" // Common UI definitions

#define HAVOC_CHEAT_IDD 84100 // IDD unik untuk dialog

class HAVOC_CheatMenu {
    idd = HAVOC_CHEAT_IDD;
    movingEnable = true;
    enableSimulation = true; // Biarkan game jalan di background
    onLoad = "uiNamespace setVariable ['HAVOCAI_CheatDialog', _this select 0];"; // Simpan referensi dialog
    onUnload = "uiNamespace setVariable ['HAVOCAI_CheatDialog', displayNull];"; // Hapus referensi

    class controlsBackground {
        class Background: RscText {
            idc = -1;
            x = safezoneX + safezoneW * 0.25;
            y = safezoneY + safezoneH * 0.20;
            w = safezoneW * 0.50;
            h = safezoneH * 0.60;
            colorBackground[] = {0.1, 0.1, 0.1, 0.8}; // Background gelap transparan
        };
         class Title: RscText {
            idc = -1;
            text = "Havoc Suite - Tools"; // Judul Dialog
            x = safezoneX + safezoneW * 0.25;
            y = safezoneY + safezoneH * 0.18;
            w = safezoneW * 0.50;
            h = 0.04;
            colorBackground[] = {0.2, 0.5, 0.8, 0.9}; // Warna header
            style = ST_CENTER;
            sizeEx = GUI_GRID_H * 1.2;
        };
    };

    class controls {
        // --- Tombol Dasar ---
        class Btn_Close: RscButtonMenuCancel {
            text = "Close";
            x = safezoneX + safezoneW * 0.70; // Pojok kanan atas
            y = safezoneY + safezoneH * 0.18;
            w = safezoneW * 0.05;
            h = 0.04;
        };
        class Btn_Arsenal: RscButtonMenu {
            idc = 1001;
            text = "Virtual Arsenal";
            x = safezoneX + safezoneW * 0.26;
            y = safezoneY + safezoneH * 0.25;
            w = safezoneW * 0.15;
            h = 0.05;
            action = "closeDialog 0; [] call BIS_fnc_arsenal;"; // Panggil VA
        };
         class Btn_Garage: RscButtonMenu {
            idc = 1002;
            text = "Virtual Garage";
            x = safezoneX + safezoneW * 0.26;
            y = safezoneY + safezoneH * 0.31;
            w = safezoneW * 0.15;
            h = 0.05;
            action = "closeDialog 0; [] call BIS_fnc_garage;"; // Panggil VG
        };
         class Btn_TeleportInfo: RscText {
             idc = -1;
             text = "Map Teleport: ALT + Left Click on Map";
             x = safezoneX + safezoneW * 0.26;
             y = safezoneY + safezoneH * 0.37;
             w = safezoneW * 0.20;
             h = 0.04;
             sizeEx = GUI_GRID_H * 0.8;
         };

         // --- Player Cheats ---
         class Chk_GodMode: RscCheckbox {
             idc = 2001;
             tooltip = "Makes the player invincible.";
             x = safezoneX + safezoneW * 0.26;
             y = safezoneY + safezoneH * 0.45;
             w = 0.03; // Ukuran checkbox
             h = 0.04;
             // Action perlu diatur via script onLoad atau button
         };
         class Lbl_GodMode: RscText {
             idc = -1;
             text = "Player God Mode";
             x = safezoneX + safezoneW * 0.29;
             y = safezoneY + safezoneH * 0.45;
             w = safezoneW * 0.15;
             h = 0.04;
         };

         // --- AI Cheats Section ---
         class Title_AICheats: RscText {
             idc = -1;
             text = "AI Cheat Application:";
             x = safezoneX + safezoneW * 0.50;
             y = safezoneY + safezoneH * 0.25;
             w = safezoneW * 0.24;
             h = 0.04;
             sizeEx = GUI_GRID_H * 0.9;
         };
         // Checkbox Faksi
         class Chk_AI_BLUFOR: RscCheckbox { idc = 3001; x = safezoneX + safezoneW * 0.51; y = safezoneY + safezoneH * 0.30; w = 0.03; h = 0.04; };
         class Lbl_AI_BLUFOR: RscText { text = "BLUFOR"; x = safezoneX + safezoneW * 0.54; y = safezoneY + safezoneH * 0.30; w = 0.1; h = 0.04; };
         class Chk_AI_OPFOR: RscCheckbox { idc = 3002; x = safezoneX + safezoneW * 0.51; y = safezoneY + safezoneH * 0.35; w = 0.03; h = 0.04; };
         class Lbl_AI_OPFOR: RscText { text = "OPFOR"; x = safezoneX + safezoneW * 0.54; y = safezoneY + safezoneH * 0.35; w = 0.1; h = 0.04; };
         class Chk_AI_INDFOR: RscCheckbox { idc = 3003; x = safezoneX + safezoneW * 0.51; y = safezoneY + safezoneH * 0.40; w = 0.03; h = 0.04; };
         class Lbl_AI_INDFOR: RscText { text = "INDEPENDENT"; x = safezoneX + safezoneW * 0.54; y = safezoneY + safezoneH * 0.40; w = 0.1; h = 0.04; };

         // Tombol Apply AI Cheats
         class Btn_ApplyAISwayNone: RscButtonMenu {
             idc = 4001; text = "Apply AI Sway: None";
             x = safezoneX + safezoneW * 0.51; y = safezoneY + safezoneH * 0.48; w = 0.23; h = 0.04;
             action = "[0] call HAVOCAI_fnc_applyAICheat;"; // 0 = No Sway
         };
          class Btn_ApplyAISway50: RscButtonMenu {
             idc = 4002; text = "Apply AI Sway: 50% Recoil";
             x = safezoneX + safezoneW * 0.51; y = safezoneY + safezoneH * 0.53; w = 0.23; h = 0.04;
             action = "[1] call HAVOCAI_fnc_applyAICheat;"; // 1 = Sway 50%
         };
          class Btn_ApplyAISway100: RscButtonMenu {
             idc = 4003; text = "Apply AI Sway: 100% No Aim";
             x = safezoneX + safezoneW * 0.51; y = safezoneY + safezoneH * 0.58; w = 0.23; h = 0.04;
             action = "[2] call HAVOCAI_fnc_applyAICheat;"; // 2 = Sway 100%
         };
         class Btn_ApplyAIStaminaOn: RscButtonMenu {
             idc = 4004; text = "Apply AI No Stamina: ON";
             x = safezoneX + safezoneW * 0.51; y = safezoneY + safezoneH * 0.65; w = 0.23; h = 0.04;
              action = "[3] call HAVOCAI_fnc_applyAICheat;"; // 3 = No Stamina ON
         };
         class Btn_ApplyAIStaminaOff: RscButtonMenu {
             idc = 4005; text = "Apply AI No Stamina: OFF";
             x = safezoneX + safezoneW * 0.51; y = safezoneY + safezoneH * 0.70; w = 0.23; h = 0.04;
             action = "[4] call HAVOCAI_fnc_applyAICheat;"; // 4 = No Stamina OFF
         };

         // --- Zeus/Achilles Placeholder ---
         class Lbl_ZeusInfo: RscText {
            idc = -1;
            text = "Note: Live Zeus/Achilles editing features are highly complex and not included. Use dedicated mods.";
            x = safezoneX + safezoneW * 0.26; y = safezoneY + safezoneH * 0.75;
            w = safezoneW * 0.48; h = 0.04;
            colorText[] = {1, 0.7, 0.7, 1}; // Warna teks peringatan
            sizeEx = GUI_GRID_H * 0.7;
         };
    };
};