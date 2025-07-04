-- This script's purpose is to make the introduction and call the dialogueBox script.
function onCreate()
    if seenCutscene == false then
        makeLuaSprite('blackScreen')
        makeGraphic('blackScreen', 2000, 2500, '000000')
        screenCenter('blackScreen')
        setObjectCamera('blackScreen', 'camOther')
        addLuaSprite('blackScreen', true)

        if not isRunning('custom_events/Set Camera Target') then
            addLuaScript('custom_events/Set Camera Target')
        end
    end
end

function onStartCountdown()
    if isStoryMode and seenCutscene == false and getVar('dialogueFinished') == false then
        triggerEvent('Set Camera Target', 'dad', '0')
        runTimer('dialogueBGFadeIn', 0.83, 5)
        runTimer('screenFadeOut', 0.3)
        return Function_Stop
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'screenFadeOut' then
        setProperty('blackScreen.alpha', getProperty('blackScreen.alpha') - 0.15)
        if getProperty('blackScreen.alpha') <= 0 then
            callScript('data/'..songPath..'/dialogueBox', 'createDialogueBox', {false})
        else
            runTimer('screenFadeOut', 0.3)
        end
    end
end