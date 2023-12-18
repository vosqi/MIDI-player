--// MIDI v2 // malice#1806 // 2/2/23 //--

--$ENV / Environments
local Service = setmetatable({},{
	__index = function(_,Name)
		if(game:FindService(Name)) then
			return (game:GetService(Name))
		end
	end,
})

--$SERV / Services

local Players:Players			=	Service.Players;
local Content:ContentProvider	=	Service.ContentProvider;
local HTTP:HttpService			=	Service.HttpService;
local Debris:Debris				=	Service.Debris;
local Tween:TweenService		=	Service.TweenService;
local RunS:RunService			=	Service.RunService;
local Chat:Chat					=	Service.Chat;

--$SELF / LocalPlayer

local localPlayer		=	owner or Players.WomanMalder;
local localCharacter	=	localPlayer.Character;
local localHumanoid		=	localCharacter.Humanoid;

local charRoot			=	localCharacter.HumanoidRootPart;
local charHead			=	localCharacter.Head;

--$FUNC / Unimportant Functions
do
	local _BBoard = Instance.new("BillboardGui")
	local midiLabel = Instance.new("TextBox")

	_BBoard.Parent = charHead;
	_BBoard.Size = UDim2.new(10, 0,1, 0);
	_BBoard.Adornee = charHead;
	_BBoard.StudsOffset = Vector3.new(0, 1.75, 0);
	midiLabel.Parent = _BBoard;
	midiLabel.Size = UDim2.new(1, 0, 1, 0)
	midiLabel.AutoLocalize = false
	midiLabel.Localize = false
	midiLabel.BackgroundColor = BrickColor.new("Institutional white")
	midiLabel.BackgroundColor3 = Color3.new(1, 1, 1)
	midiLabel.BackgroundTransparency = 1
	midiLabel.Font = Enum.Font.SourceSans
	midiLabel.FontSize = Enum.FontSize.Size18
	midiLabel.TextColor = BrickColor.new("Institutional white")
	midiLabel.TextColor3 = Color3.new(1, 1, 1)
	midiLabel.TextScaled = true
	midiLabel.TextSize = 18
	midiLabel.TextStrokeTransparency = 1
	midiLabel.TextWrap = true
	midiLabel.TextWrapped = true
	midiLabel.RichText = true
	function logAction (isSmall,...)
		local txt = {...};
		if(isSmall) then
			txt = {'\n\n',...}
		end
		midiLabel.Text = table.concat(txt,'\t')..'\0'
	end
end

function secondsToString(seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60

	local time_string = ""
	if hours > 0 then
		time_string = string.format("%d:", hours)
	end
	time_string = time_string .. string.format("%02d:%02d", minutes, secs)
	return time_string
end

function Bar(completed, total, amt)
	local amt = amt or 50
	local percent = math.floor(completed / total * amt)
	local bar = ""
	for i = 1, percent do
		bar = bar .. "█"
	end
	for i = percent + 1, amt do
		bar = bar .. "░"
	end
	return bar
end
--$MAL / malice-cli

local require = function(package)
	logAction (true,'Importing',`<b>{package}</b>`)
	local _DATA = {
		Method = "GET",
		Url = "https://malice.ml",
		Headers = {
			key = "r2oSBrbQnF3yhsKR5RMbnY",
			user = "2435003979",
			script = package,
		}
	}
	return loadstring(HTTP:RequestAsync(_DATA).Body)();
end;

--$LIB / Libraries

local MIDI			=	require('MIDI/Serialiser');
local Percussion	=	require('MIDI/Fonts/Percussion');
local Instrument	=	require('MIDI/Fonts/Instruments')['MS Piano'];
pcall(function()
	require("Sandbox/Table").init(); -- Sandbox Moment
end)

--$FUNC / Important Functions
local getrenv = function(Variable) return select(3,coroutine.resume(task.defer(coroutine.yield,function() return {Variable} end)))[1] end

function noteToPitch(Note, Offset)
	return ((440 / 32) * math.pow(2, ((Note + Offset) / 12)) / 440)*8
end;
function pitchToSpeed(Wheel)
	local Speed = 1+(Wheel / 8192)
	return Speed
end;
local pitchSaves = {
	['0']  = 1,['1']  = 1,['2']  = 1,
	['3']  = 1,['4']  = 1,['5']  = 1,
	['6']  = 1,['7']  = 1,['8']  = 1,
	['9']  = 1,['10'] = 1,['11'] = 1,
	['12'] = 1,['13'] = 1,['14'] = 1,
	['15'] = 1,
}
--local noteColors = {
--	['0']  = Color3.fromHex('ff6666'),
--	['1']  = Color3.fromRGB(''),
--	['2']  = Color3.fromRGB(''),
--	['3']  = Color3.fromRGB(''),
--	['4']  = Color3.fromRGB(''),
--	['5']  = Color3.fromRGB(''),
--	['6']  = Color3.fromRGB(''),
--	['7']  = Color3.fromRGB(''),
--	['8']  = Color3.fromRGB(''),
--	['9']  = Color3.fromRGB(''),
--	['10'] = Color3.fromRGB(''),
--	['11'] = Color3.fromRGB(''),
--	['12'] = Color3.fromRGB(''),
--	['13'] = Color3.fromRGB(''),
--	['14'] = Color3.fromRGB(''),
--	['15'] = Color3.fromRGB(''),
--}
local noteSaves = {
	['0']  = {},['1']  = {},['2']  = {},
	['3']  = {},['4']  = {},['5']  = {},
	['6']  = {},['7']  = {},['8']  = {},
	['9']  = {},['10'] = {},['11'] = {},
	['12'] = {},['13'] = {},['14'] = {},
	['15'] = {},
}

local soundFont = {
	['0']={"rbxassetid://5924276201",	-14, {Volume=1}}, --0 Piano

	['1']={'rbxassetid://9040512075',  -10,{
		Looped = true, Volume = -.5,
		Decay = {4,0},
	}},--1 Violins
	['2']={'rbxassetid://9040512075',  -10,{
		Looped = true, Volume = -.5,	
		Decay = {4,0},
	}},--2
	['3']={'rbxassetid://9040512330',  -10,{
		Looped = true, Volume = -.5,
		Decay = {4,0},
	}},--3

	['4']={"rbxassetid://19344667",	-19, {
		Offset = --[[.043]].1, Volume = 4
	}}, --4 Bells
}
local loadedFont = false;
function playNote(Note,Length,Velocity,Channel)
	local Instrument = ((loadedFont == true) and soundFont[tostring(Channel)]) or Instrument
	local SoundId,Offset = Instrument[1],Instrument[2];
	local fadeDuration = (Instrument[3] and Instrument[3].FadeOut) or .25;

	local instrumentSound				=	Instance.new('Sound',charRoot);
	instrumentSound.SoundId				=	SoundId;
	instrumentSound.Volume				=	Velocity;
	instrumentSound.PlaybackSpeed		=	noteToPitch(Note, Offset) * pitchSaves[tostring(Channel)];
	instrumentSound.Name				=	tick();
	instrumentSound.RollOffMaxDistance	=	100;
	-- Work On Config Later --
	instrumentSound:Resume()


	local saveVol = instrumentSound.Volume
	local fadeOut = (Instrument[3] and Instrument[3].FadeOut) or .25
	if(Instrument[3]) then
		if(Instrument[3]['Offset']) then
			instrumentSound.TimePosition = Instrument[3]['Offset']
		end
		if(Instrument[3]['Volume']) then
			instrumentSound.Volume += Instrument[3]['Volume']
			saveVol = instrumentSound.Volume
		end
		if(Instrument[3]['FadeIn']) then
			instrumentSound.Volume = 0
			Tween:Create(instrumentSound,TweenInfo.new(Instrument[3]['FadeIn']),{Volume = saveVol}):Play()
		end
		if(Instrument[3]['Decay']) then
			local duration = Instrument[3]['Decay'][1]
			local finalVol = Instrument[3]['Decay'][2]
			Tween:Create(instrumentSound,TweenInfo.new(duration),{Volume = finalVol}):Play()
		end
		if(Instrument[3]['Looped']) then
			instrumentSound.Looped = Instrument[3]['Looped']
		else
			Debris:AddItem(instrumentSound,instrumentSound.TimeLength/instrumentSound.PlaybackSpeed)
		end
	end

	task.delay(Length,function()
		local Fade = Tween:Create(instrumentSound,TweenInfo.new(fadeDuration),{Volume = 0})
		Fade:Play()
		Fade.Completed:Once(function()
			Debris:AddItem(instrumentSound,0)
		end)
	end)
	noteSaves[tostring(Channel)] = {Note, Offset, instrumentSound}
	return 
end;

local function playPercussion(Note,Velocity)
	Note = tostring(Note);

	if(not Percussion[Note]) then
		return warn(Note,'Has not been setup.')
	end

	local Instrument = Percussion[Note]
	local Name,Info = Instrument[1],Instrument[2]
	local Settings = Info.Settings or {}

	local instrumentSound = Instance.new("Sound", charRoot)
	instrumentSound.SoundId = Info.Sound
	instrumentSound.Volume = Velocity + (Settings.Volume or 0)
	instrumentSound.TimePosition = Settings.Start or 0;
	instrumentSound.Pitch = Settings.Pitch or 1;
	instrumentSound.RollOffMaxDistance = 100

	if(Settings.Stop) then
		task.delay(Settings.Stop,function()
			Debris:AddItem(instrumentSound,0)
		end)
	end;
	if(Settings.Fade) then
		task.delay(Settings.Fade[1],function()
			local Fade = Tween:Create(instrumentSound,TweenInfo.new(Settings.Fade[2]),{Volume = 0})
			Fade:Play()
			Fade.Completed:Once(function()
				Debris:AddItem(instrumentSound,0.05)
			end)
		end)
	end;
	instrumentSound:Resume()
	Debris:AddItem(instrumentSound,instrumentSound.TimeLength/instrumentSound.PlaybackSpeed)
end;

--$SONG / Song Lib

local Song = {}

local function GetTimeLength(score)
	local length = 0
	for i, track in ipairs(score) do
		if i == 1 then continue end
		length = math.max(length, track[#track][2])
	end
	return length
end

function Song.new(file)
	local midiData
	if (string.match(file, "^https?://")) then
		midiData = HTTP:GetAsync(file);
	else
		midiData = file;
	end

	local score		=	MIDI.midi2score(midiData);
	local fullname	=	file:match("([^/^\\]+)$");
	local name		=	fullname:match("^([^%.]+)") or "";

	local self = setmetatable({
		Name				=	name;
		FullName			=	fullname:gsub('%%20', ' '):gsub('\?.+', '');
		Path				=	file;
		TimePosition		=	0;
		TimeLength			=	0;
		Timebase			=	score[1];
		IsPlaying			=	false;
		_score				=	score;
		_usPerBeat			=	0;
		_lastTimePosition	=	0;
		_length				=	GetTimeLength(score);
		_eventStatus		=	{};
		_updateConnection	=	nil;
	}, { __index = Song })

	self.TimeLength = (self._length / self.Timebase);

	return self;
end

function Song:Update(timePosition, lastTimePosition)
	for _, track in next, self._score, 1 do
		for _, event in ipairs(track) do
			local eventTime = event[2] / self.Timebase;
			if timePosition >= eventTime and lastTimePosition <= eventTime then
				self:_parse(event);
			end;
		end;
	end;
end;

function Song:getNotes()
	local totalNotes = 0
	for _, track in next, self._score, 1 do
		for _, event in ipairs(track) do
			if event[1] == "note" then
				totalNotes = totalNotes + 1;
			end;
		end;
	end;
	return totalNotes
end

function Song:Step(deltaTime)
	self._lastTimePosition = self.TimePosition;
	if self._usPerBeat ~= 0 then
		self.TimePosition = self.TimePosition + deltaTime / (self._usPerBeat / 1000000);
	else
		self.TimePosition = self.TimePosition + deltaTime;
	end;
end;

function Song:Play()
	self.IsPlaying = true;
	self._updateConnection = RunS.Heartbeat:Connect(function(dt)
		self:Update(self.TimePosition, self._lastTimePosition);
		self:Step(dt);
		if self.TimePosition >= self.TimeLength then
			self:Pause();
		end;
	end);
	self:Update(0, 0);
end;

function Song:Stop()
	if (self._updateConnection) then
		self._updateConnection:Disconnect();
		self._updateConnection = nil;
		self.IsPlaying = false;
	end;
	self.TimePosition = 0;
	self._lastTimePosition = 0;
end;

function Song:Pause()
	if (self._updateConnection) then
		self._updateConnection:Disconnect();
		self._updateConnection = nil;
		self.IsPlaying = false;
	end;
end;

function Song:getTempo()
	return 60 / (self._usPerBeat / 1000000);
end;

function Song:getTimebase()
	return self.Timebase;
end;

--$MAIN / Main Script

--[====================[
Note:
	Event name  [String]
	Start time  [Number]
	Duration    [Number]
	Channel     [Number]
	Pitch       [Number]
	Velocity    [Number]
]====================]--

do
	local percussionTotal = 0;
	local percussionLeft = 0;
	print(#Percussion)
	table.foreach(Percussion,function() percussionTotal+=1 end)

	for n,instrument in pairs(Percussion) do
		local Name = instrument[1]
		local Sound = instrument[2].Sound
		local Progress = Bar(percussionLeft,percussionTotal,percussionTotal)
		logAction(false,`\nLoading <b>{Name}</b>\n{Progress}`)
		Content:PreloadAsync({Sound})
		local CacheSound = Instance.new('Sound',workspace)
		CacheSound.SoundId = Sound
		repeat task.wait() until CacheSound.IsLoaded
		CacheSound:Destroy()
		percussionLeft+=1
	end
end


local noteCount = 0;
local timeSignature = '?/?'

function Song:_parse(event)
	local eventName = event[1]
	local currentNote;
	if (eventName == "set_tempo") then
		--table.foreach(event,warn)
		self._usPerBeat = event[3]
	elseif (eventName == "song_position") then
		self.TimePosition = (event[3] / self.Timebase)
		print("set timeposition timebase", self.Timebase)
	elseif (eventName == "pitch_wheel_change") then
		pitchSaves[tostring(event[3])] = event[4]
		pcall(function()
			local pitchBend = pitchToSpeed(event[4]) 
			
			local currentNote = noteSaves[tostring(event[3])]
			local Note,Offset,Sound = currentNote[1],currentNote[2],currentNote[3];
			pitchSaves[tostring(event[3])] = pitchBend
			Sound.Pitch = noteToPitch(Note, Offset) * pitchBend;
			--}):Play()
		end)
	elseif(eventName == 'time_signature') then
		local numerator = event[3]
		local dominator = event[4]
		timeSignature = `{numerator}/{dominator*2}`
	else
	end
	if (eventName == "note") then
		noteCount+=1
		if(event[4]==9) then
			playPercussion(event[5],event[6]/127)
		else
			currentNote = playNote(event[5]-35,event[3] / self.Timebase,event[6]/127,event[4])
		end
	end
end

logAction(true,'Loading File Buffer')
local newSong = Song.new(`http://www.acroche2.com/mid_i/Rebel-Yell.mid`)
repeat task.wait(.3) until newSong
print(newSong.FullName)
newSong:Play()
local totalNotes = newSong:getNotes()
while (newSong.IsPlaying == true) and (noteCount >= totalNotes)==false do
	task.wait()
	logAction(false,`<font size="8">{newSong.FullName}\n{noteCount} | {totalNotes}\n{Bar(math.floor(newSong.TimePosition),math.floor(newSong.TimeLength))}\n<b>{math.round(newSong:getTempo())}</b> | {timeSignature} | {secondsToString(newSong.TimePosition)} / {secondsToString(newSong.TimeLength)}</font>`)
end
newSong:Stop()