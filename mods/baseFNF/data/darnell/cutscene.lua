local cutsceneFinished = false
local stopCoutdown = true
local videoFinished = false

local cameraTargetBF = { -- used for post-video cutscene
    x = getMidpointX('boyfriend'),
    y = getMidpointY('boyfriend')
}
local cameraTargetDad = {
    x = getMidpointX('dad'),
    y = getMidpointY('dad')
}

function onCreatePost()
    if isStoryMode == true and seenCutscene == false then
        makeLuaSprite('blackScreen')
        makeGraphic('blackScreen', 2000, 2500, '000000')
        screenCenter('blackScreen')
        setObjectCamera('blackScreen', 'camOther')
        addLuaSprite('blackScreen', true)

        makeAnimatedLuaSprite('sprayCan', 'phillyStreets/wked1_cutscene_1_can', getProperty('sprayCans.x') + 30, getProperty('sprayCans.y') - 320)
        addAnimationByPrefix('sprayCan', 'forward', 'can kick quick0', 24, false)
        addAnimationByPrefix('sprayCan', 'up', 'can kicked up0', 24, false)
        setObjectOrder('sprayCan', getObjectOrder('sprayCans'))
        addLuaSprite('sprayCan')
        setProperty('sprayCan.visible', false)

        makeFlxAnimateSprite('sprayCanExplosion')
        loadAnimateAtlas('sprayCanExplosion', 'phillyStreets/spraycanAtlas')
        setProperty('sprayCanExplosion.x', getProperty('sprayCans.x') - 430)
        setProperty('sprayCanExplosion.y', getProperty('sprayCans.y') - 840)
        setObjectOrder('sprayCanExplosion', getObjectOrder('sprayCans'))
        addLuaSprite('sprayCanExplosion')
        setProperty('sprayCanExplosion.visible', false)

        setProperty('camGame.zoom', 1.3)
        setProperty('camHUD.visible', false)
        startVideo('darnellCutscene') -- Before I used the Video Sprite script.
    end

    cameraTargetBF = {
        x = getMidpointX('boyfriend') - getProperty('boyfriend.cameraPosition[0]') + getProperty('boyfriendCameraOffset[0]') - 100,
        y = getMidpointY('boyfriend') + getProperty('boyfriend.cameraPosition[1]') + getProperty('boyfriendCameraOffset[1]') - 100
    }
    cameraTargetDad = {
        x = getMidpointX('dad') + getProperty('dad.cameraPosition[0]') + getProperty('opponentCameraOffset[0]') + 150,
        y = getMidpointY('dad') + getProperty('dad.cameraPosition[1]') + getProperty('opponentCameraOffset[1]') - 100
    }
end

playVideo = true
playDialogue = true

function onStartCountdown()
	if isStoryMode and not seenCutscene then
		if playVideo then --Video cutscene plays first
			playVideo = false
			return Function_Stop --Prevents the song from starting naturally
		elseif playDialogue then --Once the video ends it calls onStartCountdown again. Play dialogue this time
			playCutscene() --"breakfast" is the dialogue music file from "music/" folder
			playDialogue = false
			return Function_Stop --Prevents the song from starting naturally
		end
	end
	return Function_Continue --Played video and dialogue, now the song can start normally
end

function playCutscene()
    setProperty('inCutscene', true)
    runHaxeCode('FlxG.camera.target = null;') -- Makes the camera lose focus on 'camFollow'.
    playAnim('boyfriend', 'intro1')
    runTimer('setUpCutscene', 0.1)
    runTimer('startCutscene', 0.7)
    runTimer('moveOutCamera', 2)
    runTimer('lightCan', 5)
    runTimer('cockGun', 6)
    runTimer('kickCan', 6.4)
    runTimer('kneeCan', 6.9)
    runTimer('fireGun', 7.1)
    runTimer('darnellLaugh', 7.9)
    runTimer('neneLaugh', 8.2)
    runTimer('endCutscene', 10)
end

function onUpdatePost(elapsed)
    if getProperty('inCutscene') == true then
        if getProperty('boyfriend.animation.name') == 'cock' then
            if getProperty('boyfriend.animation.curAnim.curFrame') == 3 then
                makeAnimatedLuaSprite('casing', 'phillyStreets/PicoBullet', getProperty('boyfriend.x') + 250, getProperty('boyfriend.y') + 100)
                addAnimationByPrefix('casing', 'pop', 'Pop0', 24, false)
                addAnimationByPrefix('casing', 'anim', 'Bullet0', 24, false)
                addLuaSprite('casing', true)
                playAnim('casing', 'pop')
            end
        end
        if getProperty('casing.animation.name') == 'pop' then
            if getProperty('casing.animation.curAnim.curFrame') == 40 then
                startRoll('casing') 
            end
        end

        if getProperty('sprayCanExplosion.anim.finished') then
            setProperty('sprayCanExplosion.visible', false)
        end
        setProperty('sprayCanExplosion.anim.framerate', 24 * playbackRate)
    end
end

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
    'street'
}

local targetX, targetY = 0, 0
function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'setUpCutscene' then
        setProperty('camGame.scroll.x', cameraTargetBF.x + 250 - screenWidth / 2)
        setProperty('camGame.scroll.y', cameraTargetBF.y + 30 - screenHeight / 2)
    end
    if tag == 'startCutscene' then
        playMusic('darnellCanCutscene')
        runTimer('beatHit', 60 / 168, 0)
        startTween('removeBlackScreen', 'blackScreen', {alpha = 0}, 2, {startDelay = 0.3})
    end
    if tag == 'moveOutCamera' then
        targetX = cameraTargetDad.x + 150
        targetY = cameraTargetDad.y
        startTween('moveCamera1', 'camGame.scroll', {x = targetX - screenWidth / 2, y = targetY - screenHeight / 2}, 2.5, {ease = 'quadInOut'})
        doTweenZoom('zoomOutCamera', 'camGame', 0.66, 2.5, 'quadInOut')
    end
    if tag == 'lightCan' then
        playAnim('dad', 'lightCan', true)
        playSound('Darnell_Lighter')
    end
    if tag == 'cockGun' then
        targetX = cameraTargetDad.x + 230
        targetY = cameraTargetDad.y
        startTween('moveCamera2', 'camGame.scroll', {x = targetX - screenWidth / 2, y = targetY - screenHeight / 2}, 0.4, {ease = 'backOut'})
        playAnim('boyfriend', 'cock')
        playSound('Gun_Prep')
    end
    if tag == 'kickCan' then
        playAnim('dad', 'kickCan', true)
        playSound('Kick_Can_UP')
        playAnim('sprayCan', 'up')
        setProperty('sprayCan.visible', true)
    end
    if tag == 'kneeCan' then
        playAnim('dad', 'kneeCan', true)
        playSound('Kick_Can_FORWARD')
        playAnim('sprayCan', 'forward')
    end
    if tag == 'fireGun' then
        targetX = cameraTargetDad.x + 150
        targetY = cameraTargetDad.y
        startTween('moveCamera3', 'camGame.scroll', {x = targetX - screenWidth / 2, y = targetY - screenHeight / 2}, 1, {ease = 'quadInOut'})
        playAnim('boyfriend', 'intro2')
        setProperty('boyfriend.specialAnim', true)
        local num = getRandomInt(1, 4)
        playSound('shot'..num)

        playAnim('sprayCanExplosion')
        setProperty('sprayCanExplosion.anim.curFrame', 26)
        setProperty('sprayCanExplosion.visible', true)
        setProperty('sprayCan.visible', false)
        runTimer('darkenStageTween', 1 / 24)
    end
    if tag == 'darnellLaugh' then
        playAnim('dad', 'laughCutscene', true)
        playSound('darnell_laugh', 0.6)
    end
    if tag == 'neneLaugh' then
        playAnim('gf', 'laughCutscene', true)
        playSound('nene_laugh', 0.6)
    end
    if tag == 'endCutscene' then
        stopCoutdown = false
        cancelTimer('beatHit')
        startCountdown()
        setProperty('camGame.scroll.x', cameraTargetDad.x + 150 - screenWidth / 2)
        setProperty('camGame.scroll.y', cameraTargetDad.y - screenHeight / 2)
        targetX = cameraTargetDad.x + 300
        targetY = cameraTargetDad.y
        startTween('moveCamera4', 'camGame.scroll', {x = targetX - screenWidth / 2, y = targetY - screenHeight / 2}, 2 / playbackRate, {ease = 'sineInOut', onComplete = 'onTweenCompleted'})
        doTweenZoom('returnToNormalZoom', 'camGame', 0.77, 2 / playbackRate, 'sineInOut')
        setProperty('camHUD.visible', true)
    end
    if tag == 'beatHit' then
        if getProperty('dad.animation.finished') then
            if getProperty('dad.animation.curAnim.name') ~= 'lightCan' then
                characterDance('dad')
            end
        end
        if getProperty('gf.animation.finished') then
            characterDance('gf')
        end
    end
    if tag == 'darkenStageTween' then
        for object = 1, #stageObjects do
            setProperty(stageObjects[object]..'.color', 0x111111)
        end
        runTimer('resetDarkenTween', 1 / 24)
    end
    if tag == 'resetDarkenTween' then
        for object = 1, #stageObjects do
            setProperty(stageObjects[object]..'.color', 0x222222)
            doTweenColor(stageObjects[object]..'LightenTween', stageObjects[object], '0xFFFFFF', 1.4, 'linear')
        end
    end
end

function onTweenCompleted(tag)
    if tag == 'moveCamera4' then
        cutsceneFinished = true
        runHaxeCode('FlxG.camera.target = game.camFollow;') -- Makes the camera focus back on 'camFollow'.
    end
end

function onSongStart()
    runHaxeCode('FlxG.camera.target = game.camFollow;')
end