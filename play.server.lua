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
local song = midi.new("https://www.angelfire.com/nb/nonstopbounce/euro2/djsammyandyanou_heaven.mid")

song:Play()
