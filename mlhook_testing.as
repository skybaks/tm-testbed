
ServerMapListEvents@ g_hook = null;

void mlhook_testing_Main()
{
    print("hello from testbed mlhook_testing_Main");

    //auto api = GetApp().Network.PlaygroundClientScriptAPI;
    //print(tostring(Dev::GetOffsetUint8(api.MapList_Names[0], 0)));

    MLHook::UnregisterMLHooksAndRemoveInjectedML();

    //@g_hook = ServerMapListEvents("ServerMapList");
    //MLHook::RegisterMLHook(g_hook, "ServerMapList_MapListNames");
    //MLHook::RegisterMLHook(g_hook, "ServerMapList_MapListUids");
    auto fs = IO::FileSource("mlhook_playground_test.Script.txt");
    MLHook::InjectManialinkToPlayground("ServerMapList", fs.ReadToEnd(), true);
}



class ServerMapListEvents : MLHook::HookMLEventsByType
{
    array<string> m_mapNames;
    array<string> m_mapUids;

    ServerMapListEvents(const string&in type)
    {
        super(type);

        m_mapNames = {};
        m_mapUids = {};
    }

    void OnEvent(MLHook::PendingEvent@ event) override
    {
        print("Got event with type: " + tostring(event.type));
        if (event.type == MLHook::EventPrefix + "ServerMapList_MapListNames")
        {
            m_mapNames.Resize(event.data.Length);
            for (uint i = 0; i < event.data.Length; ++i)
            {
                m_mapNames[i] = tostring(event.data[i]);
            }
        }
        else if (event.type == MLHook::EventPrefix + "ServerMapList_MapListUids")
        {
            m_mapUids.Resize(event.data.Length);
            for (uint i = 0; i < event.data.Length; ++i)
            {
                m_mapUids[i] = tostring(event.data[i]);
            }
        }
    }
}




bool g_showing = false;
void mlhook_testing_RenderInterface()
{
    if (g_showing)
    {
        UI::Begin("testbed", g_showing);

        if (UI::Button("update maps"))
        {
            auto api = GetApp().Network.PlaygroundClientScriptAPI;
            if (api !is null)
            {
                api.MapList_Request();
                MLHook::Queue_MessageManialinkPlayground("ServerMapList", "SendMapListNames");
                MLHook::Queue_MessageManialinkPlayground("ServerMapList", "SendMapListUids");
            }
        }

        if (g_hook !is null && g_hook.m_mapNames.Length == g_hook.m_mapUids.Length)
        {
            if (UI::BeginTable("table", 2))
            {
                for (uint i = 0; i < g_hook.m_mapNames.Length; ++i)
                {
                    UI::TableNextRow();
                    UI::TableNextColumn();
                    UI::Text(g_hook.m_mapNames[i]);

                    UI::TableNextColumn();
                    UI::Text(g_hook.m_mapUids[i]);
                }

                UI::EndTable();
            }
        }


        UI::End();
    }
}
