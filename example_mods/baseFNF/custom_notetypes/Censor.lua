--[[
    If you plan on using this note type in another mod, make sure to follow these instructions:

    If you're on 1.0 or higher:
    Just go into Character Editor and add the censor animations by naming them like the sing anims and add 'censor'.
    Ex: If the animation is for the right note, then name it 'singRIGHTcensor'.

    If you're on 0.7.3 or lower:
    1) The image and .XML files must be placed in 'YourModName/images/characters'.

    2) The image has to be named like the character's JSON file followed with '_Censored'.
       Ex: If the original name file is 'bf-opponent', then the censored file must be named 'bf-opponent_Censored'.
    
    3) The prefix animations inside the .XML file must be named after the character's JSON file name,
       followed by 'swear', then the note's direction in lower case.
       Ex: If the character is named 'bf-opponent', and that your animation is intended for the right note,
       then the animation's prefix inside the .XML file must be 'bf-opponent swear right' (DON'T FORGET THE SPACES!!!).

    If the instructions have been followed correctly, then the note type will handle the rest by itself.
    If it doesn't work, check if you did something wrong, or close and re-open the game.
    Also, if you release the mod publicly, please credit me for this, it'll be greatly appreciated! - Ledonic
]]

function onCreate()
    if checkFileExists(currentModDirectory..'/images/characters/'..boyfriendName..'_Censored.png') then
        precacheImage('characters/'..boyfriendName..'_Censored')
    end
    if checkFileExists(currentModDirectory..'/images/characters/'..dadName..'_Censored.png') then
        precacheImage('characters/'..dadName..'_Censored')
    end
    runHaxeCode([[
        function applyCensorShader(isDad:Bool) {
            if (isDad) game.getLuaObject('dadCensor').shader = game.dad.shader;
            else game.getLuaObject('boyfriendCensor').shader = game.boyfriend.shader;
        }
    ]])
end

local showCensorBFSprite = false
local showCensorDadSprite = false
local noteDirection = {'LEFT', 'DOWN', 'UP', 'RIGHT'}
function goodNoteHit(membersIndex, noteData, noteType, isSustainNote)
    if noteType == 'Censor' then
        if callMethod('boyfriend.animOffsets.exists', {'sing'..noteDirection[noteData + 1]..'censor'}) then
            playAnim('boyfriend', 'sing'..noteDirection[noteData + 1]..'censor')
            setProperty('boyfriend.specialAnim', true)
        else
            makeCensorSprite(noteData, false)
        end
    end
end

function opponentNoteHit(membersIndex, noteData, noteType, isSustainNote)
    if noteType == 'Censor' then
        if callMethod('dad.animOffsets.exists', {'sing'..noteDirection[noteData + 1]..'censor'}) then
            playAnim('dad', 'sing'..noteDirection[noteData + 1]..'censor')
            setProperty('dad.specialAnim', true)
        else
            makeCensorSprite(noteData, true)
        end
    end
end

local curSingBFAnim = nil
local curSingDadAnim = nil
function onUpdatePost(elapsed)
    if showCensorBFSprite == true and getBFAnim() ~= 'sing'..curSingBFAnim then
        setProperty('boyfriend.visible', true)
        setProperty('boyfriendCensor.visible', false)
        showCensorBFSprite = false
    end
    if showCensorDadSprite == true and getDadAnim() ~= 'sing'..curSingDadAnim then
        setProperty('dad.visible', true)
        setProperty('dadCensor.visible', false)
        showCensorDadSprite = false
    end
end

function makeCensorSprite(noteData, isDad)
    local character = nil
    if isDad == true then
        character = 'dad'
    else
        character = 'boyfriend'
    end
    if checkFileExists(currentModDirectory..'/images/characters/'.._G[character..'Name']..'_Censored.png') then
        if not luaSpriteExists(character..'Censor') then
            makeAnimatedLuaSprite(character..'Censor', 'characters/'.._G[character..'Name']..'_Censored', getProperty(character..'.x'), getProperty(character..'.y'))
            setObjectOrder(character..'Censor', getObjectOrder(character..'Group'))
            addLuaSprite(character..'Censor', true)
            setProperty(character..'Censor.scrollFactor.x', getProperty(character..'.scrollFactor.x'))
            setProperty(character..'Censor.scrollFactor.y', getProperty(character..'.scrollFactor.y'))
            setProperty(character..'Censor.flipX', getProperty(character..'.flipX'))
        end
        if not callMethod(character..'Censor.animOffsets.exists', {noteDirection[noteData + 1]}) then
            addAnimationByPrefix(character..'Censor', noteDirection[noteData + 1], _G[character..'Name']..' swear '..noteDirection[noteData + 1]:lower(), 24, false)
            addOffset(character..'Censor', noteDirection[noteData + 1], getProperty(character..'.offset.x'), getProperty(character..'.offset.y'))
        end

        runHaxeFunction('applyCensorShader', {isDad})
        setProperty(character..'.visible', false)
        setProperty(character..'Censor.visible', true)
        playAnim(character..'Censor', noteDirection[noteData + 1], true)

        if isDad == true then
            curSingDadAnim = noteDirection[noteData + 1]
            showCensorDadSprite = true
        else
            curSingBFAnim = noteDirection[noteData + 1]
            showCensorBFSprite = true
        end
    end
end

function getBFAnim()
    return (getProperty('boyfriend.animation.curAnim.name') or getProperty('boyfriend.atlas.anim.lastPlayedAnim'))
end

function getDadAnim()
    return (getProperty('dad.animation.curAnim.name') or getProperty('dad.atlas.anim.lastPlayedAnim'))
end