package;

// A class so I don't have to go back into MainMenuState every time I update Lumen - bobbyDX

class Version {
    // Year, Month, Day
    public static final dateParts:Array<Int> = [2025, 7, 5];
    // HAPPY 249TH AMERICA DAY

    // Build number for the day (e.g., 1 = first build of the day)
    // Only changes if there are source changes [not fixes]
    public static final buildNum:Int = 1;

    // Returns version string like "2025-06-28"
    public static function getFormatted():String {
        var year = Std.string(dateParts[0]);
        var month = StringTools.lpad(Std.string(dateParts[1]), "0", 2);
        var day = StringTools.lpad(Std.string(dateParts[2]), "0", 2);
        return '$year-$month-$day';
    }

    // Final version string like "2025-06-28 Build 1"
    public static final lumenVersion:String = getFormatted() + ' Build ' + buildNum;
}