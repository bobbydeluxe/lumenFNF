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
    characterCheck = stringStartsWith(boyfriendName, 'pico')
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
        Checks and replaces the Pause Menu music to the '-(pico)' version, if there's one.
        If not, it'll keep the original one.
        Ex: 'Tea Time' will stay the same since there isn't a 'tea-time-(pico)' present in the files.
    ]]
    if characterCheck == true then
        fileName = pauseMusic:gsub(' ', '-'):lower()
        if checkFileExists('music/'..fileName..'-(pico).ogg') then
            setPropertyFromClass('backend.ClientPrefs', 'data.pauseMusic', pauseMusic..' (Pico)')
        end
    end
end

function onDestroy()
    --[[ 
        Since we don't want the Pause Menu to stay stuck to the '-pico' version all the time,
        we revert it back to normal to avoid any issues and keep it exclusive to our character.
    ]]
    if characterCheck == true and stringEndsWith(getPropertyFromClass('backend.ClientPrefs', 'data.pauseMusic'), ' (Pico)') then
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
    setPropertyFromGameOver('characterName', 'pico-dead')
    setPropertyFromGameOver('deathSoundName', 'fnf_loss_sfx-pico')
    setPropertyFromGameOver('loopSoundName', 'gameOver-pico')
    setPropertyFromGameOver('endSoundName', 'gameOverEnd-pico')
    gfOverlayProperties.offsetX = 150
    gfOverlayProperties.imageFile = 'characters/gameover/picoMixStuff/NeneKnifeToss'
    gfOverlayProperties.animationName = 'knife toss0'

    if stringEndsWith(characterName, 'christmas') then
        setPropertyFromGameOver('characterName', 'pico-christmas-dead')
        gfOverlayProperties.imageFile = 'characters/gameover/picoMixStuff/neneChristmasKnife'
        gfOverlayProperties.animationName = 'knife toss xmas0'
    elseif stringEndsWith(characterName, 'pixel') then
        useRetrySprite = false
        setPropertyFromGameOver('characterName', 'pico-pixel-dead')
        setPropertyFromGameOver('deathSoundName', 'fnf_loss_sfx-pixel-pico')
        setPropertyFromGameOver('loopSoundName', 'gameOver-pixel-pico')
        setPropertyFromGameOver('endSoundName', 'gameOverEnd-pixel-pico')
        gfOverlayProperties.offsetX = 0
        gfOverlayProperties.offsetY = -200
        gfOverlayProperties.imageFile = 'characters/gameover/picoMixStuff/nenePixelKnifeToss'
        gfOverlayProperties.animationName = 'knifetosscolor0'
        gfOverlayProperties.isPixelSprite = true
    elseif stringEndsWith(characterName, 'nene') then
        useRetrySprite = false
        useGfOverlay = false
        setPropertyFromGameOver('characterName', 'pico-holding-nene-dead')
        setPropertyFromGameOver('deathSoundName', 'fnf_loss_sfx-pico-and-nene')
    elseif stringEndsWith(characterName, 'blazin') then
        useRetrySprite = false
        useGfOverlay = false
        setPropertyFromGameOver('characterName', 'pico-blazin')
        setPropertyFromGameOver('deathSoundName', 'fnf_loss_sfx-pico-gutpunch')
    end
end

function getPropertyFromGameOver(property)
    getPropertyFromClass('substates.GameOverSubstate', 'instance.'..property)
end

function setPropertyFromGameOver(property, value)
    if getPropertyFromClass('substates.GameOverSubstate', property) ~= nil then
        setPropertyFromClass('substates.GameOverSubstate', property, value)
    else
        setPropertyFromClass('substates.GameOverSubstate', 'instance.'..property, value)
    end
end