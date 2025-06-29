-- 2HOT NOTEHANDLER --

function onCreate()
    precacheSound('Darnell_Lighter')
    precacheSound('Kick_Can_UP')
    precacheSound('Kick_Can_FORWARD')
    precacheSound('Gun_Prep')
    precacheSound('Pico_Bonk')
    for num = 1, 4 do
        precacheSound('shot'..num)
    end
    for note = 0, getProperty('unspawnNotes.length') - 1 do
        if getPropertyFromGroup('unspawnNotes', note, 'noteType') == '2hot-firegun' then
            -- This is how much the player loses health when they miss this note.
            setPropertyFromGroup('unspawnNotes', note, 'missHealth', 0.5)
        end
    end

    makeFlxAnimateSprite('sprayCan')
    loadAnimateAtlas('sprayCan', 'phillyStreets/spraycanAtlas')
    setProperty('sprayCan.x', getProperty('sprayCans.x') - 430)
    setProperty('sprayCan.y', getProperty('sprayCans.y') - 840)
    setObjectOrder('sprayCan', getObjectOrder('sprayCans'))
    addLuaSprite('sprayCan')
    
    makeAnimatedLuaSprite('explosion', 'phillyStreets/spraypaintExplosionEZ')
    addAnimationByPrefix('explosion', 'anim', 'explosion round 1 short0', 24, false)
    setProperty('explosion.x', getProperty('sprayCan.x') + 1050)
    setProperty('explosion.y', getProperty('sprayCan.y') + 150)
    setObjectOrder('explosion', getObjectOrder('sprayCans'))
    addLuaSprite('explosion')
    setProperty('explosion.visible', false)
end

function goodNoteHitPre(membersIndex, noteData, noteType, isSustainNote)
    if noteType == '2hot-firegun' then
        -- Since the player didn't hit the last note, then this one will count as a miss too.
        if gunCocked ~= true then
            setPropertyFromGroup('notes', membersIndex, 'hitCausesMiss', true)
            setPropertyFromGroup('notes', membersIndex, 'noteSplashData.disabled', true)
        end
    end
end

gunCocked = false
function goodNoteHit(membersIndex, noteData, noteType, isSustainNote)
    if noteType == '2hot-cockgun' then
        playAnim('boyfriend', 'cock')
        setProperty('boyfriend.specialAnim', true)
        makeFadingSprite()
        
        playSound('Gun_Prep')
        setOnLuas('gunCocked', true) -- Makes the variables available to all the Lua scipts with those values.
        setOnLuas('casingNum', casingNum + 1)
    elseif noteType == '2hot-firegun' then
        if gunCocked == true then
            playAnim('boyfriend', 'shoot')
            setProperty('boyfriend.specialAnim', true)
            local num = getRandomInt(1, 4)
            playSound('shot'..num)
            
            playAnim('sprayCan')
            setProperty('sprayCan.anim.curFrame', 26)
            setOnLuas('canEndFrame', 42) -- Makes the variables available to all the Lua scipts with those values.
            setOnLuas('gunCocked', false)
            runTimer('darkenStageTween', 1 / 24)
        end
    end
end

function noteMiss(membersIndex, noteData, noteType, isSustainNote)
    if noteType == '2hot-firegun' then    
        playAnim('boyfriend', 'shootMISS')
        setProperty('boyfriend.specialAnim', true)
        playSound('Pico_Bonk')
        setOnLuas('gunCocked', false)
        
        if getHealth() <= 0 then
            setPropertyFromClass('substates.GameOverSubstate', 'characterName', 'pico-explosion-dead')
            setPropertyFromClass('substates.GameOverSubstate', 'deathSoundName', 'fnf_loss_sfx-pico-explode')
            blackenStage()
        end
    end
end

function opponentNoteHit(membersIndex, noteData, noteType, isSustainNote)
    if noteType == '2hot-lightcan' then
        playAnim('dad', 'lightCan')
        setProperty('dad.specialAnim', true)
        playSound('Darnell_Lighter')
    elseif noteType == '2hot-kickcan' then
        playAnim('dad', 'kickCan')
        setProperty('dad.specialAnim', true)
        playSound('Kick_Can_UP')

        playAnim('sprayCan')
        setProperty('sprayCan.anim.curFrame', 0)
        setProperty('sprayCan.visible', true)
        setOnLuas('canEndFrame', 25) -- Makes the variable available to all the Lua scipts with that value.
    elseif noteType == '2hot-kneecan' then
        playAnim('dad', 'kneeCan')
        setProperty('dad.specialAnim', true)
        playSound('Kick_Can_FORWARD')
    end
end

canEndFrame = 0
function onUpdate(elapsed)
    -- This is how we control the animations' speed depending on the 'playbackRate' for Atlas Sprites.
    setProperty('sprayCan.anim.framerate', 24 * playbackRate)
    --[[
        This make it so the animation stop when it's supposed to be,
        instead of continuing on, and looping endlessly.
    ]]
    if getProperty('sprayCan.anim.curFrame') == canEndFrame then
        pauseAnim('sprayCan')
        setProperty('sprayCan.visible', false)
    end
    -- This is for the explosion when the can hits Pico.
    if getProperty('sprayCan.anim.curFrame') == 23 then
        playAnim('explosion', 'anim')
        setProperty('explosion.visible', true)
    end
    if getProperty('explosion.animation.finished') == true then
        setProperty('explosion.visible', false)
    end

    if getProperty('boyfriend.animation.name') == 'shootMISS' then
        if getProperty('boyfriend.animation.finished') == true then
            runTimer('flickeringTween1', 1 / 30, 30)
        end
    end
end
    
function pauseAnim(object)
    runHaxeCode("game.getLuaObject('"..object.."').anim.pause();")
end

function makeFadingSprite()
    makeAnimatedLuaSprite('picoFade', getProperty('boyfriend.imageFile'), getProperty('boyfriend.x'), getProperty('boyfriend.y'))
    addAnimationByPrefix('picoFade', 'anim', getProperty('boyfriend.animation.frameName'), getProperty('boyfriend.animation.frameIndex'), false)
    setObjectOrder('picoFade', getObjectOrder('boyfriendGroup') + 1)
    setProperty('picoFade.alpha', 0.3)
    addLuaSprite('picoFade')

    doTweenX('fadingTweenX', 'picoFade.scale', 1.3, 0.4, 'linear')
    doTweenY('fadingTweenY', 'picoFade.scale', 1.3, 0.4, 'linear')
    doTweenAlpha('fadingTweenAlpha', 'picoFade', 0, 0.4, 'linear')
    
    updateHitbox('picoFade')
    setProperty('picoFade.offset.x', getProperty('boyfriend.offset.x'))
    setProperty('picoFade.offset.y', getProperty('boyfriend.offset.y'))
end

casingNum = 0
function onUpdatePost(elapsed)
    if getProperty('boyfriend.animation.name') == 'cock' then
        if getProperty('boyfriend.animation.curAnim.curFrame') == 3 then
            makeAnimatedLuaSprite('casing'..casingNum, 'phillyStreets/PicoBullet', getProperty('boyfriend.x') + 250, getProperty('boyfriend.y') + 100)
            addAnimationByPrefix('casing'..casingNum, 'pop', 'Pop0', 24, false)
            addAnimationByPrefix('casing'..casingNum, 'anim', 'Bullet0', 24, false)
            addLuaSprite('casing'..casingNum, true)
            playAnim('casing'..casingNum, 'pop')
        end
    end
    for num = 1, casingNum do
        if getProperty('casing'..num..'.animation.name') == 'pop' then
            if getProperty('casing'..num..'.animation.curAnim.curFrame') == 40 then
                startRoll('casing'..num) 
            end
        end
    end
end

--[[
    This makes the bullet roll when the 'pop' animation is finished.
    The roll is randomized, so it won't always end up in the same position.
]]
function startRoll(spriteName)
    randomNum1 = getRandomFloat(3, 10)
    randomNum2 = getRandomFloat(1, 2)
    
    setProperty(spriteName..'.x', getProperty(spriteName..'.x') + getProperty(spriteName..'.frame.offset.x') - 1)
    setProperty(spriteName..'.y', getProperty(spriteName..'.y') + getProperty(spriteName..'.frame.offset.y') + 1)
    setProperty(spriteName..'.angle', 125.1)
    
    setProperty(spriteName..'.velocity.x', 20 * randomNum2)
    setProperty(spriteName..'.drag.x', randomNum1 * randomNum2)
    setProperty(spriteName..'.angularVelocity', 100)
    setProperty(spriteName..'.angularDrag', ((randomNum1 * randomNum2) / (20 * randomNum2)) * 100)

    playAnim(spriteName, 'anim')
end

local stageObjects = {
    'sky1',
    'sky2',
    'sky3',
    'skyline',
    'city',
    'constructionSite',
    'highwayLights',
    'highwayLightMap',
    'highway',
    'smog',
    'cars1',
    'cars2',
    'trafficLight',
    'trafficLightMap',
    'street',
    'sprayCans'
}
function blackenStage()
    setProperty('dad.color', 0x000000)
    setProperty('gf.color', 0x000000)
    for object = 1, #stageObjects do
        setProperty(stageObjects[object]..'.color', 0x000000)
    end
    for num = 1, casingNum do
        setProperty('casing'..num..'.color', 0x000000)
    end
    runTimer('resetBlacken', 1)
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'darkenStageTween' then
        for object = 1, #stageObjects do
            setProperty(stageObjects[object]..'.color', 0x111111)
        end
        for num = 1, casingNum do
            setProperty('casing'..num..'.color', 0x111111)
        end
        runTimer('resetDarkenTween', 1 / 24)
    end
    if tag == 'resetDarkenTween' then
        for object = 1, #stageObjects do
            setProperty(stageObjects[object]..'.color', 0x222222)
            doTweenColor(stageObjects[object]..'LightenTween', stageObjects[object], '0xFFFFFF', 1.4, 'linear')
        end
        for num = 1, casingNum do
            setProperty('casing'..num..'.color', 0x222222)
            doTweenColor('casing'..num..'LightenTween', 'casing'..num, '0xFFFFFF', 1.4, 'linear')
        end
    end
    if tag == 'resetBlacken' then
        setProperty('dad.color', 0xFFFFFF)
        setProperty('gf.color', 0xFFFFFF)
        for object = 1, #stageObjects do
            setProperty(stageObjects[object]..'.color', 0xFFFFFF)
        end
        for num = 1, casingNum do
            setProperty('casing'..num..'.color', 0xFFFFFF)
        end
    end
    if tag == 'flickeringTween1' then
        local visible = not getProperty('boyfriend.visible')
        setProperty('boyfriend.visible', visible)
        if loopsLeft == 0 then
            runTimer('flickeringTween2', 1 / 60, 30)
        end
    end
    if tag == 'flickeringTween2' then
        local visible = not getProperty('boyfriend.visible')
        setProperty('boyfriend.visible', visible)
        if loopsLeft == 0 then
            setProperty('boyfriend.visible', true)
        end
    end
end

---