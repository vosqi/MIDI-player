Midiplayer designed to use in SB games. It uses Httpservice, LuaMidi from luarocks to convert a midi file into a dynamic file that is readable by the LuaMidi module. It then converts the file to a table of scores that provide time, channel, volume, etc.

How to use: 
- fetch the repo and aquire all scripts into Workspace
- go to play.server.lua, change the username variable to your username, change the song variable to the midi file link
- upon runtime, the midiplayer should run
