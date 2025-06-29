local neneComboAnim = nil
local animOptions = {Disabled = 'none', Psych = 'psych', Vanilla = 'vanilla'}
function onCreate()
    --[[
        This is how the script recognizes which option you chose to use.
        However, if you decide to take Nene inside another mod,
        the 'neneComboAnim' variable will default to 'none' to avoid any bugs or issues.
        If that's the case, you can manually choose which option to pick by putting a string from 'animOptions'.
    ]]
    for optionName, optionStr in pairs(animOptions) do
        if getModSetting('comboAnims') == optionName then
            neneComboAnim = optionStr
        elseif getModSetting('comboAnims') == nil then
            neneComboAnim = 'none'
        end
    end
end

--[[
    If you ever want to use Abot Speaker on another character,
    just copy and paste this below, and change what's between '{}'.
    
    WARNING: The speaker can only get attached to BF, Dad, or GF type characters.
    Else, the offsets act as simple x and y positions.
    Go check the Abot Speaker's script for more information at line 217.
]]
function onCreatePost()
    addLuaScript('characters/props/speaker')
    callScript('characters/props/speaker', 'createSpeaker', {'gf', -225, 304}) -- {characterName, offsetX, offsetY}
end

local comboAnimActive = true
function goodNoteHit(membersIndex, noteData, noteType, isSustainNote)
    if neneComboAnim ~= 'none' and comboAnimActive == true then
        if neneComboAnim == 'vanilla' then
            if combo == 50 then
                playAnim('gf', 'cheer')
                setProperty('gf.specialAnim', true)
            end
        end
        lastCombo = combo
    end
end

function noteMiss(membersIndex, noteData, noteType, isSustainNote)
    if neneComboAnim ~= 'none' and comboAnimActive == true then
        if neneComboAnim == 'vanilla' then
            if lastCombo >= 70 then
                playAnim('gf', 'sad')
                setProperty('gf.specialAnim', true)
            end
        end
        if neneComboAnim == 'psych' then
            if lastCombo > 5 then
                playAnim('gf', 'sad')
                setProperty('gf.specialAnim', true)
            end
        end
        lastCombo = 0
    end
end

function noteMissPress(direction)
    if neneComboAnim ~= 'none' and comboAnimActive == true then
        if neneComboAnim == 'vanilla' then
            if lastCombo >= 70 then
                playAnim('gf', 'sad')
                setProperty('gf.specialAnim', true)
            end
        end
        if neneComboAnim == 'psych' then
            if lastCombo > 5 then
                playAnim('gf', 'sad')
                setProperty('gf.specialAnim', true)
            end
        end
        lastCombo = 0
    end
end