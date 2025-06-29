function onCreate()
    scrollMultiplier = callMethodFromClass('backend.ClientPrefs', 'getGameplaySetting', {'scrollspeed'})
end

function onEvent(eventName, value1, value2, strumTime)
    if eventName == 'Set Scroll Speed' then
        if getProperty('songSpeedType') ~= 'constant' then
            cancelTween('changeScroll')
           
            -- Sets up the data for the scroll and removes any empty space in the string.
            local scrollData = stringSplit(value1, ',')
            for i = 1, #scrollData do
                scrollData[i] = stringTrim(scrollData[i])
            end

            -- Sets up the data for the tween and removes any empty space in the string.
            local tweenData = stringSplit(value2, ',')
            for i = 1, #tweenData do
                tweenData[i] = stringTrim(tweenData[i])
            end

            -- Default Values
            if scrollData[1] == '' then
                scrollData[1] = '1'
            end
            if tweenData[1] == '' then
                tweenData[1] = '0'
            end

            if scrollData[2] ~= 'absolute' then
                --[[
                    The 'targetScroll' is the value multiplied by the original song's 'scrollSpeed' of the song,
                    and the 'scrollMultiplier' from the Gameplay settings.
                ]]
                targetScroll = tonumber(scrollData[1]) * scrollSpeed * scrollMultiplier
            else
                -- The 'targetScroll' is just the value multiplied by the 'scrollMultiplier' from the Gameplay settings.
                targetScroll = tonumber(scrollData[1]) * scrollMultiplier
            end

            if tweenData[1] <= '0' then
                -- Scroll Speed is instantly set to the inputted value
                setProperty('songSpeed', targetScroll)
            else
                -- Scroll Speed gradually sets to the inputted value by using a tween.
                local duration = stepCrochet * tonumber(tweenData[1]) / 1000
                if tweenData[2] == nil then
                    tweenData[2] = 'linear'
                end
                if version >= '1.0' then
                    tweenNameAdd = 'tween_' -- Shadow Mario fucked it up.
                else
                    tweenNameAdd = ''
                end
                startTween(tweenNameAdd..'changeScroll', 'this', {songSpeed = targetScroll}, duration, {ease = tweenData[2]})
            end
        end
    end
end