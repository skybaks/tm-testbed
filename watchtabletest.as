
/*
OpenplanetNext.json structure


- m: Members
    - n: Name
    - i: Index, seems to be for ordering
    - t: type of a property/member
    - r: return value of function
    - a: input arguments to function
    - m: ?
    - c: ?


To create a watch table:
- Wrapper class for every object
    - provides a string representation
    - provides access to each member
        - each member in the form of the same wrapper class type
- Use code generation to produce an entire signal database from itself


Questions:
- Do we generate all possibilities like App.Editor.XYZ or do we get those to fit together somehow?
- Use dictionary for lookup or arrays?


*/

interface IWatchTableObject
{
    string get_Name();
    string get_FullName();
    string get_Value();

    // GetMemberNames() ?
    IWatchTableObject@ GetMember(const string&in name);
}

mixin class WatchTableMixin
{
    protected string m_name;
    protected string m_qualifiedName;

    string get_Name() { return m_name; }
    string get_FullName() { return m_qualifiedName; }
}


funcdef CGameNetServerInfo@ CGameNetServerInfo_GetFunction();
class CGameNetServerInfo_WrapObj : WatchTableMixin, IWatchTableObject
{
    private CGameNetServerInfo_GetFunction@ m_getFunctionCGameNetServerInfo;

    CGameNetServerInfo_WrapObj(CGameNetServerInfo_GetFunction@ getFunction, const string&in name, const string&in qualifiedName)
    {
        @m_getFunctionCGameNetServerInfo = getFunction;
        m_name = name;
        m_qualifiedName = qualifiedName;
    }

    string get_Value()
    {
        auto@ self = m_getFunctionCGameNetServerInfo();
        if (self is null) { return "null"; }
        return "CGameNetServerInfo@";
    }
    IWatchTableObject@ GetMember(const string&in name) { return null; }
}


funcdef CGameManiaAppPlayground@ CGameManiaAppPlayground_GetFunction();
class CGameManiaAppPlayground_WrapObj : IWatchTableObject
{
    private CGameManiaAppPlayground_GetFunction@ m_getFunction;
    private string m_name;
    private string m_qualifiedName;

    CGameManiaAppPlayground_WrapObj(CGameManiaAppPlayground_GetFunction@ getFunction, const string&in name, const string&in qualifiedName)
    {
        @m_getFunction = getFunction;
        m_name = name;
        m_qualifiedName = qualifiedName;
    }

    string get_Name() { return m_name; }
    string get_FullName() { return m_qualifiedName; }
    string get_Value()
    {
        auto@ self = m_getFunction();
        if (self is null) { return "null"; }
        return "CGameManiaAppPlayground@";
    }
    IWatchTableObject@ GetMember(const string&in name) { return null; }
}







funcdef CGameNetwork@ CGameNetwork_GetFunction();
class CGameNetwork_WrapObj : WatchTableMixin, IWatchTableObject
{
    private CGameNetwork_GetFunction@ m_getFunctionCGameNetwork;

    CGameNetwork_WrapObj(CGameNetwork_GetFunction@ getFunction, const string&in name, const string&in qualifiedName)
    {
        @m_getFunctionCGameNetwork = getFunction;
        m_name = name;
        m_qualifiedName = qualifiedName;
    }

    CGameNetwork_WrapObj()
    {
    }

    string get_Value()
    {
        auto@ self = m_getFunctionCGameNetwork();
        if (self is null) { return "null"; }
        return "CGameNetwork@";
    }
    IWatchTableObject@ GetMember(const string&in name)
    {
        if (name == "ServerInfo")
        {
            return GetWrapObjServerInfo();
        }
        return null;
    }

    private CGameNetServerInfo@ GetCGameNetServerInfo()
    {
        auto@ self = m_getFunctionCGameNetwork();
        if (self is null) { return null; }
        return self.ServerInfo;
    }
    private CGameNetServerInfo_WrapObj@ m_wrapObjServerInfo = null;
    CGameNetServerInfo_WrapObj@ GetWrapObjServerInfo()
    {
        if (m_wrapObjServerInfo is null)
        {
            @m_wrapObjServerInfo = CGameNetServerInfo_WrapObj(
                CGameNetServerInfo_GetFunction(this.GetCGameNetServerInfo),
                "ServerInfo",
                m_qualifiedName + ".ServerInfo"
            );
        }
        return m_wrapObjServerInfo;
    }
}

funcdef CGameCtnNetwork@ CGameCtnNetwork_GetFunction();
class CGameCtnNetwork_WrapObj : CGameNetwork_WrapObj, IWatchTableObject
{
    private CGameCtnNetwork_GetFunction@ m_getFunctionCGameCtnNetwork;

    CGameCtnNetwork_WrapObj(CGameCtnNetwork_GetFunction@ getFunction, const string&in name, const string&in qualifiedName)
    {
        super(CGameNetwork_GetFunction(this.GetParentCGameNetwork), name, qualifiedName);
        @m_getFunctionCGameCtnNetwork = getFunction;
        //m_name = name;
        //m_qualifiedName = qualifiedName;
    }

    CGameNetwork@ GetParentCGameNetwork()
    {
        return m_getFunctionCGameCtnNetwork();
    }

    string get_Value() override
    {
        auto@ self = m_getFunctionCGameCtnNetwork();
        if (self is null) { return "null"; }
        return "CGameCtnNetwork@";
    }
    IWatchTableObject@ GetMember(const string&in name) override
    {
        auto parent = CGameNetwork_WrapObj::GetMember(name);
        if (parent !is null)
        {
            return parent;
        }

        if (name == "ClientManiaAppPlayground")
        {
            return GetWrapObjClientManiaAppPlayground();
        }
        return null;
    }

    private CGameManiaAppPlayground@ GetCGameManiaAppPlayground()
    {
        auto@ self = m_getFunctionCGameCtnNetwork();
        if (self is null) { return null; }
        return self.ClientManiaAppPlayground;
    }
    private CGameManiaAppPlayground_WrapObj@ m_wrapObjClientManiaAppPlayground = null;
    CGameManiaAppPlayground_WrapObj@ GetWrapObjClientManiaAppPlayground()
    {
        if (m_wrapObjClientManiaAppPlayground is null)
        {
            @m_wrapObjClientManiaAppPlayground = CGameManiaAppPlayground_WrapObj(
                CGameManiaAppPlayground_GetFunction(this.GetCGameManiaAppPlayground),
                "ClientManiaAppPlayground",
                m_qualifiedName + ".ClientManiaAppPlayground"
            );
        }
        return m_wrapObjClientManiaAppPlayground;
    }
}












funcdef CGameCtnApp@ CGameCtnApp_GetFunction();
class CGameCtnApp_WrapObj : IWatchTableObject
{
    private CGameCtnApp_GetFunction@ m_getFunction;
    private string m_name;
    private string m_qualifiedName;

    CGameCtnApp_WrapObj(CGameCtnApp_GetFunction@ getFunction, const string&in name, const string&in qualifiedName)
    {
        @m_getFunction = getFunction;
        m_name = name;
        m_qualifiedName = qualifiedName;
    }

    string get_Name() { return m_name; }
    string get_FullName() { return m_qualifiedName; }
    string get_Value()
    {
        auto@ self = m_getFunction();
        if (self is null) { return "null"; }
        return "CGameCtnApp@";
    }
    IWatchTableObject@ GetMember(const string&in name)
    {
        if (name == "Network")
        {
            return GetWrapObjNetwork();
        }
        return null;
    }

    // For example:
    // Network
    private CGameCtnNetwork@ GetCGameCtnNetwork()
    {
        auto@ self = m_getFunction();
        if (self is null) { return null; }
        return self.Network;
    }
    private CGameCtnNetwork_WrapObj@ m_network = null;
    CGameCtnNetwork_WrapObj@ GetWrapObjNetwork()
    {
        if (m_network is null)
        {
            // Better to let the parent handle the naming. shouldnt need to think about name as a child
            @m_network = CGameCtnNetwork_WrapObj(
                CGameCtnNetwork_GetFunction(this.GetCGameCtnNetwork),
                "Network",
                m_qualifiedName + ".Network"
            );
        }
        return m_network;
    }
}

void Main_watchtabletest()
{
    print("Main_watchtabletest");

    IWatchTableObject@ app = CGameCtnApp_WrapObj(GetApp, "App", "App");
    print(app.Value);
    IWatchTableObject@ network = app.GetMember("Network");
    print(network.Value);
    IWatchTableObject@ playground = network.GetMember("ClientManiaAppPlayground");
    print(playground.Value);
    print(network.GetMember("ServerInfo").Value);
}
