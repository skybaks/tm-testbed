
namespace screenshot_automation
{
    void Main()
    {
        return;

        for (uint i = 41; i < 51; i++)
        {
            string num = Text::Format("%02d", i);

            OpenEditor("Quicksaves_EditorHelpers\\DesertBatchProject\\My Maps_desert_04_0000" + num + ".Map.Gbx");
            OpenMediaTrackerIntro();
            LoadClipMT("desertbatch_01.Clip.Gbx");
            ComputeShadowsMT();
            ShootVideo("desertbatch_" + num);
            CloseMediaTracker();
            CloseEditor();
        }
    }

    void OpenEditor(const string&in mapfile)
    {
        // Dont include "Maps\"
        cast<CTrackMania>(GetApp()).ManiaTitleControlScriptAPI.EditMap(mapfile, "", "");

        while (cast<CGameCtnEditorFree>(cast<CTrackMania>(GetApp()).Editor) is null)
        {
            sleep(1000);
        }

        print("In editor: " + mapfile);
    }

    void CloseEditor()
    {
        cast<CGameCtnEditorFree>(cast<CTrackMania>(GetApp()).Editor).QuitFromScript_OnOk();

        while (cast<CTrackMania>(GetApp()).Editor !is null)
        {
            yield();
        }

        print("Closed Editor");
    }

    void OpenMediaTrackerIntro()
    {
        // Brings up MT dialog
        cast<CGameCtnEditorFree>(cast<CTrackMania>(GetApp()).Editor).ButtonEditEndRaceReplay();

        yield();

        GetFirstChild(
            GetFirstChild(
                GetFirstChild(
                    GetFirstChild(
                        GetFirstChild(
                            GetApp().ActiveMenus[0].CurrentFrame,
                            "FrameContent"),
                            "FrameDialog"),
                            "FrameButtonsSequences"),
                            "ButtonIntroEdit"),
                            "ButtonSelection").OnAction();

        while (cast<CGameEditorMediaTracker>(cast<CTrackMania>(GetApp()).Editor) is null)
        {
            sleep(1000);
        }

        print("In MT Intro");
    }

    void LoadClipMT(const string&in clipfile)
    {
        cast<CGameEditorMediaTrackerPluginAPI>(cast<CGameEditorMediaTracker>(cast<CTrackMania>(GetApp()).Editor).PluginAPI).ImportClip();

        yield();

        auto entry = cast<CControlEntry>(GetFirstChild(GetFirstChild(GetFirstChild(GetApp().ActiveMenus[0].CurrentFrame, "FrameContent"), "FrameSave"), "EntryFileName"));
        cast<CGameDialogs>(entry.Nod).String = clipfile;
        cast<CGameDialogs>(entry.Nod).DialogSaveAs_OnValidate();

        print("Loaded clip: " + clipfile);
    }

    void ClearClipMT()
    {
        auto api = cast<CGameEditorMediaTrackerPluginAPI>(cast<CGameEditorMediaTracker>(cast<CTrackMania>(GetApp()).Editor).PluginAPI);
        while (api.Clip.Tracks.Length > 0)
        {
            api.RemoveTrack(0);
        }
        print("Cleared MT Tracks");
    }

    void ComputeShadowsMT()
    {
        auto api = cast<CGameEditorMediaTrackerPluginAPI>(cast<CGameEditorMediaTracker>(cast<CTrackMania>(GetApp()).Editor).PluginAPI);
        api.ComputeShadows();
        auto frame = GetFirstChild(GetFirstChild(GetApp().ActiveMenus[0].CurrentFrame, "FrameContent"), "FrameShadows");
        auto quality = cast<CControlLabel>(GetFirstChild(frame, "LabelQualityLevel"));
        auto next = GetFirstChild(frame, "ButtonNextQuality");
        while (quality.Label != "High")
        {
            next.OnAction();
        }

        if (GetFirstChild(frame, "FrameShadowsAlreadyComputed").IsVisible)
        {
            GetFirstChild(GetFirstChild(GetFirstChild(GetApp().ActiveMenus[0].CurrentFrame, "FrameContent"), "ButtonReturn"), "ButtonSelection").OnAction();
            print("Shadows already computed");
        }
        else
        {
            GetFirstChild(GetFirstChild(frame, "ButtonComputeShadows"), "ButtonSelection").OnAction();
            while (GetApp().ActiveMenus.Length == 0)
            {
                yield();
            }
            while (GetApp().ActiveMenus.Length > 0
                && GetApp().ActiveMenus[0].CurrentFrame.IdName == "FrameWaitMessage")
            {
                sleep(1000);
            }
            print("Shadows computed");
        }
    }

    void TakeScreenshot(const string&in filename)
    {
        auto api = cast<CGameEditorMediaTrackerPluginAPI>(cast<CGameEditorMediaTracker>(cast<CTrackMania>(GetApp()).Editor).PluginAPI);
        api.ShootScreen();

        // TODO: Find a way to get through final "press a key to accept"
    }

    void ShootVideo(const string&in filename)
    {
        SnapshotScreenshotsFolder();
        auto api = cast<CGameEditorMediaTrackerPluginAPI>(cast<CGameEditorMediaTracker>(cast<CTrackMania>(GetApp()).Editor).PluginAPI);
        api.ShootVideo();
        yield();

        auto entry = GetFirstChild(
            GetFirstChild(
                GetFirstChild(
                    GetFirstChild(
                        GetApp().ActiveMenus[0].CurrentFrame,
                        "FrameContent"),
                        "FrameParameters"),
                        "FrameVideoName"),
                        "EntryVideoName");
        auto parms = cast<CGameDialogShootParams>(entry.Nod);
        if (parms !is null)
        {
            // Don't know a way to consistently set filename. Things I've tried:
            //  * Simply setting parms.ShootName. Updates the dialog but resulting file is still VideoXX.webm
            //  * Setting parms.ShootName, then giving textbox focus, then removing focus. No better
            //  * Setting parms.ShootName, then closing and reopening dialog. No better
            // It's always set when you type directly into the textbox. Must
            // be some other state variable behind the dialog that is set by
            // maniascript event code? or c++?
            // In any case, the dialog ShootName can frik off. I'll just rename
            // the file with IO::Move().

            //parms.ShootName = filename;
            parms.SetQualityPreset_High();
            parms.OnOk();
            yield();
        }

        // Detect the end of shooting by repeatedly trying to advance the
        // timer. It wont advance until we are back in the MT editor screen
        auto startTime = api.CurrentTimer;
        while (startTime == api.CurrentTimer)
        {
            api.TimePlay();
            yield();
        }
        api.TimeStop();
        api.CurrentTimer = startTime;

        RenameNewVideo(filename);

        print("Done shooting: " + filename);
    }

    void CloseMediaTracker()
    {
        auto api = cast<CGameEditorMediaTrackerPluginAPI>(cast<CGameEditorMediaTracker>(cast<CTrackMania>(GetApp()).Editor).PluginAPI);
        api.Quit();

        while (cast<CGameEditorMediaTracker>(cast<CTrackMania>(GetApp()).Editor) !is null)
        {
            yield();
        }

        print("Closed MediaTracker");
    }

    // Utils

    CControlBase@ GetFirstChild(CControlBase@ control, const string&in name)
    {
        CControlBase@ child = null;
        CControlContainer@ container = cast<CControlContainer>(control);
        if (control !is null)
        {
            for (uint i = 0; i < container.Childs.Length; ++i)
            {
                if (container.Childs[i] !is null && container.Childs[i].IdName == name)
                {
                    @child = container.Childs[i];
                    break;
                }
            }
        }
        return child;
    }

    array<string>@ g_screenshotsFiles = null;
    void SnapshotScreenshotsFolder()
    {
        @g_screenshotsFiles = IO::IndexFolder(IO::FromUserGameFolder("ScreenShots"), false);
    }

    void RenameNewVideo(const string&in filename)
    {
        if (g_screenshotsFiles is null)
        {
            error("No initial snapshot to compare");
            return;
        }

        auto newFiles = IO::IndexFolder(IO::FromUserGameFolder("ScreenShots"), false);
        uint index = 0;
        while (index < newFiles.Length)
        {
            int existingIndex = g_screenshotsFiles.Find(newFiles[index]);
            if (existingIndex < 0)
            {
                index++;
            }
            else
            {
                newFiles.RemoveAt(index);
            }
        }

        for (uint i = 0; i < newFiles.Length; i++)
        {
            string newName = filename;
            if (i > 0)
            {
                newName += tostring(i);
            }

            string dir = GetDirectoryName(newFiles[i]);
            string ext = GetExtension(newFiles[i]);

            // Only operate on webm files just in case
            if (ext == ".webm")
            {
                string newFullPath = dir + "/" + newName + ext;
                print("Renaming file to: " + tostring(newFullPath));
                IO::Move(newFiles[i], newFullPath);
            }
            else
            {
                print("Skipping: " + tostring(newFiles[i]));
            }
        }

        @g_screenshotsFiles = null;
    }

    string GetDirectoryName(const string&in path)
    {
        string directory = "";
        array<uint8> seps = { '/'[0], '\\'[0] };
        int pos = path.Length - 1;
        while (pos >= 0)
        {
            bool found = false;
            for (uint i = 0; i < seps.Length; ++i)
            {
                if (path[pos] == seps[i])
                {
                    directory = path.SubStr(0, pos);
                    found = true;
                }
            }

            if (found)
            {
                break;
            }
            --pos;
        }
        return directory;
    }

    string GetFilename(const string&in path)
    {
        string filename = "";
        array<uint8> seps = { '/'[0], '\\'[0] };
        int pos = path.Length - 1;
        while (pos >= 0)
        {
            bool found = false;
            for (uint i = 0; i < seps.Length; ++i)
            {
                if (path[pos] == seps[i])
                {
                    filename = path.SubStr(pos + 1);
                    found = true;
                }
            }

            if (found)
            {
                break;
            }
            --pos;
        }
        return filename;
    }

    string GetExtension(const string&in filename)
    {
        string ext = "";
        uint8 sep = "."[0];
        int pos = filename.Length - 1;
        while (pos >= 0)
        {
            if (filename[pos] == sep)
            {
                ext = filename.SubStr(pos);
                break;
            }
            --pos;
        }
        return ext;
    }

    string StripExtension(const string&in filename)
    {
        string name = filename;
        uint8 sep = "."[0];
        int pos = filename.Length - 1;
        while (pos >= 0)
        {
            if (filename[pos] == sep)
            {
                name = filename.SubStr(0, pos);
                break;
            }
            --pos;
        }
        return name;
    }
}
