function onCreatePost()
    addLuaScript('characters/props/speaker')
    callScript('characters/props/speaker', 'createSpeaker', {'pico-speaker', -190, 438}) -- {characterName, offsetX, offsetY}
end