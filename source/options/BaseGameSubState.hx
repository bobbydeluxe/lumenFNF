package options;
import options.Option;

class BaseGameSubState extends BaseOptionsMenu {
    public function new() {
        title = Language.getPhrase("vslice_menu","V-Slice settings");
        rpcTitle = "V-Slice settings menu";
		var option:Option = new Option('Smooth health bar',
			'If enabled makes health bar move more smoothly',
			'vsliceSmoothBar',
			BOOL,);
		addOption(option);
		var option:Option = new Option('Force "New" tag',
			'If enabled will force every uncompleted song to show "new" tag even if it\'s disabled',
			'vsliceForceNewTag',
			BOOL);
		addOption(option);
        super();
    }
}