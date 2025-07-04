-- This script's purpose is only to call the dialogueBox script.
function onCreate()
    if seenCutscene == false then
        if not isRunning('custom_events/Set Camera Target') then
            addLuaScript('custom_events/Set Camera Target')
        end
    end
end

function onStartCountdown()
    if isStoryMode and seenCutscene == false and getVar('dialogueFinished') == false then
        triggerEvent('Set Camera Target', 'dad', '0')
        callScript('data/'..songPath..'/dialogueBox', 'createDialogueBox', {true})
        return Function_Stop
    end
end