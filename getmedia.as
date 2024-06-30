/*

CSystemFidsFolder@ GetTreeFidsFolder(CSystemFids@ fids, const string&in dirName)
{
    for (uint i = 0; i < fids.Trees.Length; i++)
    {
        auto treeAsFidsFolder = cast<CSystemFidsFolder>(fids.Trees[i]);
        if (treeAsFidsFolder !is null && treeAsFidsFolder.DirName == dirName)
        {
            return treeAsFidsFolder;
        }
    }
    return null;
}

void RecursiveAddDefaultSkinsPath(CSystemFidsFolder@ fidsFolder, const string&in prefix, string[]& paths)
{
    for (uint i = 0; i < fidsFolder.Trees.Length; i++)
    {
        auto fidsSubfolder = cast<CSystemFidsFolder>(fidsFolder.Trees[i]);
        RecursiveAddDefaultSkinsPath(fidsSubfolder, prefix + fidsSubfolder.DirName + "\\", paths);
    }

    for (uint i = 0; i < fidsFolder.Leaves.Length; i++)
    {
        auto fidsSubfile = cast<CSystemFidFile>(fidsFolder.Leaves[i]);
        paths.InsertLast(prefix + fidsSubfile.FileName);
    }
}

void getmedia()
{
    if (GetApp().Editor !is null)
    {
        string[] defaultSkins = {};
        CSystemFidsFolder@ appFid = cast<CSystemFidFile>(GetFidFromNod(GetApp())).ParentFolder;
        CSystemFidsFolder@ skinsFid = GetTreeFidsFolder(appFid, "Skins");
        RecursiveAddDefaultSkinsPath(skinsFid, "Skins\\", defaultSkins);

        for (uint i = 0; i < defaultSkins.Length; i++)
        {
            print(defaultSkins[i]);
        }
    }
}

*/