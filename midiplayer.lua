local Song = {}
Song.__index = Song
local HttpService = game:GetService('HttpService')

local MIDI = require(script.Parent.MIDI)

local RunService = game:GetService("RunService")
local HttpService = game:GetService('HttpService')

local function GetTimeLength(score)
local length = 0
for i, track in ipairs(score) do
	if (i == 1) then continue end
	length = math.max(length, track[#track][2])
end
return length
end


function Song.new(file)
local midiData = HttpService:GetAsync(file)
local score = MIDI.midi2score(midiData)

local fullname = file:match("([^/^\\]+)$")
local name = fullname:match("^([^%.]+)") or ""

local self = setmetatable({

	Name = name;
	FullName = fullname:gsub('%%20',' '):gsub('\?.+','');
	Path = file;
	TimePosition = 0;
	TimeLength = 0;
	Timebase = score[1];
	IsPlaying = false;

	_score = score;
	_usPerBeat = 0;
	_lastTimePosition = 0;
	_length = GetTimeLength(score);
	_eventStatus = {};
	_updateConnection = nil;

}, {__index = Song})

self.TimeLength = (self._length / self.Timebase)

return self

end


function Song:Update(timePosition, lastTimePosition)
for _,track in next, self._score,1 do
	for _,event in ipairs(track) do
		local eventTime = (event[2] / self.Timebase)
		if (timePosition >= eventTime) then
			if (lastTimePosition <= eventTime) then
				self:_parse(event)
			end
		end
	end
end
end


function Song:Step(deltaTime)
self._lastTimePosition = self.TimePosition
if (self._usPerBeat ~= 0) then
	self.TimePosition += (deltaTime / (self._usPerBeat / 1000000))
else
	self.TimePosition += deltaTime
end
end
function Song:Play()
self._updateConnection = RunService.Heartbeat:Connect(function(dt)
	self:Update(self.TimePosition, self._lastTimePosition)
	self:Step(dt)
	if (self.TimePosition >= self.TimeLength) then
		self:Pause()
	end
end)
self:Update(0, 0)
self.IsPlaying = true
end


function Song:Stop()
if (self._updateConnection) then
	self._updateConnection:Disconnect()
	self._updateConnection = nil
	self.IsPlaying = false
end
self._lastTimePosition = 0
end


function Song:Pause()
if (self._updateConnection) then
	self._updateConnection:Disconnect()
	self._updateConnection = nil
	self.IsPlaying = false
end
end


local ExistingSounds = {}

local instruments = {
['Piano']             = {"rbxassetid://5924276201",	-8},
['Bell']              = {'rbxassetid://19344667'  , -10},
['Harp'] 		  	  = {'rbxassetid://109618842' ,	-12},
['Sitar'] 		      = {'rbxassetid://12857654'  ,	-1},
['Guitar']		      = {'rbxassetid://4007485270',	 0},
['Doo'] 		      = {'rbxassetid://75338648'  ,	-2},
['Brass']             = {'rbxassetid://11998777'  , 11},
['Baritone']		  = {'rbxassetid://1846986991',  6},
['Violin']            = {'rbxassetid://13418521'  ,  3},
['Dulcheimer']        = {'rbxassetid://9040512197',  2},
['Horn']              = {'rbxassetid://13417380'  , -7},
['Bassoon']           = {'rbxassetid://13424334'  ,-12},

-- Waves --
['Square']            = {'rbxassetid://9040512330',  2},
['Sawtooth']          = {'rbxassetid://9040512075',  2},
['Sine']     		  = {'rbxassetid://146750669' ,	 2},
['Dial']    		  = {'rbxassetid://15666462'  ,	-2},
['Calliope']          = {'rbxassetid://9040512197',  2},
}

local vol = 1
local highgain = 20
local lowgain = 5
local midgain = 5
local decaytime = 1
local density = 0
local diffusion = 0
local drylevel = 5
local defaultvol = 1
local reverbenabled = false
local equalizerenabled = true

local ContentProvider = game:GetService("ContentProvider")

for i,v in pairs(instruments) do
ContentProvider:Preload(v[1])
end

function notetopitch(note, offset)
return ((440 / 32) * math.pow(2, ((note + offset) / 12)) / 440)*8
end

local function playNote(note, time, volume, instrument)
local audio = Instance.new("Sound")-- Create the audio
audio.SoundId = instrument[1]
audio.Pitch = notetopitch(note, instrument[2])
audio.Volume = volume*(defaultvol*vol)

local reverb = Instance.new("ReverbSoundEffect")
reverb.DecayTime = decaytime
reverb.Density = density
reverb.Diffusion = diffusion
reverb.DryLevel = drylevel
reverb.Enabled = reverbenabled
reverb.Parent = audio

audio.Parent = workspace
audio:Play() -- Play the audio
task.delay(time,function()
	game:GetService('TweenService'):Create(audio,TweenInfo.new(.5),{Volume = 0}):Play()
end)
table.insert(ExistingSounds, 1, audio)
game:GetService("Debris"):AddItem(audio,8)
end

function Song:_parse(event)
--[[
Event:
    Event name  [String]
    Start time  [Number]
    ...
Note:
    Event name  [String]
    Start time  [Number]
    Duration    [Number]
    Channel     [Number]
    Pitch       [Number]
    Velocity    [Number]
]]
local eventName = event[1]
if (eventName == "set_tempo") then
	self._usPerBeat = event[3]
elseif (eventName == "song_position") then
	self.TimePosition = (event[3] / self.Timebase)
	print("set timeposition timebase", self.Timebase)
elseif (eventName == "note") then
	--print(event[6])

	if(event[4]==9) then
		--print(event[5])
		local Percussion = {
			-- Bass Drum
			['35'] = 'rbxassetid://31173820',
			['36'] = 'rbxassetid://31173820',

			--IDK
			['82'] = 'rbxassetid://31173898',

			--Conga
			['62'] = 'rbxassetid://57802212', --high
			['63'] = 'rbxassetid://57802212', --high
			['64'] = 'rbxassetid://57802134', -- low

			--Conga
			['60'] = 'rbxassetid://57802055', --high
			['61'] = 'rbxassetid://57801983', -- low
			--Toms
			['45'] = 'rbxassetid://31173881', -- low

			['47'] = 'rbxassetid://31173863', -- lowmid
			['48'] = 'rbxassetid://31173863', -- highmid

			['50'] = 'rbxassetid://31173844', -- high

			--Cowbell
			['56'] = 'rbxassetid://9120917609',


			--Cymbals
			['49'] = 'rbxassetid://31173771', -- Crash
			['51'] = 'rbxassetid://31173898', -- Ride
			['57'] = 'rbxassetid://31173771', -- Crash
			['59'] = 'rbxassetid://31173898', -- Ride

			['42'] = 'rbxassetid://4702649974', --HiHat Closed
			['44'] = 'rbxassetid://4702649717', --HiHat
			['46'] = 'rbxassetid://4702649315', --HiHat

			-- Cuica
			['78'] = 'rbxassetid://7430849680',
			['79'] = 'rbxassetid://7430849680',
			-- Snare
			['38'] = 'rbxassetid://31173799',
			['40'] = 'rbxassetid://31173799',

			--Triangle
			['80'] = 'rbxassetid://6732342375',
			['81'] = 'rbxassetid://6732342375',

			-- Wood Blocks
			['76']='rbxassetid://9120917978',
			['77']='rbxassetid://9120917605',
		}

		local audio = Instance.new("Sound", workspace)-- Create the audio
		audio.SoundId = Percussion[tostring(event[5])] or ''
		audio.Pitch = 1
		audio.Volume = (event[6]/127)*(defaultvol*vol)

		local EqualizerSoundEffect = Instance.new("EqualizerSoundEffect")
		EqualizerSoundEffect.HighGain = highgain
		EqualizerSoundEffect.LowGain = lowgain
		EqualizerSoundEffect.MidGain = midgain
		EqualizerSoundEffect.Enabled = equalizerenabled
		EqualizerSoundEffect.Parent = audio

		audio:Play()
	elseif event[4] == 9 then
		playNote(event[5]-35,event[3] / self.Timebase,event[6]/127, instruments['Baritone'])
	else
		playNote(event[5]-35,event[3] / self.Timebase,event[6]/127, instruments['Piano'])
	end
end
end

return Song
