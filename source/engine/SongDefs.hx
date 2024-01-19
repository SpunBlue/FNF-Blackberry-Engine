package engine;


typedef SongListJson = {
    var songs:Array<FreeplaySong>;
    var weeks:Array<WeekData>;
}

/**
 * Used for Mods as well!!
 */
typedef FreeplaySong = {
    var name:String;
    var icon:String;
}

/**
 * Used for Mods as well!!
 */
typedef WeekData = {
    var name:String;
    var songs:Array<String>;
}