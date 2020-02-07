function AssertSteamIdWithDiscord(steamId, discordId)
    if IsAlreadyAssoc(steamId) then
        CallEvent("DiscordVoice:ResultAssert", false, steamId, discordId)
        return
    end
    local r = http_create()
	http_set_resolver_protocol(r, "any")
	http_set_protocol(r, "http")
	http_set_host(r, "localhost")
	http_set_port(r, 3000)
	http_set_target(r, "/call/associate?steamId="..steamId.."&discordId="..discordId)
	http_set_verb(r, "get")
	http_set_timeout(r, 60)
	http_set_version(r, 11)
	http_set_keepalive(r, false)
    http_set_field(r, "user-agent", "Onset Server "..GetGameVersionString())
    if http_send(r, function()
        local body = http_result_body(r)
        local data = jsondecode(body)
        if data.result then
            SaveAssoc(steamId, discordId)
        end
        CallEvent("DiscordVoice:ResultAssert", data.result, steamId, discordId)
    end) == false then
		callback(false, nil)
		http_destroy(r)
	end
end
AddFunctionExport("AssertSteamIdWithDiscord", AssertSteamIdWithDiscord)

function CreateCall(playerDiscordId1, playerDiscordId2, extraParam1, extraParam2)
    local r = http_create()
	http_set_resolver_protocol(r, "any")
	http_set_protocol(r, "http")
	http_set_host(r, "localhost")
	http_set_port(r, 3000)
	http_set_target(r, "/call/create?player1="..playerDiscordId1.."&player2="..playerDiscordId2)
	http_set_verb(r, "get")
	http_set_timeout(r, 30)
	http_set_version(r, 11)
	http_set_keepalive(r, false)
    http_set_field(r, "user-agent", "Onset Server "..GetGameVersionString())
    if http_send(r, function()
        local body = http_result_body(r)
        local data = jsondecode(body)
        CallEvent("DiscordVoice:CallCreated", data.result, data.callId, playerDiscordId1, playerDiscordId2, extraParam1, extraParam2)
    end) == false then
		callback(false, nil)
		http_destroy(r)
	end
end
AddFunctionExport("CreateCall", CreateCall)

function DeleteCall(callId)
    local r = http_create()
	http_set_resolver_protocol(r, "any")
	http_set_protocol(r, "http")
	http_set_host(r, "localhost")
	http_set_port(r, 3000)
	http_set_target(r, "/call/delete?callId="..callId)
	http_set_verb(r, "get")
	http_set_timeout(r, 30)
	http_set_version(r, 11)
	http_set_keepalive(r, false)
    http_set_field(r, "user-agent", "Onset Server "..GetGameVersionString())
    if http_send(r, function()
        local body = http_result_body(r)
        local data = jsondecode(body)
        CallEvent("DiscordVoice:CallDeleted", data.result)
    end) == false then
		callback(false, nil)
		http_destroy(r)
	end
end
AddFunctionExport("DeleteCall", DeleteCall)

function CreateFileIfNotExist(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    if f == nil then
        f = io.open(file, "w")
        f:write("{}")
        f:close()
    end
  end

function SaveAssoc(steamId, discordId) 
    CreateFileIfNotExist("discord_link.json")
    local f = io.open("discord_link.json", "rb")
    local content = f:read("*all")
    f:close()

    local data = jsondecode(content)
    data[steamId] = discordId
    f = io.open("discord_link.json", "w")
    f:write(jsonencode(data))
    f:close()
end

function IsAlreadyAssoc(steamId) 
    CreateFileIfNotExist("discord_link.json")
    local f = io.open("discord_link.json", "rb")
    local content = f:read("*all")
    f:close()
    
    local data = jsondecode(content)
    return data[steamId] ~= nil
end
AddFunctionExport("IsAlreadyAssoc", IsAlreadyAssoc)

function GetDiscordIdBySteamId(steamId)
    CreateFileIfNotExist("discord_link.json")
    local f = io.open("discord_link.json", "rb")
    local content = f:read("*all")
    f:close()
    
    local data = jsondecode(content)
    return data[steamId]
end
AddFunctionExport("GetDiscordIdBySteamId", GetDiscordIdBySteamId)