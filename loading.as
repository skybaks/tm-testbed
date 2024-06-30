
namespace loading
{
    void load_plugin()
    {
        // Needs absolute path
        Meta::LoadPlugin("OpenplanetNext\\Plugins\\TestDep", Meta::PluginSource::UserFolder, Meta::PluginType::Folder);
    }

    void reload_plugin(const string&in name)
    {
        auto plugin = Meta::GetPluginFromID(name);
        if (plugin !is null)
        {
            print("plugin not null");

            print("unloading plugin");
            Meta::UnloadPlugin(plugin);
            print("unloaded");

            print("yield");
            yield();
            print("yield done");
        }
        else
        {
            print("plugin is null");
        }

        print("loading plugin");
        Meta::LoadPlugin("OpenplanetNext\\Plugins\\" + name + "\\", Meta::PluginSource::UserFolder, Meta::PluginType::Folder);
        print("loaded");
    }
}
