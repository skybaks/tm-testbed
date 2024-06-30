
void saveWork()
{
    auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
    if (editor !is null)
    {
        string currentFileName = editor.PluginMapType.MapFileName;
        if (currentFileName != "")
        {
            string[] mapPath = currentFileName.Split("\\");
            string saveName = "";
            for (uint i = 0; i < (mapPath.Length - 1); i++)
            {
                saveName += mapPath[i] + "\\";
            }
            saveName += editor.PluginMapType.MapName + ".Map.Gbx";
            editor.PluginMapType.SaveMap(saveName);
        }
        else
        {
            editor.ButtonSaveOnClick();
        }
    }
}

bool g_enabled = false;
bool g_trigger = false;

void renderInterface()
{
    UI::Begin("Testbed");
    if (UI::Button(g_enabled ? "Stop" : "Start"))
    {
        g_enabled = !g_enabled;
    }
    UI::End();

    if (g_trigger)
    {
        g_trigger = false;
        saveWork();
    }
}

void _main()
{
    //auto len = cast<CGameCtnEditorFree>(GetApp().Editor).PluginMapType.Items.Length;

    while (true)
    {
        sleep(2000);
        if (g_enabled)
        {
            g_trigger = true;
        }
    }
}














