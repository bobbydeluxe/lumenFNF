function onCreate()
    local curChar = getFreeplayCharacter()
    
    if curChar ~= nil and stringStartsWith(curChar, "pico") then
        setPropertyFromClass("substates.StickerSubState", "STICKER_SET", "stickers-set-pico")
    end
end
