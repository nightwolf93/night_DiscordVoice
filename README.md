# night_DiscordVoice
A simple package with a discord bot for creating calls

# How to use
Before you need to configure the bot in bot/index.js
You need to put the GuildId, CategoryId, and Token for the App.
You can start this bot in pm2 for example.

# API
There is some functions available for creating calls

Before using it you need to import the package with
```
local discordVoice = ImportPackage("night_DiscordVoice")
```

For begin the linking process just do something like that 
```
AddCommand("discord", function(player, discordId)
    AddPlayerChat(player, "Association en cours.. répondre au bot sur discord (30s)")
    local discordVoice = ImportPackage("night_DiscordVoice")
    if not discordVoice.IsAlreadyAssoc(tostring(GetPlayerSteamId(player))) then
        discordVoice.AssertSteamIdWithDiscord(tostring(GetPlayerSteamId(player)), discordId)
    else
        AddPlayerChat(player, "Votre compte est déjà associé à Discord")
    end
end)

AddEvent("DiscordVoice:ResultAssert", function(result, steamId, discordId)
    if result then
        print("Association ok !")
    else
        print("Association failed !")
    end
end)

```

Create a call
```
    discordVoice.CreateCall(discordVoice.GetDiscordIdBySteamId(tostring(GetPlayerSteamId(player))), discordVoice.GetDiscordIdBySteamId(call.to),
        tostring(GetPlayerSteamId(player)), call.to)
```

Delete a call
```
discordVoice.DeleteCall(call.id_call)
```