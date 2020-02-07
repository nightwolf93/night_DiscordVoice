const Discord = require('discord.js');
const uuidv1 = require('uuid/v1');
const client = new Discord.Client();
const express = require('express')

const guildId = ""; // Put with discord server id here
const categoryId = ""; // Put the category on your discord where calls will be created
let guild = null;

let calls = [];

client.once('ready', async () => {
    guild = client.guilds.find(x => x.id == guildId);
});

const createCallChannel = async (playerId1, playerId2) => {
    const id = uuidv1();
    const tempChannel = await guild.createChannel("call-"+id, {type: "voice", parent: categoryId, userLimit: 2})

    const discordUser1 = await guild.members.find(x => x.id == playerId1);
    const discordUser2 = await guild.members.find(x => x.id == playerId2);

    if(discordUser1 == null || discordUser2 == null) {
        return {result: false};
    }
    if(discordUser1.voiceChannelID == null || discordUser2.voiceChannelID == null) {
        return {result: false};
    }
    const lastChannelPlayer1 = discordUser1.voiceChannelID;
    const lastChannelPlayer2 = discordUser2.voiceChannelID;

    await discordUser1.setVoiceChannel(tempChannel.id);
    await discordUser2.setVoiceChannel(tempChannel.id);

    calls[id] = {callId: id, channel: tempChannel, player1: {
        id: playerId1,
        lastChannel: lastChannelPlayer1
    }, player2: {
        id: playerId2,
        lastChannel: lastChannelPlayer2
    }}
    
    return {result: true, callId: id};
}

const deleteCallChannel = async (callId) => {
    const call = calls[callId];
    if(call == null) {
        return { result: false }
    }
    
    const discordUser1 = await guild.members.find(x => x.id == call.player1.id);
    const discordUser2 = await guild.members.find(x => x.id == call.player2.id);

    if(discordUser1 != null) {
        try {
            await discordUser1.setVoiceChannel(call.player1.lastChannel)
        }catch(ex) {
            console.log("can't move back player1")
        }
    }
    if(discordUser2 != null) {
        try {
            await discordUser2.setVoiceChannel(call.player2.lastChannel)
        }catch(ex) {
            console.log("can't move back player2")
        }
    }

    await call.channel.delete()
    delete calls[callId];

    return { result: true }
}

const app = express()
app.get('/call/create', async(req, res) => {
    const call = await createCallChannel(req.query.player1, req.query.player2)
    res.send({
        result: call.result,
        callId: call.callId
    })
})

app.get('/call/delete', async(req, res) => {
    const call = await deleteCallChannel(req.query.callId)
    res.send({
        result: call.result
    })
})

app.get('/call/associate', async(req, res) => {
    const discordUser = await guild.members.find(x => x.id == req.query.discordId);
    if(discordUser == null) {
        return res.send({result: false})
    }
    const dmchannel = await discordUser.createDM()
    dmchannel.send("Association du compte Steam: **"+req.query.steamId+"** avec votre compte discord, répondre **!oui** si c'est vous.")
    try {
        await dmchannel.awaitMessages(m => m.content.toLowerCase().startsWith('!oui'), { max: 1, time: 30000, errors: ['time']});
        dmchannel.send("Merci votre compte Steam est désormais lié à votre compte Discord")
        return res.send({result: true})
    }catch(ex) {
        return res.send({result: false})
    }
})

app.listen(3000, function () {
    client.login("<put your discord app token>")
})