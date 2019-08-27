// Configuration
string VERSION = "2.4.0";
string SERVER = "slsr.org";
integer USE_SSL = TRUE;
string DEFAULT_SECTION = "random";
integer DEBUG_MODE_ENABLED = FALSE;
integer ID = 1;
integer SCREEN_WIDTH = 1080;
integer SCREEN_HEIGHT = 1920;
integer SCREEN_FACE = 3;

/**
 * Generates URL.
 * @param section Section name.
 * @return URL.
 */
string generateURL(string section) {
    string protocol = "http";
    if (USE_SSL) protocol = "https";
    if (section == "") section = DEFAULT_SECTION;
    string url = protocol + "://" + SERVER + "/" + section + "?client=" + (string) ID + "&version=" + VERSION;
    if (DEBUG_MODE_ENABLED) llInstantMessage(llGetOwner(), url);
    return url;
}

/**
 * Loads section.
 * @param section Section name.
 */
load(string section) {
    string url = generateURL(section);
    llSetPrimMediaParams(
        SCREEN_FACE,
        [
            PRIM_MEDIA_CONTROLS, PRIM_MEDIA_CONTROLS_MINI,
            PRIM_MEDIA_HOME_URL, url,
            PRIM_MEDIA_CURRENT_URL, url,
            PRIM_MEDIA_AUTO_SCALE, FALSE,
            PRIM_MEDIA_WIDTH_PIXELS, SCREEN_WIDTH,
            PRIM_MEDIA_HEIGHT_PIXELS, SCREEN_HEIGHT,
            PRIM_MEDIA_AUTO_PLAY, TRUE
        ]
    );
}

/**
 * Returns clicked section.
 * @return Name of clicked section.
 */
string getClickedSection() {
    string prim = llGetLinkName(llDetectedLinkNumber(0));
    return llList2String(llParseString2List(prim, ["_"], []), 1);
}

/**
 * States.
 */
default {
    /**
     * Entry state.
     */
    state_entry() {
        load("");
    }

    /**
     * Touch event.
     * @param total_number Number of agents detected touching during the last clock cycle.
     */
    touch_start(integer total_number) {
        load(getClickedSection());
    }
}
