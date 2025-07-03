package options;

class GameplaySettingsSubState extends BaseOptionsMenu
{
	public function new() {
		super(Language.getPhrase('gameplay_menu', 'Gameplay Settings'), 'Gameplay Settings Menu');
		
		//I'd suggest using "Downscroll" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Downscroll', //Name
			'Changes the notes to be located at the bottom instead of the top of the screen.', //Description
			'downScroll', //Save data variable name
			BOOL); //Variable type
		addOption(option);

		var option:Option = new Option('Middlescroll',
			'Changes the player notes to be located in the middle of the screen.',
			'middleScroll',
			BOOL);
		addOption(option);

		var option:Option = new Option('Opponent Notes',
			'Should the opponent\'s notes be shown?',
			'opponentStrums',
			BOOL);
		addOption(option);

		var option:Option = new Option('Ghost Tapping',
			"If checked, you won't get misses from pressing keys while there are no notes able to be hit.",
			'ghostTapping',
			BOOL);
		addOption(option);
		
		var option:Option = new Option('Auto Pause',
			"If checked, the game will automatically pause when focus is lost.",
			'autoPause',
			BOOL);
		addOption(option);
		option.onChange = onChangeAutoPause;

		var option:Option = new Option('Disable Reset Button',
			"If checked, pressing Reset won't kill the player.",
			'noReset',
			BOOL);
		addOption(option);

		var option:Option = new Option('Sustains as One Note',
			"If checked, Hold Notes can't be pressed if you miss,\nand count as a single Hit/Miss.\nUncheck this if you prefer the old Input System.",
			'guitarHeroSustains',
			BOOL);
		addOption(option);

		var option:Option = new Option('Hitsound Volume',
			'Changes the volume of a tick sound that will play when hitting notes.',
			'hitsoundVolume',
			PERCENT);
		addOption(option);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		option.onChange = onChangeHitsoundVolume;

		var option:Option = new Option('Rating Offset',
			'Changes how late/early you have to hit for a "Epic!!"\nHigher values mean you have to hit later.',
			'ratingOffset',
			INT);
		option.displayFormat = '%vms';
		option.scrollSpeed = 20;
		option.minValue = -30;
		option.maxValue = 30;
		addOption(option);

		var option:Option = new Option('Epic!! Hit Window',
			'Changes the amount of time you have\nfor hitting a "Epic!!" in milliseconds.',
			'epicWindow',
			FLOAT);
		option.displayFormat = '%vms';
		option.scrollSpeed = 15;
		option.minValue = 15.0;
		option.maxValue = 23.0;
		option.changeValue = 0.1;
		addOption(option);

		var option:Option = new Option('Sick! Hit Window',
			'Changes the amount of time you have\nfor hitting a "Sick!" in milliseconds.',
			'sickWindow',
			FLOAT);
		option.displayFormat = '%vms';
		option.scrollSpeed = 15;
		option.minValue = 15.0;
		option.maxValue = 45.0;
		option.changeValue = 0.1;
		addOption(option);

		var option:Option = new Option('Good Hit Window',
			'Changes the amount of time you have\nfor hitting a "Good" in milliseconds.',
			'goodWindow',
			FLOAT);
		option.displayFormat = '%vms';
		option.scrollSpeed = 30;
		option.minValue = 15.0;
		option.maxValue = 90.0;
		option.changeValue = 0.1;
		addOption(option);

		var option:Option = new Option('Bad Hit Window',
			'Changes the amount of time you have\nfor hitting a "Bad" in milliseconds.',
			'badWindow',
			FLOAT);
		option.displayFormat = '%vms';
		option.scrollSpeed = 60;
		option.minValue = 15.0;
		option.maxValue = 135.0;
		option.changeValue = 0.1;
		addOption(option);

		var option:Option = new Option('Safe Frames',
			'Changes how many frames you have for\nhitting a note earlier or late.',
			'safeFrames',
			FLOAT);
		option.scrollSpeed = 5;
		option.minValue = 2;
		option.maxValue = 10;
		option.changeValue = 0.1;
		addOption(option);
	}

	function onChangeHitsoundVolume()
		FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.data.hitsoundVolume);

	function onChangeAutoPause()
		FlxG.autoPause = ClientPrefs.data.autoPause;
}
