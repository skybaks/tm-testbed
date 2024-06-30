/*
MediatrackerEditor - TmNext

Editor -> CGameEditorMediaTracker
Editor.PluginAPI -> CGameEditorMediaTrackerPluginAPI

Things that work:

Editor.PluginAPI.ToggleAlwaysShowTriggerZone();
    Calling this toggles a mode where the triggers are always shown. Not sure if we can know state.

EditorPluginAPI.CurrentTimer = 0.0;
    Can be set or read. Decimal number where 1.0 = 1 second.
*/


/*
MeshModeler - TmNext

Editor -> CGameEditorMesh

Things that work:

Editor.IsEditingLayer = true/false;
    Read and write to determine if layer is being edited.

Editor.LayerName = "";
    Read and write for active layer.

Editor.Display_HideMap(); Editor.Display_ShowMap();
    Hide or show the map behind the edited item.

*/
