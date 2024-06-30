
namespace handletest
{
    int g_instances = 0;

    class MyObject
    {
        int m_instance;

        MyObject()
        {
            g_instances += 1;
            m_instance = g_instances;
            print("created " + tostring(m_instance));
        }

        void Print(const string&in name)
        {
            print(tostring(name) + " MyObject{ " + tostring(m_instance) + " }");
        }
    }


    void main()
    {
        MyObject@ obj1 = MyObject();
        MyObject@ obj2 = MyObject();
        obj1.Print("obj1");
        obj2.Print("obj2");

        auto@ swap = obj2;
        @obj2 = obj1;
        @obj1 = swap;

        obj1.Print("obj1");
        obj2.Print("obj2");
    }

    void print_array(const string&in name, array<int>@ a)
    {
        string txt = name + " {";
        for (uint i = 0; i < a.Length; i++)
        {
            txt += tostring(a[i]);
            if (i < (a.Length - 1))
            {
                txt += ", ";
            }
        }
        txt += "}";
        print(txt);
    }
}
