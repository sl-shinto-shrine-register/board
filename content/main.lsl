// Configuration.
string VERSION = "2.7.0";
string SERVER = "slsr.org";
integer USE_SSL = TRUE;
string DEFAULT_SECTION = "random";
integer DEBUG_MODE_ENABLED = FALSE;
integer ID = 1;
integer SCREEN_WIDTH = 1080;
integer SCREEN_HEIGHT = 1920;
integer SCREEN_FACE = 3;
string VERSION_URL = "https://api.github.com/repos/sl-shinto-shrine-register/board/tags";
string BUY_LINK = "https://marketplace.secondlife.com/p/Shrine-register-board/17914344";
string VERSION_OUTDATED_TEXT = "New version available. Please replace as soon as possible!";
string INFO_TEXT = "Please join our group secondlife:///app/group/1e87fa6c-7a9f-5a54-602c-149606623147/about or visit our homepage http://www.slsr.org";

// Internal states.
key httpVersionRequestID;
string lastVersionCheck;

/**
 * Generates URL.
 * @param section Section name.
 * @return URL.
 */
string generateURL(string section) {
    string protocol = "http";
    if (USE_SSL) protocol = "https";
    string url = protocol + "://" + SERVER + "/" + section + "?client=" + (string) ID + "&version=" + VERSION + "&location=" + getLocation();
    if (DEBUG_MODE_ENABLED) llInstantMessage(llGetOwner(), url);
    return url;
}

/**
 * Loads section.
 * @param section Section name.
 */
load(string section) {
    requestVersionCheck();
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
 * Returns location.
 * @return Location.
 * @version 1.0.1
 */
string getLocation() {
    vector position = llGetPos();
    return llEscapeURL(llGetRegionName()) + "/" + (string) llRound(position.x) + "/" + (string) llRound(position.y) + "/" + (string) llRound(position.z);
}

/**
 * Returns clicked section.
 * @return Name of clicked section.
 */
string getClickedSection() {
    string prim = llGetLinkName(llDetectedLinkNumber(0));
    if (DEBUG_MODE_ENABLED) llInstantMessage(llGetOwner(), "Clicked prim: " + prim);
    return llList2String(llParseString2List(prim, ["_"], []), 1);
}

/**
 * Requests a version check.
 */
requestVersionCheck() {
    httpVersionRequestID = llHTTPRequest(
        VERSION_URL,
        [
            HTTP_METHOD, "GET",
            HTTP_MIMETYPE, "application/json"
        ],
        ""
    );
}

/**
 * Checks if the current version is outdated by given JSON data and sends a notification to the owner, if so.
 * @param json JSON data.
 */
checkVersion(string json) {
    string currentDate = llGetDate();
    if (lastVersionCheck != currentDate) {
        string latestVersion = llDeleteSubString(llJsonGetValue(json, [0, "name"]), 0, 0);
        if (DEBUG_MODE_ENABLED) llInstantMessage(llGetOwner(), "Latest version: " + latestVersion);
        if (latestVersion != VERSION) llInstantMessage(llGetOwner(), VERSION_OUTDATED_TEXT + "\n" + BUY_LINK);
        lastVersionCheck = currentDate;
    }
}

/**
 * Sends a info text to the agents.
 * @param numberOfAgents Number of agents detected touching during the last clock cycle.
 */
sendInfoText(integer numberOfAgents) {
    integer number;
    do {
        llInstantMessage(llDetectedKey(number), INFO_TEXT);
    } while (numberOfAgents > ++number);
}

/**
 * States.
 */
default {
    /**
     * Entry state.
     */
    state_entry() {
        load(DEFAULT_SECTION);
    }

    /**
     * Touch event.
     * @param total_number Number of agents detected touching during the last clock cycle.
     */
    touch_start(integer total_number) {
        string section = getClickedSection();
        if (section == "") {
            sendInfoText(total_number);
        } else {
            load(section);
        }
    }

    /**
     * HTTP response event.
     * @param request_id Matches return from llHTTPRequest.
     * @param status HTTP status code (like 404 or 200).
     * @param metadata List of HTTP_* constants and attributes.
     * @param body Response body content.
     */
    http_response(key request_id, integer status, list metadata, string body) {
        if ((request_id == httpVersionRequestID) && (status == 200)) checkVersion(body);
    }
}
