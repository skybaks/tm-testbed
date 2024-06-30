
namespace screenshot_automation
{
    void Main()
    {
        return;

        OpenEditor("Quicksaves_EditorHelpers\\My Maps_snow_01_000001.Map.Gbx");
        OpenMediaTrackerIntro();
        LoadClipMT("scripttest_01.Clip.Gbx");
        ComputeShadowsMT();
        ShootVideo("scripttest_01");
        CloseMediaTracker();
        CloseEditor();
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
        yield();
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

        print("In MT");
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
        auto api = cast<CGameEditorMediaTrackerPluginAPI>(cast<CGameEditorMediaTracker>(cast<CTrackMania>(GetApp()).Editor).PluginAPI);
        api.ShootVideo();

        yield();

        auto entry = GetFirstChild(GetFirstChild(GetFirstChild(GetFirstChild(GetApp().ActiveMenus[0].CurrentFrame, "FrameContent"), "FrameParameters"), "FrameVideoName"), "EntryVideoName");
        auto parms = cast<CGameDialogShootParams>(entry.Nod);
        if (parms !is null)
        {
            parms.SetQualityPreset_High();
            parms.ShootName = filename;

            return;

            // ...it doesnt work...
            // How can i reliably set the dang file name?!
            entry.IsFocused = true;
            sleep(1000);
            // Now take focus away to lock in name
            GetFirstChild(GetFirstChild(GetFirstChild(GetFirstChild(GetApp().ActiveMenus[0].CurrentFrame, "FrameContent"), "FrameButtons"), "ButtonOk"), "ButtonSelection").IsFocused = true;
            sleep(1000);


            parms.OnOk();

            yield();
        }

        auto startTime = api.CurrentTimer;
        while (startTime == api.CurrentTimer)
        {
            api.TimePlay();
            yield();
        }
        api.TimeStop();
        api.CurrentTimer = startTime;

        print("Done shooting: " + filename);
    }

    void CloseMediaTracker()
    {
        auto api = cast<CGameEditorMediaTrackerPluginAPI>(cast<CGameEditorMediaTracker>(cast<CTrackMania>(GetApp()).Editor).PluginAPI);
        api.Quit();
        yield();
    }

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
}
