class NarrativeControl_Settings_Listener extends UIScreenListener;

event OnInit(UIScreen Screen)
{
    local NarrativeControl_Settings settings;

    if (MCM_API(Screen) != none || UIShell(Screen) != none)
    {
        settings = new class'NarrativeControl_Settings';
        settings.OnInit(Screen);
    }
}

defaultproperties
{
    ScreenClass = none;
}