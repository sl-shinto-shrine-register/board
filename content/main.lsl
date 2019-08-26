// Config
string version = "2.3.0";
string server = "http://slsr.bplaced.net";
integer id = 1;
integer width = 1080;
integer height = 1920;
integer face = 3;
key uuid = "3729f60f-73a4-4b6d-ae59-06136d1eade1";

string generate_url(string section)
{
    string url;
    if (section == "") {
        url = server + "?client=" + (string)id + "&version=" + version;
    } else {
        url = server + "/" + section + "?client=" + (string)id + "&version=" + version;
    }
    //llInstantMessage(uuid, url);
    return url;
}

setup()
{
    string url = generate_url("");
    llSetPrimMediaParams(face, [
        PRIM_MEDIA_CONTROLS, PRIM_MEDIA_CONTROLS_MINI,
        PRIM_MEDIA_HOME_URL, url,
        PRIM_MEDIA_CURRENT_URL, url,
        PRIM_MEDIA_AUTO_SCALE, FALSE,
        PRIM_MEDIA_WIDTH_PIXELS, width,
        PRIM_MEDIA_HEIGHT_PIXELS, height,
        PRIM_MEDIA_AUTO_PLAY, TRUE
    ]);
}

load(string section)
{
    llSetPrimMediaParams(face, [
        PRIM_MEDIA_CURRENT_URL, generate_url(section)
    ]);
}

default
{
    state_entry()
    {
        setup();
    }

    touch_start(integer total_number)
    {
        string prim = llGetLinkName(llDetectedLinkNumber(0));
        //llInstantMessage(uuid, prim);
        string section = llList2String(llParseString2List(prim, ["_"], []), 1);
        //llInstantMessage(uuid, section);
        if (section != "") {
            load(section);
        }
    }
}
