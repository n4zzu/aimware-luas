-- Player Chat Info - Updated by naz#6660 - Made by Sxx#7162
-- Version: 1.1 (2019-7-16 04:00)
-- Version 1.2 (01/05/2021 16:15)

local Enemy = 1;
local Teammate = 2;

local Toggle = 1;
local SendType = 2;
local TriggerMode = 3;
local TriggerKey = 4;
local IncludeYourself = 5;
local SendName = 6;
local SendHealth = 7;
local SendWeapon = 8;
local SendAmmo = 9;
local SendSeparator = 10;
local CompareCallback = 11;
local LastTickCount = 12;
local SendCount = 13;
local SentSeparator = 14;
local Trigger = 15;
local SendDelay = 16;

local Data = { };
Data[Enemy] = { };
Data[Teammate] = { };


-- CPI = "Chat Player Info" ("Player Chat Info")
local Menu_Reference = gui.Reference("MISC", "GENERAL", "Extra");
local miscRef = gui.Reference("MISC")
local miscTab = gui.Tab(miscRef, "miscTab", "Chat Info")
local Wnd_Active = gui.Checkbox(Menu_Reference, "CPI_Check_WndActive", "Player Chat Info", true);
local Wnd_EnemyInfo = gui.Groupbox(miscTab, "Enemy Info", 16, 16, 296, 340);
local Wnd_TeammateInfo = gui.Groupbox(miscTab, "Teammate Info", 325, 16, 296, 340);

Data[Enemy][Toggle] = gui.Checkbox(Wnd_EnemyInfo, "CPI_Check_E_Toggle", "Enable", true);
Data[Enemy][SendType] = gui.Combobox(Wnd_EnemyInfo, "CPI_Combo_E_SendType", "Send Type", "Global Send", "Team Send");
Data[Enemy][TriggerMode] = gui.Combobox(Wnd_EnemyInfo, "CPI_Combo_E_TriggerMode", "Trigger Mode", "Key Pressed", "Always Spam");
Data[Enemy][TriggerKey] = gui.Keybox(Wnd_EnemyInfo, "CPI_Combo_E_TriggerKey", "Trigger Key", 67);
Data[Enemy][SendDelay] = gui.Slider(Wnd_EnemyInfo, "CPI_Slider_E_SendDelay", "Send Delay", 50, 45, 150);
Data[Enemy][SendName] = gui.Checkbox(Wnd_EnemyInfo, "CPI_Check_E_SendName", "Send Name", true);
Data[Enemy][SendHealth] = gui.Checkbox(Wnd_EnemyInfo, "CPI_Check_E_SendHealth", "Send Health", true);
Data[Enemy][SendWeapon] = gui.Checkbox(Wnd_EnemyInfo, "CPI_Check_E_SendWeapon", "Send Weapon", true);
Data[Enemy][SendSeparator] = gui.Checkbox(Wnd_EnemyInfo, "CPI_Check_E_SendSeparator", "Send Separator", false);

Data[Teammate][Toggle] = gui.Checkbox(Wnd_TeammateInfo, "CPI_Check_T_Toggle", "Enable", true);
Data[Teammate][TriggerMode] = gui.Combobox(Wnd_TeammateInfo, "CPI_Combo_T_TriggerMode", "Trigger Mode", "Key Pressed", "Always Spam");
Data[Teammate][TriggerKey] = gui.Keybox(Wnd_TeammateInfo, "CPI_Combo_T_TriggerKey", "Trigger Key", 86);
Data[Teammate][SendDelay] = gui.Slider(Wnd_TeammateInfo, "CPI_Slider_T_SendDelay", "Send Delay", 50, 45, 150);
Data[Teammate][IncludeYourself] = gui.Checkbox(Wnd_TeammateInfo, "CPI_Check_T_ExcludeYourself", "Include Yourself", true);
Data[Teammate][SendName] = gui.Checkbox(Wnd_TeammateInfo, "CPI_Check_T_SendName", "Send Name", true);
Data[Teammate][SendHealth] = gui.Checkbox(Wnd_TeammateInfo, "CPI_Check_T_SendHealth", "Send Health", true);
Data[Teammate][SendWeapon] = gui.Checkbox(Wnd_TeammateInfo, "CPI_Check_T_SendWeapon", "Send Weapon", true);
Data[Teammate][SendSeparator] = gui.Checkbox(Wnd_TeammateInfo, "CPI_Check_T_SendSeparator", "Send Separator", false);

local Menu_Active = true;
local LocalPlayer = { };
local function CompareEnemy(TargetPlayer)
	return TargetPlayer:GetTeamNumber() ~= LocalPlayer:GetTeamNumber();
end
local function CompareTeammate(TargetPlayer)
	if (TargetPlayer:GetTeamNumber() ~= LocalPlayer:GetTeamNumber()) then
		return false;
	end
	
	local IncludeCheck = Data[Teammate][IncludeYourself];
	return IncludeCheck:GetValue() == false and TargetPlayer:GetIndex() ~= LocalPlayer:GetIndex() or IncludeCheck:GetValue();
end
local function ChatSay(String, Comp)
	if (Comp[SendType] == 1 or Comp[SendType]:GetValue() == 0) then
		client.ChatSay(String);
	else
		client.ChatTeamSay(String);
	end
end



Data[Enemy][CompareCallback] = CompareEnemy;
Data[Enemy][LastTickCount] = globals.TickCount();
Data[Enemy][SendCount] = 1;
Data[Enemy][SentSeparator] = false;
Data[Enemy][Trigger] = false;

Data[Teammate][CompareCallback] = CompareTeammate;
Data[Teammate][LastTickCount] = globals.TickCount();
Data[Teammate][SendCount] = 1;
Data[Teammate][SentSeparator] = false;
Data[Teammate][Trigger] = false;

--------------------------------------------------


Data[Enemy][SendType]:SetValue(1);
Data[Enemy][SendName]:SetValue(true);
Data[Enemy][SendHealth]:SetValue(true);
Data[Enemy][SendWeapon]:SetValue(true);
Data[Enemy][SendSeparator]:SetValue(true);

Data[Teammate][SendType] = 1;
Data[Teammate][SendName]:SetValue(true);
Data[Teammate][SendHealth]:SetValue(true);
Data[Teammate][SendWeapon]:SetValue(true);
Data[Teammate][SendSeparator]:SetValue(true);



local function StringSplit(Source, Separator)
	local StartIndex = 1;
	local Index = 1;
	local Result = { };
	
	while true do
		local LastIndex = string.find(Source, Separator, StartIndex);
		if (LastIndex == nil) then
			Result[Index] = string.sub(Source, StartIndex, string.len(Source));
			break;
		end
		Result[Index] = string.sub(Source, StartIndex, LastIndex - 1);
		StartIndex = LastIndex + string.len(Separator);
		Index = Index + 1;
	end
	
	return Result;
end

local function FilterPlayer(Players, Compare)
	local Result = { };
	
	for i = 1, #Players do
		if (Players[i]:IsAlive() and Compare(Players[i])) then
			table.insert(Result, 1, Players[i]);
		end
	end
	
	return Result;
end

local function GetSendString(Player, Camp)
	local Result = "";
	
	if (Camp[SendName]:GetValue()) then
		Result = Result .. Player:GetName() .. " | ";
	end
	
	if (Camp[SendHealth]:GetValue()) then
		Result = Result ..  "HP: " .. Player:GetHealth() .. " | ";
	end
	
	if (Camp[SendWeapon]:GetValue()) then
		local ActiveWeapon = Player:GetPropEntity("m_hActiveWeapon"):GetName();
			Result = Result .. ActiveWeapon .. " | ";
	
	Result = Result .. "Location: " .. Player:GetPropString("m_szLastPlaceName");
    end
	
	return Result;
end

local function SendInfo(Camp)
	if (not Camp[Trigger]) then
		return;
	end
	
	local Players = entities.FindByClass("CCSPlayer");
	local Filtered = FilterPlayer(Players, Camp[CompareCallback]);
	
	if (Filtered[Camp[SendCount]] == nil) then
		Camp[SendCount] = 1;
		Camp[Trigger] = false;
		if (Camp[SentSeparator] == false) then
			Camp[SentSeparator] = true;
			if (Camp[SendSeparator]:GetValue()) then
				ChatSay("--------------------------------------------------", Camp);
			end
		end
	else
		local SendContent = GetSendString(Filtered[Camp[SendCount]], Camp);
		ChatSay(SendContent, Camp);
		Camp[SentSeparator] = false;
		Camp[SendCount] = Camp[SendCount] + 1;
	end
end

local function PlayerChatInfo(Camp)
	if (Camp[Toggle]:GetValue() ~= true) then
		return;
	end
	
	if (Camp[TriggerMode]:GetValue() == 0) then
		if (input.IsButtonPressed(Camp[TriggerKey]:GetValue())) then
			Camp[Trigger] = true;
		end
	else
		Camp[Trigger] = true;
	end
	
	local CurrentTickCount = globals.TickCount();
	if (CurrentTickCount - Camp[LastTickCount] >= Camp[SendDelay]:GetValue()) then
		SendInfo(Camp);
		Camp[LastTickCount] = CurrentTickCount;
	else
		if (CurrentTickCount < Camp[LastTickCount]) then
			Camp[LastTickCount] = 0;
		end
	end
end

local function DrawCallback()
	
	LocalPlayer = entities.GetLocalPlayer();
	if (LocalPlayer == nil) then
		return;
	end
	
	PlayerChatInfo(Data[Enemy]);
	PlayerChatInfo(Data[Teammate]);
end


callbacks.Register("Draw", "CPI_CbDraw", DrawCallback);