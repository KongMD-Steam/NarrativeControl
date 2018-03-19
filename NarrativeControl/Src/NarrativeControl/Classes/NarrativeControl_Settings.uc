class NarrativeControl_Settings extends Object config(NarrativeControl_Settings)
	dependsOn(NarrativeControl_Settings_Defaults);


var config int ConfigVersion;

var config string BradfordNarratives;
var localized string strBradfordNarratives;
var localized string strBradfordNarrativesTooltip;
var MCM_API_Dropdown BradfordNarratives_Dropdown;

var config bool NoGreetingsWhenNarrativePlaying;
var localized string strNoGreetingsWhenNarrativePlaying;
var localized string strNoGreetingsWhenNarrativePlayingTooltip;
var MCM_API_Checkbox NoGreetingsWhenNarrativePlaying_Checkbox;

var config bool NoNarrativesInGeoscape;
var localized string strNoNarrativesInGeoscape;
var localized string strNoNarrativesInGeoscapeTooltip;
var MCM_API_Checkbox NoNarrativesInGeoscape_Checkbox;

var config bool NoNarrativesAtAll;
var localized string strNoNarrativesAtAll;
var localized string strNoNarrativesAtAllTooltip;
var MCM_API_Checkbox NoNarrativesAtAll_Checkbox;

var config bool LogNarrativeInfo;
var localized string strLogNarrativeInfo;
var localized string strLogNarrativeInfoTooltip;
var MCM_API_Checkbox LogNarrativeInfo_Checkbox;


//settings retrieved only via the NarrativeControl_Settings_Defaults.ini. Can't manage arrays in MCM!
var config array<NarrativeToSkip> StrategyNarrativesToSkip;


`include(NarrativeControl/Src/ModConfigMenuAPI/MCM_API_Includes.uci)
`include(NarrativeControl/Src/ModConfigMenuAPI/MCM_API_CfgHelpers.uci)
`MCM_CH_VersionChecker(class'NarrativeControl_Settings_Defaults'.default.ConfigVersion, ConfigVersion)

event OnInit(UIScreen Screen)
{
    `MCM_API_Register(Screen, ClientModCallback);
	
	// Ensure that the default config is loaded, if necessary
	EnsureConfigExists();
}

function ClientModCallback(MCM_API_Instance ConfigAPI, int GameMode)
{
    // Build the settings UI
    local MCM_API_SettingsPage page;
    local MCM_API_SettingsGroup group;
	
	local array<string> BradfordNarrativesOptions; 
	BradfordNarrativesOptions.addItem("All");
	BradfordNarrativesOptions.addItem("Ambient Only");
	BradfordNarrativesOptions.addItem("None");

    LoadSavedSettings();

    page = ConfigAPI.NewSettingsPage("Narrative Control");
    page.SetPageTitle("Narrative Control");
    page.SetSaveHandler(SaveButtonClicked);
	Page.EnableResetButton(ResetButtonClicked);

    group = Page.AddGroup('StrategyLayer', "Strategy Layer");
	
	BradfordNarratives_Dropdown = group.AddDropdown('BradfordNarratives', 
		strBradfordNarratives, 
		strBradfordNarrativesTooltip,
		BradfordNarrativesOptions,
		BradfordNarratives,
		BradfordNarrativesSaveHandler);
	NoGreetingsWhenNarrativePlaying_Checkbox = group.AddCheckbox('NoGreetingsWhenNarrativePlaying', // Name
      strNoGreetingsWhenNarrativePlaying, // Text
      strNoGreetingsWhenNarrativePlayingTooltip, // Tooltip
      NoGreetingsWhenNarrativePlaying, // Initial value
      SaveNoGreetingsWhenNarrativePlaying // Save handler
	);
	NoNarrativesInGeoscape_Checkbox = group.AddCheckbox('NoNarrativesInGeoscape', // Name
      strNoNarrativesInGeoscape, // Text
      strNoNarrativesInGeoscapeTooltip, // Tooltip
      NoNarrativesInGeoscape, // Initial value
      SaveNoNarrativesInGeoscape // Save handler
    );
	NoNarrativesAtAll_Checkbox = group.AddCheckbox('NoNarrativesAtAll', // Name
      strNoNarrativesAtAll, // Text
      strNoNarrativesAtAllTooltip, // Tooltip
      NoNarrativesAtAll, // Initial value
      SaveNoNarrativesAtAll // Save handler
	);
	LogNarrativeInfo_Checkbox = group.AddCheckbox('LogNarrativeInfo', // Name
      strLogNarrativeInfo, // Text
      strLogNarrativeInfoTooltip, // Tooltip
      LogNarrativeInfo, // Initial value
      SaveLogNarrativeInfo // Save handler
	);
    page.ShowSettings();
}

`MCM_API_BasicDropDownSaveHandler(BradfordNarrativesSaveHandler, BradfordNarratives)
`MCM_API_BasicCheckboxSaveHandler(SaveNoGreetingsWhenNarrativePlaying, NoGreetingsWhenNarrativePlaying)
`MCM_API_BasicCheckboxSaveHandler(SaveNoNarrativesInGeoscape, NoNarrativesInGeoscape)
`MCM_API_BasicCheckboxSaveHandler(SaveNoNarrativesAtAll, NoNarrativesAtAll)
`MCM_API_BasicCheckboxSaveHandler(SaveLogNarrativeInfo, LogNarrativeInfo)

function LoadSavedSettings()
{
	BradfordNarratives = `MCM_CH_GetValue(class'NarrativeControl_Settings_Defaults'.default.BradfordNarratives, BradfordNarratives);
	NoGreetingsWhenNarrativePlaying = `MCM_CH_GetValue(class'NarrativeControl_Settings_Defaults'.default.NoGreetingsWhenNarrativePlaying, NoGreetingsWhenNarrativePlaying);
	NoNarrativesInGeoscape = `MCM_CH_GetValue(class'NarrativeControl_Settings_Defaults'.default.NoNarrativesInGeoscape, NoNarrativesInGeoscape);
	NoNarrativesAtAll = `MCM_CH_GetValue(class'NarrativeControl_Settings_Defaults'.default.NoNarrativesAtAll, NoNarrativesAtAll);
	LogNarrativeInfo = `MCM_CH_GetValue(class'NarrativeControl_Settings_Defaults'.default.LogNarrativeInfo, LogNarrativeInfo);
	
	//get the values not exposed to MCM from the default INI
	StrategyNarrativesToSkip = class'NarrativeControl_Settings_Defaults'.default.StrategyNarrativesToSkip;
}

function LoadNonMCMSettings()
{
	StrategyNarrativesToSkip = class'NarrativeControl_Settings'.default.StrategyNarrativesToSkip;
	//`log("StrategyNarrativesToSkip Len:"@StrategyNarrativesToSkip.length);
}

simulated function ResetButtonClicked(MCM_API_SettingsPage Page)
{
	BradfordNarratives_Dropdown.SetValue(class'NarrativeControl_Settings_Defaults'.default.BradfordNarratives, true);
	NoGreetingsWhenNarrativePlaying_Checkbox.SetValue(class'NarrativeControl_Settings_Defaults'.default.NoGreetingsWhenNarrativePlaying, true);
	NoNarrativesInGeoscape_Checkbox.SetValue(class'NarrativeControl_Settings_Defaults'.default.NoNarrativesInGeoscape, true);
	NoNarrativesAtAll_Checkbox.SetValue(class'NarrativeControl_Settings_Defaults'.default.NoNarrativesAtAll, true);
	LogNarrativeInfo_Checkbox.SetValue(class'NarrativeControl_Settings_Defaults'.default.LogNarrativeInfo, true);
}

function SaveButtonClicked(MCM_API_SettingsPage Page)
{
	//`log("StrategyNarrativesToSkip Len:"@StrategyNarrativesToSkip.length);
	
    self.ConfigVersion = `MCM_CH_GetCompositeVersion();
    self.SaveConfig();
}

function EnsureConfigExists()
{
    if(ConfigVersion == 0)
    {
        LoadSavedSettings();
        SaveButtonClicked(none);
    }
	else
	{
		LoadNonMCMSettings();
	}
}
