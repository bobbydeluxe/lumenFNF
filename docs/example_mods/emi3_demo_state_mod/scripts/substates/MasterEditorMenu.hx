function onCreate():Void {
	options.push('Testing!!');
	optionFunctions['Testing!!'] = () -> openSubState(new CustomSubstate('TestingMenu'));
}