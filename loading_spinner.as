
namespace loading_spinner
{

    string g_text = "";

    void Main()
    {
        array<string> loadingSteps = {
            Icons::Kenney::MoveBr,
            Icons::Kenney::MoveBt,
            Icons::Kenney::MoveRt,
            Icons::Kenney::MoveLr,
            Icons::Kenney::MoveLt,
            Icons::Kenney::MoveBtAlt,
            Icons::Kenney::MoveLb,
            Icons::Kenney::MoveLrAlt
        };
        uint index = 0;

        while (false)
        {
            sleep(50);
            if (index >= loadingSteps.Length)
            {
                index = 0;
            }
            g_text = loadingSteps[index];
            ++index;
        }
    }

    void RenderInterface()
    {
        UI::Begin("testbed");
        UI::Text(g_text + " Loading");
        UI::End();
    }

}