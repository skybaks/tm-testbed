
namespace json
{
    string GetPath()
    {
        return IO::FromStorageFolder("EditorFunction_CustomPalette.json");
    }

    void save()
    {
        auto js = Json::Object();

        auto palettes = Json::Array();

        for (uint i = 0; i < 4; ++i)
        {
            auto palette = Json::Object();

            palette["name"] = "elem" + tostring(i);

            auto articles = Json::Array();
            for (uint articleIndex = 0; articleIndex < 10; ++articleIndex)
            {
                articles.Add(Json::Value("Item/Other/Timer/Thing.Item.Gbx." + tostring(articleIndex)));
            }
            palette["articles"] = articles;

            palettes.Add(palette);
        }

        js["palettes"] = palettes;

        Json::ToFile(GetPath(), js);
    }

    void load()
    {
        auto js = Json::FromFile(GetPath());

        auto palettes = js.Get("palettes", Json::Array());
        for (uint i = 0; i < palettes.Length; ++i)
        {
            string name = palettes[i].Get("name", Json::Value("default"));
            auto articles = palettes[i].Get("articles", Json::Array());
            for (uint articleIndex = 0; articleIndex < articles.Length; ++articleIndex)
            {
                string article = articles[articleIndex];
                print(article);
            }
            print(name);
        }
    }
}
