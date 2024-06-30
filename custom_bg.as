/*
string layerId = "custombg-b4c8cbc5-e9d3-4e10-b864-48fda3c6abdc";
CGameUILayer@ menuLayer = null;

void Main()
{

    auto maniaAppTitle = cast<CGameManiaAppTitle>(cast<CTrackManiaMenus>(cast<CTrackMania>(GetApp()).MenuManager).MenuCustom_CurrentManiaApp);
    auto uiLayers = maniaAppTitle.UILayers;
    for (uint i = 0; i < uiLayers.Length; ++i)
    {
        if (uiLayers[i].AttachId == layerId)
        {
            @menuLayer = uiLayers[i];
            break;
        }
        //else
        //{
        //    uiLayers[i].IsVisible = true;
        //}

    }
    if (menuLayer is null)
    {
        @menuLayer = maniaAppTitle.UILayerCreate();
        menuLayer.AttachId = layerId;
    }

    menuLayer.IsVisible = true;

    menuLayer.ManialinkPage = """<manialink name="Page_CustomBg" version="3">
<stylesheet>
<style class="background" size="320 180" halign="center" valign="center" keepratio="fit"/>
</stylesheet>
<frame id="frame-global" z-index="-0.01">
<quad id="quad-custom" image="https://images.mania-exchange.com/next/backgrounds/21-08/bg.jpg" fullscreen="1" opacity="1." class="background" />
</frame>
</manialink>""";

    print(tostring(menuLayer.AttachId));

}

*/