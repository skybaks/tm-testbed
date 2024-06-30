
void dumpdeclaresforvariables()
{
    auto nod = GetApp().UserManagerScript.Users[0];
    //auto nod = GetApp().RootMap;

    //auto fid = Fids::GetProgramData("LaunchedCheckpointCache/script_dev_14.LaunchedCP.gbx");
    //if (fid !is null)
    //{
    //    print("fid is goog");
    //}
    //auto nod = Fids::Preload(fid);

    string declare = tostring(cast<CTrackMania>(GetApp()).MenuManager.MenuCustom_CurrentManiaApp.Dbg_DumpDeclareForVariables(nod, false));
    string[] declares = declare.Split("\n");
    for (uint i = 0; i < declares.Length; ++i)
    {
        print(declares[i]);
    }
}
