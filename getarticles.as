
namespace getarticles
{
    void Debug_EnterMethod(const string&in str){}
    void Debug_LeaveMethod(){}
    void Debug(const string&in str) { trace(str); }

    class EditorInventoryArticle
    {
        EditorInventoryArticle()
        {
            DisplayName = "";
            @Article = null;
            PlaceMode = CGameEditorPluginMap::EPlaceMode::Unknown;
        }

        EditorInventoryArticle(const string&in name, CGameCtnArticleNodeArticle@ article, CGameEditorPluginMap::EPlaceMode placeMode)
        {
            DisplayName = name;
            @Article = article;
            PlaceMode = placeMode;
        }

        string DisplayName;
        CGameCtnArticleNodeArticle@ Article;
        CGameEditorPluginMap::EPlaceMode PlaceMode;
    }

    EditorInventoryArticle@[] m_articles;

    void getarticles()
    {
        IndexInventory();

        print("Articles: " + tostring(m_articles.Length));

        int dupes = 0;
        for (uint i = 0; i < m_articles.Length; ++i)
        {
            string lookup = m_articles[i].DisplayName;

            for (uint lookupIndex = 0; lookupIndex < m_articles.Length; ++lookupIndex)
            {
                if (lookupIndex != i && lookup == m_articles[lookupIndex].DisplayName)
                {
                    print(tostring(lookupIndex) + " :: " + lookup);
                    dupes += 1;
                }
            }

            print(tostring(i));
        }
        print("----- DONE -----");
        print("dupes: " + tostring(dupes));
    }

    void RecursiveAddInventoryArticle(CGameCtnArticleNode@ current, const string&in name, CGameEditorPluginMap::EPlaceMode placeMode)
    {
        Debug_EnterMethod("RecursiveAddInventoryArticle");

        CGameCtnArticleNodeDirectory@ currentDir = cast<CGameCtnArticleNodeDirectory>(current);
        if (currentDir !is null)
        {
            for (uint i = 0; i < currentDir.ChildNodes.Length; ++i)
            {
                auto newDir = currentDir.ChildNodes[i];
                if (newDir.IsDirectory)
                {
                    RecursiveAddInventoryArticle(newDir, name + "/" + newDir.NodeName, placeMode);
                }
                else
                {
                    CGameCtnArticleNodeArticle@ currentArt = cast<CGameCtnArticleNodeArticle>(newDir);
                    if (currentArt !is null)
                    {
                        string articleName = name + "/" + currentArt.NodeName;
                        if (currentArt.NodeName.Contains("\\"))
                        {
                            auto splitPath = tostring(currentArt.NodeName).Split("\\");
                            if (splitPath.Length > 0)
                            {
                                articleName = name + "/" + splitPath[splitPath.Length-1];
                                Debug("Split node name results in: " + tostring(articleName));
                            }
                        }
                        Debug("Add " + articleName);
                        m_articles.InsertLast(EditorInventoryArticle(articleName, currentArt, placeMode));
                    }
                }
            }
        }

        Debug_LeaveMethod();
    }

    void IndexInventory()
    {
        Debug_EnterMethod("IndexInventory");

        if (m_articles.Length > 0)
        {
            Debug("Clearing cached articles");
            m_articles.RemoveRange(0, m_articles.Length);
        }
        //if (m_articlesHistory.Length > 0)
        //{
        //    Debug("Clearing recent articles");
        //    m_articlesHistory.RemoveRange(0, m_articlesHistory.Length);
        //}

        auto Editor = cast<CGameCtnEditorFree>(GetApp().Editor);

        Debug("Loading inventory blocks");
        RecursiveAddInventoryArticle(Editor.PluginMapType.Inventory.RootNodes[0], "Block", CGameEditorPluginMap::EPlaceMode::Block);
        Debug("Loading inventory items");
        RecursiveAddInventoryArticle(Editor.PluginMapType.Inventory.RootNodes[3], "Item", CGameEditorPluginMap::EPlaceMode::Item);
        Debug("Loading inventory macroblocks");
        RecursiveAddInventoryArticle(Editor.PluginMapType.Inventory.RootNodes[4], "Macroblock", CGameEditorPluginMap::EPlaceMode::Macroblock);

        Debug("Inventory total length: " + tostring(m_articles.Length));

        //UpdateFilteredList();

        Debug_LeaveMethod();
    }

}

