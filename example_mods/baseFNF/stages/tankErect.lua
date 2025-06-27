function onCreate()
	makeLuaSprite('bar', 'tankmanBattlefield/erect/bg', -985, -805)
	scaleObject('bar', 1.15, 1.15)
	addLuaSprite('bar')

	makeAnimatedLuaSprite('sniper', 'tankmanBattlefield/erect/sniper', -127, 349)
	addAnimationByPrefix('sniper', 'idle', 'Tankmanidlebaked instance 1', 24, false)
	addAnimationByPrefix('sniper', 'sip', 'tanksippingBaked instance 1', 24, false)
	scaleObject('sniper', 1.15, 1.15)
	addLuaSprite('sniper')
	playAnim('sniper', 'idle')

	makeAnimatedLuaSprite('tankguy', 'tankmanBattlefield/erect/guy', 1398, 407)
	addAnimationByPrefix('tankguy', 'idle', 'BLTank2 instance 1', 24, false)
	scaleObject('tankguy', 1.15, 1.15)
	addLuaSprite('tankguy')
end

function onCreatePost()
	runHaxeCode([[
		var maskRemaps:Map<String, String> = [
			"senpai-angry" => "senpai"
			// this one's still here, its just a simple remap testin' even though senpai ain't in week 7
		];

		function getRemappedName(original:String):String
		{
			return maskRemaps.exists(original) ? maskRemaps.get(original) : original;
		}
		
		function applyShader(sprite)
		{
			var rim = new shaders.AdjustColorScreenspace();

			rim.setAdjustColor(-25, -20, -46, -38);
			rim.distance = 15;
			rim.threshold = 0.3;

			rim.color = 0xFFDFEF3C;
			rim.antialiasAmt = 2;
			rim.attachedSprite = sprite;

			var remapped = getRemappedName(sprite.curCharacter);

			if (Paths.fileExists("images/tankmanBattlefield/erect/masks/" + remapped + ".png"))
			{
				rim.altMaskImage = Paths.image("tankmanBattlefield/erect/masks/" + remapped).bitmap;
				rim.maskThreshold = 1;
				rim.useAltMask = true;
			}

			sprite.animation.callback = function(anim, frame, index)
			{
				rim.updateFrameInfo(sprite.frame);
			};
			
			return rim;
		}

		for (sprite in [game.dad, game.boyfriend, game.gf]) {
			sprite.shader = applyShader(sprite);
		}
	]])
end

sniperSpecialAnim = false
function onBeatHit()
	if getRandomBool(2) and sniperSpecialAnim == false then
		playAnim('sniper', 'sip', true)
		runTimer('sipAnimLength', getProperty('sniper.animation.curAnim.numFrames') / 24)
		sniperSpecialAnim = true
	end

	if curBeat % 2 == 0 then
		if sniperSpecialAnim == false then
			playAnim('sniper', 'idle', true)
		end
		playAnim('tankguy', 'idle', true)
	end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'sipAnimLength' then
		sniperSpecialAnim = false
	end
end