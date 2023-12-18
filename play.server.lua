local require = function(module)
    if type(module) == "string" then 
        local func, err = loadstring(game:GetService('HttpService'):GetAsync((module:sub(1,8) == "https://" and "" or "https://")..module))
        if not func then 
            warn(err) 
        else
            return func()
        end 
    else 
        return getfenv().require(module)
    end 
end

local midi = require(script.Parent.midiplayer)
local song = midi.new("https://kanephan3.tripod.com/Midis/zombie.mid")

song:Play()
