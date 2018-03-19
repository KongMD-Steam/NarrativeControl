class NarrativeControl_Settings_Defaults extends Object config(NarrativeControl_Settings_Defaults);

var config int ConfigVersion;
var config string BradfordNarratives;
var config bool NoGreetingsWhenNarrativePlaying;
var config bool NoNarrativesInGeoscape;
var config bool NoNarrativesAtAll;
var config bool LogNarrativeInfo;

struct NarrativeToSkip
{
	var string Exclude;
	var string Include;
	var string SoundPath;		//the path of the SoundCue. Can be found in the Unreal Editor Content Browser
};
var config array<NarrativeToSkip> StrategyNarrativesToSkip;
