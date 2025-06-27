--BLAZIN NOTEHANDLER--

function goodNoteHit(membersIndex, noteData, noteType, isSustainNote)
    if noteType == 'blazin-blocklow' then
        playAnim('boyfriend', 'block', true)
        playAnim('dad', 'punchLow'..alternateDadpunch(), true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
        cameraShake('game', 0.002, 0.1)
    end
    if noteType == 'blazin-blockhigh' then
        playAnim('boyfriend', 'block', true)
        playAnim('dad', 'punchHigh'..alternateDadpunch(), true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
        cameraShake('game', 0.002, 0.1)
    end
    if noteType == 'blazin-blockspin' then
        playAnim('boyfriend', 'block', true)
        playAnim('dad', 'punchHigh'..alternateDadpunch(), true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
        cameraShake('game', 0.002, 0.1)
    end
    if noteType == 'blazin-dodgehigh' then
        playAnim('boyfriend', 'dodge', true)
        playAnim('dad', 'punchHigh'..alternateDadpunch(), true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
    end
    if noteType == 'blazin-dodgelow' then
        playAnim('boyfriend', 'dodge', true)
        playAnim('dad', 'punchLow'..alternateDadpunch(), true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
    end
    if noteType == 'blazin-dodgespin' then
        playAnim('boyfriend', 'dodge', true)
        playAnim('dad', 'punchHigh'..alternateDadpunch(), true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
    end
    if noteType == 'blazin-fakeout' then
        playAnim('boyfriend', 'fakeout', true)
        playAnim('dad', 'cringe', true)
        setOnLuas('picoFakeOutHit', true)
    end
    if noteType == 'blazin-hithigh' then
        playAnim('boyfriend', 'hitHigh', true)
        playAnim('dad', 'punchHigh'..alternateDadpunch(), true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
        cameraShake('game', 0.0025, 0.15)
    end
    if noteType == 'blazin-hitlow' then
        playAnim('boyfriend', 'hitLow', true)
        playAnim('dad', 'punchLow'..alternateDadpunch(), true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
        cameraShake('game', 0.0025, 0.15)
    end
    if noteType == 'blazin-hitspin' then
        playAnim('boyfriend', 'hitSpin', true)
        playAnim('dad', 'punchHigh'..alternateDadpunch(), true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
        cameraShake('game', 0.0025, 0.15)
    end
    if noteType == 'blazin-picouppercutprep' then
        playAnim('boyfriend', 'uppercutPrep', true)
        playAnim('dad', 'idle', true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 2)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 1)
        setOnLuas('picoUppercutReady', true)
    end
    if noteType == 'blazin-picouppercut' then
        if picoUppercutReady == true then
            playAnim('boyfriend', 'uppercut', true)
            playAnim('dad', 'uppercutHit', true)
            setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 2)
            setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 1)
            cameraShake('game', 0.005, 0.25)
        else
            playAnim('boyfriend', 'block', true)
            playAnim('dad', 'punchHigh'..alternateDadpunch(), true)
            setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
            setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
            cameraShake('game', 0.002, 0.1)
        end
        setOnLuas('picoUppercutReady', false)
    end
    if noteType == 'blazin-punchhighblocked' then    
        playAnim('boyfriend', 'punchHigh'..alternateBFpunch(), true)
        playAnim('dad', 'block', true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 2)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 1)
        cameraShake('game', 0.002, 0.1)
    end
    if noteType == 'blazin-punchhighdodged' then    
        playAnim('boyfriend', 'punchHigh'..alternateBFpunch(), true)
        playAnim('dad', 'dodge', true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 2)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 1)
    end
    if noteType == 'blazin-punchhighspin' then    
        playAnim('boyfriend', 'punchHigh'..alternateBFpunch(), true)
        playAnim('dad', 'hitSpin', true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 2)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 1)
        cameraShake('game', 0.0025, 0.15)
    end
    if noteType == 'blazin-punchhigh' then    
        playAnim('boyfriend', 'punchHigh'..alternateBFpunch(), true)
        playAnim('dad', 'hitHigh', true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 2)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 1)
        cameraShake('game', 0.0025, 0.15)
    end
    if noteType == 'blazin-punchlowblocked' then    
        playAnim('boyfriend', 'punchLow'..alternateBFpunch(), true)
        playAnim('dad', 'block', true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 2)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 1)
        cameraShake('game', 0.002, 0.1)
    end
    if noteType == 'blazin-punchlowdodged' then    
        playAnim('boyfriend', 'punchLow'..alternateBFpunch(), true)
        playAnim('dad', 'dodge', true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 2)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 1)
    end
    if noteType == 'blazin-punchlowspin' then    
        playAnim('boyfriend', 'punchLow'..alternateBFpunch(), true)
        playAnim('dad', 'hitSpin', true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 2)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 1)
        cameraShake('game', 0.0025, 0.15)
    end
    if noteType == 'blazin-punchlow' then
        playAnim('boyfriend', 'punchLow'..alternateBFpunch(), true)
        playAnim('dad', 'hitLow', true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 2)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 1)
        cameraShake('game', 0.0025, 0.15)
    end
    if noteType == 'blazin-taunt' then
        if picoFakeOutHit == true then
            playAnim('boyfriend', 'taunt', true)
            playAnim('dad', 'pissed', true)
        else
            playAnim('boyfriend', 'punchHigh'..alternateBFpunch(), true)
            playAnim('dad', 'hitHigh', true)
            setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 2)
            setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 1)
            cameraShake('game', 0.0025, 0.15)
        end
        setOnLuas('picoFakeOutHit', false)
    end
end

function noteMiss(membersIndex, noteData, noteType, isSustainNote)
    if noteType == 'blazin-blocklow' then
        playAnim('boyfriend', 'hitLow', true)
        playAnim('dad', 'punchLow'..alternateDadpunch(), true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
        cameraShake('game', 0.0025, 0.15)
    end
    if noteType == 'blazin-blockhigh' then
        playAnim('boyfriend', 'hitHigh', true)
        playAnim('dad', 'punchHigh'..alternateDadpunch(), true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
        cameraShake('game', 0.0025, 0.15)
    end
    if noteType == 'blazin-blockspin' then
        playAnim('boyfriend', 'hitSpin', true)
        playAnim('dad', 'punchHigh'..alternateDadpunch(), true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
        cameraShake('game', 0.0025, 0.15)
    end
    if noteType == 'blazin-dodgehigh' then
        playAnim('boyfriend', 'hitHigh', true)
        playAnim('dad', 'punchHigh'..alternateDadpunch(), true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
        cameraShake('game', 0.0025, 0.15)
    end
    if noteType == 'blazin-dodgelow' then
        playAnim('boyfriend', 'hitLow', true)
        playAnim('dad', 'punchLow'..alternateDadpunch(), true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
        cameraShake('game', 0.0025, 0.15)
    end
    if noteType == 'blazin-dodgespin' then
        playAnim('boyfriend', 'hitSpin', true)
        playAnim('dad', 'punchHigh'..alternateDadpunch(), true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
        cameraShake('game', 0.0025, 0.15)
    end
    if noteType == 'blazin-fakeout' then
        playAnim('boyfriend', 'punchHigh'..alternateBFpunch(), true)
        playAnim('dad', 'hitHigh', true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 2)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 1)
        cameraShake('game', 0.0025, 0.15)
        setOnLuas('picoFakeOutHit', false)
    end
    if noteType == 'blazin-hithigh' then
        playAnim('boyfriend', 'hitHigh', true)
        playAnim('dad', 'punchHigh'..alternateDadpunch(), true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
        cameraShake('game', 0.0025, 0.15)
    end
    if noteType == 'blazin-hitlow' then
        playAnim('boyfriend', 'hitLow', true)
        playAnim('dad', 'punchLow'..alternateDadpunch(), true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
        cameraShake('game', 0.0025, 0.15)
    end
    if noteType == 'blazin-hitspin' then
        playAnim('boyfriend', 'hitSpin', true)
        playAnim('dad', 'punchHigh'..alternateDadpunch(), true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
        cameraShake('game', 0.0025, 0.15)
    end
    if noteType == 'blazin-picouppercutprep' then
        playAnim('boyfriend', 'punchHigh'..alternateBFpunch(), true)
        playAnim('dad', 'hitHigh', true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 2)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 1)
        cameraShake('game', 0.0025, 0.15)
        setOnLuas('picoUppercutReady', false)
    end
    if noteType == 'blazin-picouppercut' then
        if picoUppercutReady == true then
            playAnim('boyfriend', 'uppercut', true)
            playAnim('dad', 'dodge', true)
            setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 2)
            setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 1)
        else
            playAnim('boyfriend', 'hitHigh', true)
            playAnim('dad', 'punchHigh'..alternateDadpunch(), true)
            setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
            setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
            cameraShake('game', 0.0025, 0.15)
        end
        setOnLuas('picoUppercutReady', false)
    end
    if noteType == 'blazin-punchhighblocked' then
        playAnim('boyfriend', 'hitHigh', true)
        playAnim('dad', 'punchHigh'..alternateDadpunch(), true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
        cameraShake('game', 0.0025, 0.15)
    end
    if noteType == 'blazin-punchhighdodged' then
        playAnim('boyfriend', 'hitHigh', true)
        playAnim('dad', 'punchHigh'..alternateDadpunch(), true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
        cameraShake('game', 0.0025, 0.15)
    end
    if noteType == 'blazin-punchhighspin' then
        playAnim('boyfriend', 'hitSpin', true)
        playAnim('dad', 'punchHigh'..alternateDadpunch(), true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
        cameraShake('game', 0.0025, 0.15)
    end
    if noteType == 'blazin-punchhigh' then
        playAnim('boyfriend', 'hitHigh', true)
        playAnim('dad', 'punchHigh'..alternateDadpunch(), true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
        cameraShake('game', 0.0025, 0.15)
    end
    if noteType == 'blazin-punchlowblocked' then
        playAnim('boyfriend', 'hitLow', true)
        playAnim('dad', 'punchLow'..alternateDadpunch(), true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
        cameraShake('game', 0.0025, 0.15)
    end
    if noteType == 'blazin-punchlowdodged' then
        playAnim('boyfriend', 'hitLow', true)
        playAnim('dad', 'punchLow'..alternateDadpunch(), true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
        cameraShake('game', 0.0025, 0.15)
    end
    if noteType == 'blazin-punchlowspin' then
        playAnim('boyfriend', 'hitSpin', true)
        playAnim('dad', 'punchLow'..alternateDadpunch(), true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
        cameraShake('game', 0.0025, 0.15)
    end
    if noteType == 'blazin-punchlow' then
        playAnim('boyfriend', 'hitLow', true)
        playAnim('dad', 'punchLow'..alternateDadpunch(), true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
        cameraShake('game', 0.0025, 0.15)
    end
    if noteType == 'blazin-taunt' then
        if picoFakeOutHit == true then
            playAnim('boyfriend', 'taunt', true)
            playAnim('dad', 'pissed', true)
        else
            playAnim('boyfriend', 'hitHigh', true)
            playAnim('dad', 'punchHigh'..alternateDadpunch(), true)
            setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
            setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
            cameraShake('game', 0.0025, 0.15)
        end
        setOnLuas('picoFakeOutHit', false)
    end
end

function opponentNoteHit(membersIndex, noteData, noteType, isSustainNote)
    if noteType == 'blazin-darnelluppercutprep' then
        playAnim('boyfriend', 'idle', true)
        playAnim('dad', 'uppercutPrep', true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
    end
    if noteType == 'blazin-darnelluppercut' then
        playAnim('boyfriend', 'uppercutHit', true)
        playAnim('dad', 'uppercut', true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
        cameraShake('game', 0.005, 0.25)
    end
    if noteType == 'blazin-hithigh' then
        playAnim('boyfriend', 'hitHigh', true)
        playAnim('dad', 'punchHigh'..alternateDadpunch(), true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
        cameraShake('game', 0.0025, 0.15)
    end
    if noteType == 'blazin-hitlow' then
        playAnim('boyfriend', 'hitLow', true)
        playAnim('dad', 'punchLow'..alternateDadpunch(), true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
        cameraShake('game', 0.0025, 0.15)
    end
    if noteType == 'blazin-hitspin' then
        playAnim('boyfriend', 'hitSpin', true)
        playAnim('dad', 'punchHigh'..alternateDadpunch(), true)
        setObjectOrder('boyfriendGroup', getObjectOrder('gfGroup') + 1)
        setObjectOrder('dadGroup', getObjectOrder('gfGroup') + 2)
        cameraShake('game', 0.0025, 0.15)
    end
    if noteType == 'blazin-idle' then
        playAnim('boyfriend', 'idle', true)
        playAnim('dad', 'idle', true)
    end
end


-- This is to alternate the fists one fighter uses when punching the other.
function alternateDadpunch()
    setOnLuas('isOneDad', not isOneDad)
    if isOneDad == true then
        return '1'
    else
        return '2'
    end
end
function alternateBFpunch()
    setOnLuas('isOneBF', not isOneBF)
    if isOneBF == true then
        return '1'
    else
        return '2'
    end
end
