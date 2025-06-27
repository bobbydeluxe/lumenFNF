local characterCheck = nil
local useRetrySprite = true
local useGfOverlay = true
local gfOverlayProperties = {
    offsetX = 0,
    offsetY = 0,
    imageFile = '',
    animationName = '',
    isPixelSprite = false
}

function onCreatePost()
    characterCheck = stringStartsWith(boyfriendName, 'bf')
    if characterCheck == true then
        pauseMusic = getPropertyFromClass('backend.ClientPrefs', 'data.pauseMusic')
        setUpDeathProperties(boyfriendName)

        runHaxeCode([[
            function getScreenPosition(character:String) {
                var characterPos:Array<Dynamic>;
                switch(character) {
                    case 'boyfriend':
                        characterPos = game.boyfriend.getScreenPosition();
                    case 'dad':
                        characterPos = game.dad.getScreenPosition();
                    case 'gf':
                        characterPos = game.gf.getScreenPosition();
                    default:
                        return;
                }
                return [characterPos.x, characterPos.y];
            }
        ]])
    end
end

function onPause()
    --[[
        Replaces pause music with a custom '-(pixel)' version if available,
        for Week 6 pixel-themed BF variants. Falls back to default if not found.
    ]]
    if characterCheck == true then
        fileName = pauseMusic:gsub(' ', '-'):lower()
        if stringEndsWith(characterName, 'pixel') then
            if checkFileExists('music/'..fileName..'-(pixel).ogg') then
                setPropertyFromClass('backend.ClientPrefs', 'data.pauseMusic', pauseMusic..' (Pixel)')
            end
        end
    end
end

function onDestroy()
    --[[
        Restores the default pause music when exiting the song,
        to prevent persistent changes across non-BF characters.
    ]]
    if characterCheck == true then
        setPropertyFromClass('backend.ClientPrefs', 'data.pauseMusic', pauseMusic)
    end
end

local gfPos = {}
function onGameOver()
    if characterCheck == true and useGfOverlay == true then
        gfPos = runHaxeFunction('getScreenPosition', {'gf'})
    end
end

function onGameOverStart()
    if characterCheck == true then
        if useRetrySprite == true then
            makeAnimatedLuaSprite('gameOverRetry', 'characters/gameover/picoMixStuff/Pico_Death_Retry', getPropertyFromGameOver('boyfriend.x') + 205, getPropertyFromGameOver('boyfriend.y') - 80)
            addAnimationByPrefix('gameOverRetry', 'idle', 'Retry Text Loop0')
            addAnimationByPrefix('gameOverRetry', 'confirm', 'Retry Text Confirm0', 24, false)
            addOffset('gameOverRetry', 'confirm', 250, 200)
            addLuaSprite('gameOverRetry', true)
            setProperty('gameOverRetry.visible', false)
        end

        if useGfOverlay == true then
            makeAnimatedLuaSprite('neneDeathSprite', gfOverlayProperties.imageFile, gfPos[1] + gfOverlayProperties.offsetX, gfPos[2] + gfOverlayProperties.offsetY)
            addAnimationByPrefix('neneDeathSprite', 'throw', gfOverlayProperties.animationName, 24, false)
            addLuaSprite('neneDeathSprite', true)
            if gfOverlayProperties.isPixelSprite == true then
                scaleObject('neneDeathSprite', 6, 6)
                setProperty('neneDeathSprite.antialiasing', false)
            end
        end
    end
end

function onUpdate(elapsed)
    if characterCheck == true and inGameOver == true then
        if useGfOverlay == true then
            if getProperty('neneDeathSprite.animation.finished') then
                setProperty('neneDeathSprite.visible', false)
            end
        end

        if useRetrySprite == true then
            if getPropertyFromGameOver('boyfriend.animation.curAnim.name') == 'firstDeath' then
                if getPropertyFromGameOver('boyfriend.animation.curAnim.curFrame') == 35 then
                    playAnim('gameOverRetry', 'idle')
                    setProperty('gameOverRetry.visible', true)
                end
            end
        end
    end
end

function onGameOverConfirm(isNotGoingToMenu)
    if isNotGoingToMenu == true and characterCheck == true then
        if useRetrySprite == true then
            playAnim('gameOverRetry', 'confirm')
            setProperty('gameOverRetry.visible', true)
        end
    end
end

function setUpDeathProperties(characterName)
    setPropertyFromGameOver('characterName', 'bf-dead')
    setPropertyFromGameOver('deathSoundName', 'fnf_loss_sfx')
    setPropertyFromGameOver('loopSoundName', 'gameOver')
    setPropertyFromGameOver('endSoundName', 'gameOverEnd')
    useRetrySprite = false
    useGfOverlay = false

    if stringEndsWith(characterName, 'pixel') then
        useRetrySprite = false
        setPropertyFromGameOver('characterName', 'bf-pixel-dead')
        setPropertyFromGameOver('deathSoundName', 'fnf_loss_sfx-pixel')
        setPropertyFromGameOver('loopSoundName', 'gameOver-pixel')
        setPropertyFromGameOver('endSoundName', 'gameOverEnd-pixel')
    elseif stringEndsWith(characterName, 'gf') then
        setPropertyFromGameOver('characterName', 'bf-holding-gf-dead')
    end
end

function getPropertyFromGameOver(property)
    if getPropertyFromClass('substates.GameOverSubstate', property) ~= nil then
        return getPropertyFromClass('substates.GameOverSubstate', property)
    else
        return getPropertyFromClass('substates.GameOverSubstate', 'instance.'..property)
    end
end

function setPropertyFromGameOver(property, value)
    if getPropertyFromClass('substates.GameOverSubstate', property) ~= nil then
        setPropertyFromClass('substates.GameOverSubstate', property, value)
    else
        setPropertyFromClass('substates.GameOverSubstate', 'instance.'..property, value)
    end
end
