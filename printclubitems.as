

void printclubitems()
{
    CGameCtnChapter@ blocksChapter = null;
    for (uint i = 0; i < GetApp().GlobalCatalog.Chapters.Length; i++)
    {
        if (GetApp().GlobalCatalog.Chapters[i].CollectionFid !is null
            && GetApp().GlobalCatalog.Chapters[i].CollectionFid.FileName == "Stadium.Collection.Gbx")
        {
            @blocksChapter = GetApp().GlobalCatalog.Chapters[i];
            break;
        }
    }

    if (blocksChapter !is null)
    {
        for (uint i = 0; i < blocksChapter.Articles.Length; i++)
        {
            uint dataLoc = uint(blocksChapter.Articles[i].ArticleDataLocation);
            if (dataLoc != 0)
            {
                print(tostring(dataLoc) + " " + blocksChapter.Articles[i].IdName);
            }
        }
    }
}