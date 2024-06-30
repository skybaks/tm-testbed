
namespace textdialog
{
    void Main()
    {
        bool maxLengthSet = false;

        while (true)
        {
            yield();

            if (GetApp().ActiveMenus.Length > 0)
            {
                if (maxLengthSet)
                {
                    continue;
                }

                CGameMenuFrame@ cf = GetApp().ActiveMenus[0].CurrentFrame;
                if (cf !is null
                    && cf.IdName == "FrameDialogSaveAs")
                {
                    CControlEntry@ entry = cast<CControlEntry>(
                        GetFirstChild(GetFirstChild(GetFirstChild(cf, "FrameContent"), "FrameSave"), "EntryFileName")
                    );
                    entry.MaxLength = 150;
                    maxLengthSet = true;
                    @entry = null;
                }
            }
            else
            {
                maxLengthSet = false;
            }
        }
    }

    CControlBase@ GetFirstChild(CControlBase@ control, const string&in name)
    {
        CControlBase@ child = null;
        CControlContainer@ container = cast<CControlContainer>(control);
        if (control !is null)
        {
            for (uint i = 0; i < container.Childs.Length; ++i)
            {
                if (container.Childs[i] !is null && container.Childs[i].IdName == name)
                {
                    @child = container.Childs[i];
                    break;
                }
            }
        }
        return child;
    }
}
