local shootPlayerFrames = {}
local shootOpponentFrames = {}
for i = 0, 300 do
    shootPlayerFrames[i] = i + 878
    shootOpponentFrames[i] = i
end

local explodePlayerFrames = {}
local explodeOpponentFrames = {}
for i = 301, 576 do
    explodePlayerFrames[(i - 300)] = i + 878
    explodeOpponentFrames[(i - 300)] = i
end

local explodePlayerLoopFrames = {}
local explodeOpponentLoopFrames = {}
for i = 0, 7 do
    explodePlayerLoopFrames[(i + 1)] = explodePlayerFrames[(#explodePlayerFrames - (7 - i))]
    explodeOpponentLoopFrames[(i + 1)] = explodeOpponentFrames[(#explodeOpponentFrames - (7 - i))]
end

local cigarettePlayerFrames = {}
local cigaretteOpponentFrames = {}
for i = 577, 877 do
    cigarettePlayerFrames[(i - 576)] = i + 878
    cigaretteOpponentFrames[(i - 576)] = i
end

function onCreate()
    initSaveData('Pico_Mix_Variables')
    
    makeFlxAnimateSprite('dopplegangerPlayer', getProperty('boyfriend.x') + 45, getProperty('boyfriend.y') + 400)
    loadAnimateAtlas('dopplegangerPlayer', 'philly/cutscenes/pico_doppleganger')
    addAnimationBySymbolIndices('dopplegangerPlayer', 'shoot', 'picoDoppleganger', shootPlayerFrames)
    addAnimationBySymbolIndices('dopplegangerPlayer', 'explode', 'picoDoppleganger', explodePlayerFrames)
    addAnimationBySymbolIndices('dopplegangerPlayer', 'explode-loop', 'picoDoppleganger', explodePlayerLoopFrames, 24, true)
    addAnimationBySymbolIndices('dopplegangerPlayer', 'cigarette', 'picoDoppleganger', cigarettePlayerFrames)
    setObjectOrder('dopplegangerPlayer', getObjectOrder('boyfriendGroup'))
    addLuaSprite('dopplegangerPlayer')

    makeFlxAnimateSprite('dopplegangerOpponent', getProperty('dad.x') + 83, getProperty('dad.y') + 400)
    loadAnimateAtlas('dopplegangerOpponent', 'philly/cutscenes/pico_doppleganger')
    addAnimationBySymbolIndices('dopplegangerOpponent', 'shoot', 'picoDoppleganger', shootOpponentFrames)
    addAnimationBySymbolIndices('dopplegangerOpponent', 'explode', 'picoDoppleganger', explodeOpponentFrames)
    addAnimationBySymbolIndices('dopplegangerOpponent', 'explode-loop', 'picoDoppleganger', explodeOpponentLoopFrames, 24, true)
    addAnimationBySymbolIndices('dopplegangerOpponent', 'cigarette', 'picoDoppleganger', cigaretteOpponentFrames)
    setObjectOrder('dopplegangerOpponent', getObjectOrder('dadGroup'))
    addLuaSprite('dopplegangerOpponent')

    makeAnimatedLuaSprite('cigarette', 'philly/cutscenes/cigarette')
    addAnimationByPrefix('cigarette', 'anim', 'cigarette spit', 24, false)
    setObjectOrder('cigarette', getObjectOrder('gfGroup') + 1)
    addLuaSprite('cigarette')
    setProperty('cigarette.visible', false)

    makeFlxAnimateSprite('bloodPool')
    loadAnimateAtlas('bloodPool', 'philly/cutscenes/bloodPool')
    addLuaSprite('bloodPool')
    setProperty('bloodPool.visible', false)

    for _, music in ipairs({'cutscene', 'cutscene2'}) do
        precacheMusic(music)
    end
    for _, sound in ipairs({'Gasp', 'Cigarette', 'Cigarette2', 'Shoot', 'Explode', 'Spin'}) do
        precacheSound('pico'..sound)
    end
    if not isRunning('custom_events/Set Camera Target') then
        addLuaScript('custom_events/Set Camera Target')
    end
    if not isRunning('custom_events/Set Camera Zoom') then
        addLuaScript('custom_events/Set Camera Zoom')
    end
end

function onCreatePost()
    for _, object in ipairs({'dopplegangerPlayer', 'dopplegangerOpponent', 'cigarette', 'bloodPool'}) do
        runHaxeCode([[
            var obj = getLuaObject("]]..object..[[");
            if (obj.shader != game.boyfriend.shader) {
                obj.shader = game.boyfriend.shader;
            }
        ]])
    end
end

local stopCountdown = true
function onStartCountdown()
    if seenCutscene == false and stopCountdown == true then
        setProperty('camHUD.alpha', 0)
        playCutscene()
        return Function_Stop
    else
        setUpFinishedCutscene()
    end
end

isPlayerShooting = nil
smokerExplodes = nil
shooterCamPos = {}
smokerCamPos = {}
inBetweenCamPos = {}
function playCutscene()
    setProperty('boyfriend.visible', false)
    setProperty('dad.visible', false)
    setUpCutscene()
    triggerEvent('Set Camera Target', 'None,'..tostring(inBetweenCamPos.x)..','..tostring(inBetweenCamPos.y), '0')
    startCutsceneAnim(isPlayerShooting, smokerExplodes)
    runTimer('startCutsceneMusic', 0.001)
    runTimer('moveToSmoker', 4)
    runTimer('moveToShooter', 6.3)
    runTimer('moveBackToSmoker', 8.75)
    if smokerExplodes then
        runTimer('picoBleeds', 11.2)
    else
        runTimer('picoSpitsCigarette', 11.5)
    end
    runTimer('endCutscene', 13)
end

function setUpCutscene()
    isPlayerShooting = getRandomBool(50)
    smokerExplodes = getRandomBool(8)
    setDataFromSave('Pico_Mix_Variables', 'hasPlayerShooted', isPlayerShooting)
    setDataFromSave('Pico_Mix_Variables', 'smokerExploded', smokerExplodes)
	flushSaveData('Pico_Mix_Variables')
    
    if isPlayerShooting then
        setProperty('cigarette.x', getProperty('boyfriend.x') - 310)
        setProperty('cigarette.y', getProperty('boyfriend.y') + 205)
        setProperty('cigarette.flipX', true)

        setProperty('bloodPool.x', getProperty('dad.x') - 1487)
        setProperty('bloodPool.y', getProperty('dad.y') - 171)

        shooterCamPos = {
            x = getMidpointX('boyfriend') - getProperty('boyfriend.cameraPosition[0]') + getProperty('boyfriendCameraOffset[0]') - 100,
            y = getMidpointY('boyfriend') + getProperty('boyfriend.cameraPosition[1]') + getProperty('boyfriendCameraOffset[1]') - 100
        }
        smokerCamPos = {
            x = getMidpointX('dad') + getProperty('dad.cameraPosition[0]') + getProperty('opponentCameraOffset[0]') + 150,
            y = getMidpointY('dad') + getProperty('dad.cameraPosition[1]') + getProperty('opponentCameraOffset[1]') - 100
        }
    else
        setProperty('cigarette.x', getProperty('boyfriend.x') - 478)
        setProperty('cigarette.y', getProperty('boyfriend.y') + 205)

        setProperty('bloodPool.x', getProperty('boyfriend.x') - 793)
        setProperty('bloodPool.y', getProperty('boyfriend.y') - 170)

        shooterCamPos = {
            x = getMidpointX('dad') + getProperty('dad.cameraPosition[0]') + getProperty('opponentCameraOffset[0]') + 150,
            y = getMidpointY('dad') + getProperty('dad.cameraPosition[1]') + getProperty('opponentCameraOffset[1]') - 100
        }
        smokerCamPos = {
            x = getMidpointX('boyfriend') - getProperty('boyfriend.cameraPosition[0]') + getProperty('boyfriendCameraOffset[0]') - 100,
            y = getMidpointY('boyfriend') + getProperty('boyfriend.cameraPosition[1]') + getProperty('boyfriendCameraOffset[1]') - 100
        }
    end
    inBetweenCamPos = {
        x = (shooterCamPos.x + smokerCamPos.x) / 2,
        y = (shooterCamPos.y + smokerCamPos.y) / 2
    }
end

function setUpFinishedCutscene()
    hasPlayerShooted = getDataFromSave('Pico_Mix_Variables', 'hasPlayerShooted')
    smokerExploded = getDataFromSave('Pico_Mix_Variables', 'smokerExploded')
        
    if smokerExploded then
        setProperty('dad.visible', false)
        setProperty('dopplegangerPlayer.visible', false)
        playAnim('dopplegangerOpponent', 'explode-loop')

        setProperty('opponentVocals.volume', 0)
        for i = 0, getProperty('notes.length') - 1 do
            if getPropertyFromGroup('notes', i, 'mustPress') == false then
                setPropertyFromGroup('notes', i, 'ignoreNote', true)
            end
        end
        for i = 0, getProperty('unspawnNotes.length') - 1 do
            if getPropertyFromGroup('unspawnNotes', i, 'mustPress') == false then
                setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true)
            end
        end
        
        setProperty('bloodPool.x', getProperty('dad.x') - 1487)
        setProperty('bloodPool.y', getProperty('dad.y') - 171)
        setProperty('bloodPool.visible', true)
        setProperty('bloodPool.anim.curFrame', getProperty('bloodPool.anim.length') - 1)
    else
        if hasPlayerShooted then
            setProperty('cigarette.x', getProperty('boyfriend.x') - 310)
            setProperty('cigarette.y', getProperty('boyfriend.y') + 205)
            setProperty('cigarette.flipX', true)
        else
            setProperty('cigarette.x', getProperty('boyfriend.x') - 478)
            setProperty('cigarette.y', getProperty('boyfriend.y') + 205)
        end
        setProperty('cigarette.visible', true)
        callMethod('cigarette.animation.curAnim.finish')
        setProperty('dopplegangerPlayer.visible', false)
        setProperty('dopplegangerOpponent.visible', false)
    end
end

function startCutsceneAnim(isPlayerShooting, smokerExplodes)
    local shooter = nil
    local smoker = nil
    if isPlayerShooting then
        shooter = 'Player'
        smoker = 'Opponent'
    else
        shooter = 'Opponent'
        smoker = 'Player'
    end
    
    playAnim('doppleganger'..shooter, 'shoot')
    if smokerExplodes then
        playAnim('doppleganger'..smoker, 'explode')
        runTimer('picoFuckinDies', 8.75)
    else
        playAnim('doppleganger'..smoker, 'cigarette')
    end

    runTimer('delayGasp', 0.3)
    runTimer('picoPointsCigarette', 3.7)
    runTimer('picoShoots', 6.29)
    runTimer('picoSpinsGun', 10.33)
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'beatHit' then
        if getProperty('gf.animation.finished') then
            characterDance('gf')
        end
    end
    if tag == 'startCutsceneMusic' then
        if smokerExplodes then
            playMusic('picoCutscene/cutscene2')
        else
            playMusic('picoCutscene/cutscene')
        end
        runTimer('beatHit', 60 / 150, 0)
    end
    if tag == 'delayGasp' then
        playSound('picoCutscene/picoGasp')
    end
    if tag == 'picoPointsCigarette' then
        if smokerExplodes then
            playSound('picoCutscene/picoCigarette2')
        else
            playSound('picoCutscene/picoCigarette')
        end
    end
    if tag == 'moveToSmoker' then
        triggerEvent('Set Camera Target', 'None,'..tostring(smokerCamPos.x)..','..tostring(smokerCamPos.y))
    end
    if tag == 'picoShoots' then
        playSound('picoCutscene/picoShoot')
    end
    if tag == 'moveToShooter' then
        triggerEvent('Set Camera Target', 'None,'..tostring(shooterCamPos.x)..','..tostring(shooterCamPos.y))
    end
    if tag == 'picoFuckinDies' then
        playSound('picoCutscene/picoExplode')
    end
    if tag == 'moveBackToSmoker' then
        triggerEvent('Set Camera Target', 'None,'..tostring(smokerCamPos.x)..','..tostring(smokerCamPos.y))
        if smokerExplodes then
            playAnim('gf', 'drop70')
            setProperty('gf.specialAnim', true)
        end
    end
    if tag == 'picoSpinsGun' then
        playSound('picoCutscene/picoSpin')
    end
    if tag == 'picoBleeds' then
        playAnim('bloodPool', 'poolAnim')
        setProperty('bloodPool.visible', true)
    end
    if tag == 'picoSpitsCigarette' then
        playAnim('cigarette', 'anim', true)
        setProperty('cigarette.visible', true)
    end
    if tag == 'endCutscene' then
        if smokerExplodes == false or isPlayerShooting == true then
            stopCountdown = false
            startCountdown()
            setProperty('camHUD.alpha', 1)
            cancelTimer('beatHit')
        end
        if smokerExplodes == true then
            if isPlayerShooting == true then
                setProperty('dopplegangerPlayer.visible', false)
                setProperty('boyfriend.visible', true)
                setProperty('opponentVocals.volume', 0)
                for i = 0, getProperty('notes.length') - 1 do
                    if getPropertyFromGroup('notes', i, 'mustPress') == false then
                        setPropertyFromGroup('notes', i, 'ignoreNote', true)
                    end
                end
                for i = 0, getProperty('unspawnNotes.length') - 1 do
                    if getPropertyFromGroup('unspawnNotes', i, 'mustPress') == false then
                        setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true)
                    end
                end
            else
                setProperty('dopplegangerOpponent.visible', false)
                setProperty('dad.visible', true)
                runTimer('fadeOutScreen', 1)
                runTimer('goBackToMenu', 2)
            end
        else
            setProperty('dopplegangerPlayer.visible', false)
            setProperty('boyfriend.visible', true)
            setProperty('dopplegangerOpponent.visible', false)
            setProperty('dad.visible', true)
        end
    end
    if tag == 'fadeOutScreen' then
        cameraFade('game', '000000', 1)
    end
    if tag == 'goBackToMenu' then
        endSong()
    end
end

function onUpdate(elapsed)
    if getProperty('dopplegangerOpponent.anim.finished') then
        if getProperty('dopplegangerOpponent.anim.curSymbol.name') == 'explode' then
            playAnim('dopplegangerOpponent', 'explode-loop')
        end
    end
    if getProperty('dopplegangerPlayer.anim.finished') then
        if getProperty('dopplegangerPlayer.anim.curSymbol.name') == 'explode' then
            playAnim('dopplegangerPlayer', 'explode-loop')
        end
    end
    if getProperty('bloodPool.anim.curFrame') >= getProperty('bloodPool.anim.length') - 1 then
        callMethod('bloodPool.anim.pause')
    end
end