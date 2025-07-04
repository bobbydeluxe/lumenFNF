@echo off
color 0a
cd ..
@echo on
echo Installing dependencies...
echo This might take a few moments depending on your internet speed.
haxelib install lime 8.2.2
haxelib install openfl 9.4.1
haxelib install flixel 6.0.0
haxelib install flixel-addons 3.3.2
haxelib install flixel-tools 1.5.1
haxelib install hscript-iris 1.1.3
haxelib install tjson 1.4.0
haxelib install hxdiscord_rpc 1.3.0
haxelib git sophie-utils https://github.com/bobbydeluxe/sophie-utils.git --skip-dependencies
haxelib install hxvlc 2.2.2 --skip-dependencies
haxelib set lime 8.2.2
haxelib set openfl 9.4.1
haxelib git flxanimate https://github.com/Psych-Slice/FlxAnimate.git 42f1b5d193b4345ca7d6933380ab3105985b44a3
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit 1906c4a96f6bb6df66562b3f24c62f4c5bba14a7
haxelib git funkin.vis https://github.com/FunkinCrew/funkVis 22b1ce089dd924f15cdc4632397ef3504d464e90
haxelib git grig.audio https://gitlab.com/haxe-grig/grig.audio.git cbf91e2180fd2e374924fe74844086aab7891666
haxelib git FlxPartialSound https://github.com/FunkinCrew/FlxPartialSound.git f986332ba5ab02abd386ce662578baf04904604a
echo Finished!
pause