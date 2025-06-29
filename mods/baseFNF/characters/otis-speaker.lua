function onCreatePost()
    makeAnimatedLuaSprite('muzzleFlash', 'particles/otis_flashes')
    addAnimationByPrefix('muzzleFlash', 'shoot1', 'shoot back0', 24, false)
    addAnimationByPrefix('muzzleFlash', 'shoot2', 'shoot back low0', 24, false)
    addAnimationByPrefix('muzzleFlash', 'shoot3', 'shoot forward0', 24, false)
    addAnimationByPrefix('muzzleFlash', 'shoot4', 'shoot forward low0', 24, false)
    setObjectOrder('muzzleFlash', getObjectOrder('gfGroup') + 1)
    addLuaSprite('muzzleFlash')

    --[[
        If you ever want to use Abot Speaker on another character,
        just copy and paste this below, and change what's between '{}'.
    
        WARNING: The speaker can only get attached to BF, Dad, or GF type characters.
        Else, the offsets act as simple x and y positions.
        Go check the Abot Speaker's script for more information at line 374.
    ]]
    addLuaScript('characters/props/abot-stereo')
    callScript('characters/props/abot-stereo', 'createSpeaker', {'otis-speaker', 5, 10}) -- {characterName, offsetX, offsetY}
end

function onUpdatePost(elapsed)
    local gfCurAnim = getProperty('gf.animation.curAnim.name')
    updateMuzzleFlash(gfCurAnim)
    
    if stringStartsWith(gfCurAnim, 'shoot') then
        if getProperty('muzzleFlash.animation.curAnim.name') ~= gfCurAnim then
            playAnim('muzzleFlash', gfCurAnim, true)
            setBlendMode('muzzleFlash', 'ADD')
        end
    end
end

function updateMuzzleFlash(curAnim)
    if getProperty('muzzleFlash.animation.curAnim.curFrame') > 1 then
        setProperty('muzzleFlash.blend', nil)
    end
    setProperty('muzzleFlash.visible', not getProperty('muzzleFlash.animation.finished'))

    if curAnim == 'shoot1' then
        setProperty('muzzleFlash.x', getProperty('gf.x') + 640)
        setProperty('muzzleFlash.y', getProperty('gf.y') - 20)
    elseif curAnim == 'shoot2' then
        setProperty('muzzleFlash.x', getProperty('gf.x') + 650)
        setProperty('muzzleFlash.y', getProperty('gf.y') - 50)
    elseif curAnim == 'shoot3' then
        setProperty('muzzleFlash.x', getProperty('gf.x') - 540)
        setProperty('muzzleFlash.y', getProperty('gf.y') - 50)
    elseif curAnim == 'shoot4' then
        setProperty('muzzleFlash.x', getProperty('gf.x') - 570)
        setProperty('muzzleFlash.y', getProperty('gf.y') - 90)
    end
end