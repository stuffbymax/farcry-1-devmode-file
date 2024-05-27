--System:ExecuteCommand("load_game");           -- note: for executing this script as a console command (e.g. edit script, then re-load game to test script)

cl_display_hud = 1
cl_drunken_cam = 0
ThirdPersonView = 0

Input:BindCommandToKey("#GotoNextSpawnpoint()","f2",1);
Input:BindCommandToKey("#ToggleFastFlyMode()","f3",1);
Input:BindCommandToKey("#ToggleNoClipFlyMode()","f4",1);
--Input:BindCommandToKey("\\save_game","f5","");        -- How to key-bind a console command
--Input:BindCommandToKey("\\load_game","f8","");        -- How to key-bind a console command
Input:BindCommandToKey("#QuickSave()","f5",1);
Input:BindCommandToKey("#QuickLoad()","f8",1);
Input:BindCommandToKey("#BlindDeafEnemies()","f9",1);
Input:BindCommandToKey("#ToggleGod()","backspace",1);
Input:BindCommandToKey("#AllGrenades()","9",1);
Input:BindCommandToKey("#AllGear()","0",1);
Input:BindCommandToKey("#MoreAmmo()","o",1);
Input:BindCommandToKey("#AllWeapons()","p",1);


--- temp variables for functions below ---
prev_speed_walk=p_speed_walk;
prev_speed_run=p_speed_run;

prev_speed_walk2=p_speed_walk;
prev_speed_run2=p_speed_run;

default_speed_walk=p_speed_walk;
default_speed_run=p_speed_run;

screenshotmode=0;

fastfly=0;                                              -- for functions that toggle states
noclipfly=0;
blind_deaf_enemies=0;


function QuickSave()
        if _localplayer then
                Game:Save('Quicksave');
                Hud:AddMessage("[CHEAT]: Quick-saved the game.");
                System:LogToConsole("\001CHEAT: Quick-saved the game.");
        else
                Hud:AddMessage("[CHEAT]: Cannot quick-save the game.");
        end
end
function QuickLoad()
        Game:Load('Quicksave');                                 -- also allowed when no game is yet loaded
        Hud:AddMessage("[CHEAT]: Quick-loaded the game.");
        System:LogToConsole("\001CHEAT: Quick-loaded the game.");
end

function BlindDeafEnemies()
        if _localplayer then
                if (blind_deaf_enemies==1) then
                        ai_ignoreplayer=0;
                        ai_soundperception=1;
                        Hud:AddMessage("[CHEAT]: Enemies CAN see/hear you.");
                        System:LogToConsole("\001CHEAT: Enemies CAN see/hear you.");
                else
                        ai_ignoreplayer=1;
                        ai_soundperception=0;
                        Hud:AddMessage("[CHEAT]: Enemies CANNOT see/hear you.");
                        System:LogToConsole("\001CHEAT: Enemies CANNOT see/hear you.");
                end
                blind_deaf_enemies=1-blind_deaf_enemies;
        else
                Hud:AddMessage("[CHEAT]: No hiding from enemies.");
        end
end


function ToggleAIInfo()
       
        if (not aiinfo) then
                aiinfo=1;
        else
                aiinfo=1-aiinfo;
        end

        if (aiinfo==1) then
                ai_debugdraw=1;
                ai_drawplayernode=1;
                ai_area_info=1;
        else
                ai_debugdraw=0;
                ai_drawplayernode=0;
                ai_area_info=0;
        end
end

function GotoNextSpawnpoint()
        if _localplayer then
                local pt;
                pt=Server:GetNextRespawnPoint();

                if(not pt)then                                  -- last respawn point or there are no respawn points
                        pt=Server:GetFirstRespawnPoint();       -- try to get the first one
                end

                if(pt)then                                      -- if there is one
                        Game:ForceEntitiesToSleep();

                        _localplayer:SetPos(pt);
                        _localplayer:SetAngles({ x = pt.xA, y = pt.yA, z = pt.zA });
                end
                Hud:AddMessage("[CHEAT]: Jumped to next checkpoint.");
                System:LogToConsole("\001CHEAT: Jumped to next checkpoint.");
        else
                Hud:AddMessage("[CHEAT]: Cannot jump to next checkpoint.");
        end
end

function SetPlayerPos()
        local p=_localplayer
        p:SetPos({x=100,y=100,z=300});
end


function ToggleFastFlyMode()
        if _localplayer then
                ToggleNewDesignerMode(40,120,1);
                if (fastfly==1) then
                        Hud:AddMessage("[CHEAT]: Fast Fly Mode OFF");
                        System:LogToConsole("\001CHEAT: Fast Fly Mode OFF.");
                        fastfly=0;
                else
                        if (noclipfly==1) then
                                Hud:AddMessage("[CHEAT]: No-Clip Fly Mode OFF");
                                System:LogToConsole("\001CHEAT: No-Clip Fly Mode OFF.");
                                noclipfly=0;
                        else
                                Hud:AddMessage("[CHEAT]: Fast Fly Mode ON");
                                System:LogToConsole("\001CHEAT: Fast Fly Mode ON.");
                                fastfly=1;
                        end
                end
        else
                Hud:AddMessage("[CHEAT]: Cannot set fly mode.");
        end
end
function ToggleNoClipFlyMode()
        if _localplayer then
                ToggleNewDesignerMode(10,15,0);
                if (noclipfly==1) then
                        Hud:AddMessage("[CHEAT]: No-Clip Fly Mode OFF");
                        System:LogToConsole("\001CHEAT: No-Clip Fly Mode OFF.");
                        noclipfly=0;
                else
                        if (fastfly==1) then
                                Hud:AddMessage("[CHEAT]: Fast Fly Mode OFF");
                                System:LogToConsole("\001CHEAT: Fast Fly Mode OFF.");
                                fastfly=0;
                        else
                                Hud:AddMessage("[CHEAT]: No-Clip Fly Mode ON");
                                System:LogToConsole("\001CHEAT: No-Clip Fly Mode ON.");
                                noclipfly=1;
                        end
                end
        else
                Hud:AddMessage("[CHEAT]: Cannot set fly mode.");
        end
end


-- replacement for ToggleSuperDesignerMode() and ToggleDesignerMode()
--
-- USAGE:
--  deactivate designer mode: (nil,nil,0)
--  old super designer mode (with collision): (40,120,1)
--  old designer mode (without collision): (10,15,0)
--  change values: call with (nil,nil,0) then with the new values (0.., 0.., 0/1)
--
function ToggleNewDesignerMode( speedwalk, speedrun, withcollide )

        if(SuperDesignerMode_Save1~=nil or speedwalk==nil) then
                --Hud:AddMessage("[CHEAT]: Fly mode OFF");

                p_speed_walk = SuperDesignerMode_Save1;
                p_speed_run = SuperDesignerMode_Save2;
                _localplayer.DynProp.gravity = SuperDesignerMode_Save3;
                _localplayer.DynProp.inertia = SuperDesignerMode_Save4;
                _localplayer.DynProp.swimming_gravity = SuperDesignerMode_Save5;
                _localplayer.DynProp.swimming_inertia = SuperDesignerMode_Save6;
                _localplayer.DynProp.air_control = SuperDesignerMode_Save7;
                _localplayer.cnt:SetDynamicsProperties( _localplayer.DynProp );
                SuperDesignerMode_Save1=nil;

                -- activate collision, parameter is 0 or 1
                _localplayer:ActivatePhysics(1);

        else
                --Hud:AddMessage("[CHEAT]: Fly mode ON");

                SuperDesignerMode_Save1 = p_speed_walk;
                SuperDesignerMode_Save2 = p_speed_run;
                SuperDesignerMode_Save3 = _localplayer.DynProp.gravity;
                SuperDesignerMode_Save4 = _localplayer.DynProp.inertia;
                SuperDesignerMode_Save5 = _localplayer.DynProp.swimming_gravity;
                SuperDesignerMode_Save6 = _localplayer.DynProp.swimming_inertia;
                SuperDesignerMode_Save7 = _localplayer.DynProp.air_control;

                p_speed_walk = speedwalk;
                p_speed_run = speedrun;
                _localplayer.DynProp.gravity=0.0;
                _localplayer.DynProp.inertia=0.0;
                _localplayer.DynProp.swimming_gravity=0.0;
                _localplayer.DynProp.swimming_inertia=0.0;
                _localplayer.DynProp.air_control=1.0;
                _localplayer.cnt:SetDynamicsProperties( _localplayer.DynProp );

                -- deactivate collision, parameter is 0 or 1
                _localplayer:ActivatePhysics(withcollide);
        end
end

function ToggleScreenshotMode()

        if(screenshotmode~=0) then
                System:LogToConsole("SCREENSHOTMODE OFF-->SWITCH TO NORMAL");
                screenshotmode=0;
                hud_crosshair = "1"
                cl_display_hud = "1"
                r_NoDrawNear = "0"
                ai_ignoreplayer = "0"
                ai_soundperception = "1"
                r_DisplayInfo = "1"
        else
                System:LogToConsole("SCREENSHOTMODE ON");
                screenshotmode=1;
                hud_crosshair = "0"
                cl_display_hud = "0"
                r_NoDrawNear = "1"
                ai_ignoreplayer = "1"
                ai_soundperception = "0"
                r_DisplayInfo = "0"
        end
end



function DecreaseSpeed()

        if tonumber(p_speed_walk)>5 then
                p_speed_walk=p_speed_walk-5;
                p_speed_run=p_speed_run-5;
                System:LogToConsole("Decreased player speed by 5");
        else
                System:LogToConsole("You can not go any slower!");
        end
end

function IncreaseSpeed()

        if tonumber(p_speed_walk)<500 then
                p_speed_walk=p_speed_walk+5;
                p_speed_run=p_speed_run+5;
                System:LogToConsole("Increased player speed by 5");
        else
                System:LogToConsole("You can not go any faster!");
        end
end

function DefaultSpeed()

        p_speed_walk=default_speed_walk;
        p_speed_run=default_speed_run;
        System:LogToConsole("Player speed reset");
end

function TeleportToSpawn(n)
        local player = _localplayer;
        local pos = Server:GetRespawnPoint("Respawn"..n);
        if pos then
                player:SetPos(pos);
                player:SetAngles({ x = pos.xA, y = pos.yA, z = pos.zA });
        end
end


-- Give the player the passed weapon, load it if neccesary
function AddWeapon(Name)

        Game:AddWeapon(Name)
        for i, CurWeapon in WeaponClassesEx do
                if (i == Name) then
                        _localplayer.cnt:MakeWeaponAvailable(CurWeapon.id);
                end
        end    
end


--_localplayer.cnt.ammo=999;            -- Reserve ammo         -- Relevant to ammo manipulations
--_localplayer.cnt.ammo_in_clip=999;    -- Clip ammo


function MoreAmmo()

        if _localplayer then
                local weapon = _localplayer.cnt.weapon;
                local name = "";
                local nAmmo = 0;
                local nFireMode = 0;
                if (weapon) then
                        name = weapon.name;
                        nFireMode = _localplayer.cnt.firemode;          -- .firemode exists even for single firemode cases.
                        if (name=="AG36") then
                                if (nFireMode == 0) then
                                        nAmmo = 300;
                                else
                                        nAmmo = 10;
                                        nFireMode = 2;                  -- Flag an alt-ammo add, for displayed message.
                                end
                                _localplayer.cnt.ammo = nAmmo;
                        end
                        if (name=="Falcon") then
                                nAmmo = 150;
                                _localplayer.cnt.ammo = nAmmo;
                        end
                        if (name=="SniperRifle") then
                                nAmmo = 30;
                                _localplayer.cnt.ammo = nAmmo;
                        end
                        if (name=="MP5") then
                                nAmmo = 300;
                                _localplayer.cnt.ammo = nAmmo;
                        end
                        if (name=="RL") then
                                nAmmo = 10;
                                _localplayer.cnt.ammo = nAmmo;
                                name = "Rocket Launcher";
                        end
                        if (name=="Shotgun") then
                                nAmmo = 50;
                                _localplayer.cnt.ammo = nAmmo;
                        end
                        if (name=="OICW") then
                                if (nFireMode == 0) then
                                        nAmmo = 300;
                                else
                                        nAmmo = 10;
                                        nFireMode = 2;                  -- Flag an alt-ammo add, for displayed message.
                                end
                                _localplayer.cnt.ammo = nAmmo;
                        end
                        if (name=="P90") then
                                nAmmo = 300;
                                _localplayer.cnt.ammo = nAmmo;
                        end
                        if (name=="M4") then
                                nAmmo = 300;
                                _localplayer.cnt.ammo = nAmmo;
                        end
                        if (name=="M249") then
                                nAmmo = 300;
                                _localplayer.cnt.ammo = nAmmo;
                        end
                        local sFireMode = "";
                        if (nFireMode==2) then sFireMode="(alt fire-mode) "; end;
                        Hud:AddMessage("[CHEAT]: Set the ammo reserve for weapon '" ..name.."' "..sFireMode.."to

"..nAmmo..".");
                        System:LogToConsole("\001CHEAT: Set the ammo reserve for weapon '" ..name.."' "..sFireMode.."to

"..nAmmo..".");
                else
                        Hud:AddMessage("[CHEAT]: No ammo added.  Try arming a gun first.");
                end
        else
                Hud:AddMessage("[CHEAT]: Cannot give ammo.");
        end
end


-- These script commands can set the ammo reserve of the player for some types of ammo.
--      (The ammo is not loaded, just in reserve.)
--              _localplayer.Ammo.Pistol = 150;
--              _localplayer.Ammo.Assault = 300;
--              _localplayer.Ammo.Sniper = 30;
--              _localplayer.Ammo.SMG = 350;
--              _localplayer.Ammo.Shotgun = 50;
--              --_localplayer.Ammo.MortarShells = 10;  -- This one doesn't seem to work.
--              _localplayer.Ammo.SmokeGrenade = 6;
--              _localplayer.Ammo.FlashbangGrenade = 6;
--              --_localplayer.Ammo.HandGrenade = 6;    -- This one doesn't seem to work.
--              _localplayer.Ammo.Rocket = 10;


function AllWeapons()
        if _localplayer then
                AddWeapon("AG36");
                AddWeapon("Falcon");
                AddWeapon("SniperRifle");
                AddWeapon("MP5");
                AddWeapon("RL");
                AddWeapon("Shotgun");
                AddWeapon("OICW");
                AddWeapon("P90");
                --AddWeapon("M4");      -- Maximum of 9 weapons can be carried (all accessed by mouse-wheel)
                AddWeapon("M249");
                Hud:AddMessage("[CHEAT]: Give 9 weapons.  (Drop unwanted weapons. Access all weapons by mouse-wheel.)");
                System:LogToConsole("\001CHEAT: Give 9 weapons.  (Drop unwanted weapons. Access all weapons by mouse-

wheel.)");
        else
                Hud:AddMessage("[CHEAT]: Cannot give weapons.");
        end
end

function AllGrenades()
        if _localplayer then
                local nHG = _localplayer:GetAmmoAmount("HandGrenade");
                local nSG = _localplayer:GetAmmoAmount("SmokeGrenade");
                local nFG = _localplayer:GetAmmoAmount("FlashbangGrenade");
                _localplayer:AddAmmo("FlashbangGrenade",6-nFG);
                _localplayer:AddAmmo("SmokeGrenade",6-nSG);
                _localplayer:AddAmmo("HandGrenade",6-nHG);
                --_localplayer.Ammo.SmokeGrenade = 6;                   -- Set exact amount, no worries to exceed normal

maximum.
                --_localplayer.Ammo.FlashbangGrenade = 6;
                --_localplayer.Ammo.HandGrenade = 6;                    -- Doesn't work unfortunately
                --_localplayer.cnt.grenadetype = 2;                     -- HUD selects hand grenade.
                --_localplayer.cnt.numofgrenades = 6;                   -- Set selected grenade's amount.
                                                                        -- Set .grenadetype is annoyingly asynchronous, but

one use is fine.
                Hud:AddMessage("[CHEAT]: Give all grenades.");
                System:LogToConsole("\001CHEAT: Give all grenades.");
        else
                Hud:AddMessage("[CHEAT]: Cannot give grenades.");
        end
end

function AllGear()
        if _localplayer then
                _localplayer.cnt:GiveBinoculars(1);
                _localplayer.cnt:GiveFlashLight(1);
                _localplayer.items.heatvisiongoggles=1;
                Hud:AddMessage("[CHEAT]: Give binoculars, flashlight, and heat-vision goggles.");
                System:LogToConsole("\001CHEAT: Give binoculars, flashlight, and heat-vision goggles.")
        else
                Hud:AddMessage("[CHEAT]: Cannot give gear.");
        end
end

function ToggleGod()
        if _localplayer then
                if (not god) then
                        god=1;
                else
                        god=1-god;
                end
                -- Check if we are going to set or remove god mode now.
                if (god==1) then
                        GodMode_Save1 = _localplayer.cnt.health;
                        GodMode_Save2 = _localplayer.cnt.armor;
                        _localplayer.cnt.health = 99999;
                        _localplayer.cnt.armor = 99999;
                        Hud:AddMessage("[CHEAT]: God Mode ON. Set health and armor to 99999.");
                        System.LogToConsole("\001CHEAT: God Mode ON. Set health and armor to 99999.");
                else
                        _localplayer.cnt.health = GodMode_Save1;
                        _localplayer.cnt.armor = GodMode_Save2;
                        Hud:AddMessage("[CHEAT]: God Mode OFF. Restored health ("..GodMode_Save1..") and armor

("..GodMode_Save2..").");
                        System:LogToConsole("\001CHEAT: God Mode OFF. Restored health ("..GodMode_Save1..") and armor

("..GodMode_Save2..").");
                end
        else
                Hud:AddMessage("[CHEAT]: Cannot set god mode.");
        end
end

--Hud:AddMessage("Loaded script: DevMode.lua"); -- debugging feedback