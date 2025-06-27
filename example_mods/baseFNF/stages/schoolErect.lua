function onCreate()
	makeLuaSprite('sky', 'weeb/erect/weebSky', -164, -78)
	setScrollFactor('sky', 0.2, 0.2)
	scaleObject('sky', 6, 6)
	addLuaSprite('sky')
	setProperty('sky.antialiasing', false)

	makeLuaSprite('treesBackground', 'weeb/erect/weebBackTrees', -242, -80)
	setScrollFactor('treesBackground', 0.5, 0.5)
	scaleObject('treesBackground', 6, 6)
	addLuaSprite('treesBackground')
	setProperty('treesBackground.antialiasing', false)

	makeLuaSprite('schoolBuilding', 'weeb/erect/weebSchool', -216, -38)
	setScrollFactor('schoolBuilding', 0.75, 0.75)
	scaleObject('schoolBuilding', 6, 6)
	addLuaSprite('schoolBuilding')
	setProperty('schoolBuilding.antialiasing', false)

	makeLuaSprite('schoolStreet', 'weeb/erect/weebStreet', -200, 6)
	scaleObject('schoolStreet', 6, 6)
	addLuaSprite('schoolStreet')
	setProperty('schoolStreet.antialiasing', false)

	makeLuaSprite('treesBack', 'weeb/erect/weebTreesBack', -200, 6)
	scaleObject('treesBack', 6, 6)
	addLuaSprite('treesBack')
	setProperty('treesBack.antialiasing', false)

	makeAnimatedLuaSprite('trees', 'weeb/erect/weebTrees', -806, -1050, 'packer')
	addAnimation('trees', 'anim', {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18}, 12)
	scaleObject('trees', 6, 6)
	addLuaSprite('trees')
	setProperty('trees.antialiasing', false)

	makeAnimatedLuaSprite('fallingPetals', 'weeb/erect/petals', -20, -40)
	addAnimationByPrefix('fallingPetals', 'anim', 'PETALS ALL')
	scaleObject('fallingPetals', 6, 6)
	addLuaSprite('fallingPetals')
	setProperty('fallingPetals.antialiasing', false)
end

function onCreatePost()
	runHaxeCode([[
		var maskRemaps:Map<String, String> = [
			"senpai-angry" => "senpai"
		];

		function getRemappedName(original:String):String
		{
			return maskRemaps.exists(original) ? maskRemaps.get(original) : original;
		}
		
		function applyShader(sprite)
		{
			var rim = new shaders.AdjustColorScreenspace();

			if (sprite == game.gf)
			{
				rim.setAdjustColor(-10, -25, -42, 5);
				rim.distance = 3;
				rim.threshold = 0.3;
			}
			else
			{
				rim.setAdjustColor(-10, -23, -66, 24);
				rim.distance = 5;
				rim.threshold = 0.1;
			}

			rim.color = 0xFF52351D;
			rim.antialiasAmt = 0;
			rim.attachedSprite = sprite;

			var remapped = getRemappedName(sprite.curCharacter);

			if (Paths.fileExists("images/weeb/erect/masks/" + remapped + ".png"))
			{
				rim.altMaskImage = Paths.image("weeb/erect/masks/" + remapped).bitmap;
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