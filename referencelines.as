
/*

bool g_active = false;
array<vec3> g_points = {};

void Main()
{
}

void RenderInterface()
{
    UI::Begin("testbed");

    if (!g_active)
    {
        if (UI::Button("Activate"))
        {
            g_active = true;
        }
    }
    else
    {
        if (UI::Button("Deactivate"))
        {
            g_active = false;
        }
    }

    UI::SameLine();
    if (UI::Button("Clear"))
    {
        g_points.RemoveRange(0, g_points.Length);
    }

    for (uint i = 0; i < g_points.Length; ++i)
    {
        UI::Text(tostring(g_points[i]));
    }

    UI::End();
}

// UI::InputBlocking::DoNothing
// UI::InputBlocking::Block
UI::InputBlocking OnMouseButton(bool down, int button, int x, int y)
{
    //left mouse is 0
    if (g_active && button == 0)
    {
        if (!down)
        {
            print(tostring(down) + " " + tostring(button));
            g_points.InsertLast(cast<CGameCtnEditorFree>(GetApp().Editor).Cursor.FreePosInMap);
        }
        return UI::InputBlocking::Block;
    }
    return UI::InputBlocking::DoNothing;
}

void Render()
{
    if (g_points.Length > 1)
    {
        nvg::BeginPath();
        bool lineStarted = false;
        for (uint i = 0; i < g_points.Length; ++i)
        {
            vec3 screenPos = Camera::ToScreen(g_points[i]);
            if (!lineStarted)
            {
                nvg::MoveTo(screenPos.xy);
                lineStarted = true;
            }
            else
            {
                nvg::LineTo(screenPos.xy);
            }
        }
        nvg::StrokeWidth(2.0f);
        nvg::StrokeColor(vec4(0.2f, 1.0f, 0.2f, 1.0f));
        nvg::Stroke();
    }
}

*/
