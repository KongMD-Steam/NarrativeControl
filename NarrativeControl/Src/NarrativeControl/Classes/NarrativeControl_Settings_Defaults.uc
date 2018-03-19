class NarrativeControl_Settings_Defaults extends Object config(NarrativeControl_Settings_Defaults);

var config int ConfigVersion;
var config string BradfordNarratives;
var config bool NoGreetingsWhenNarrativePlaying;
var config bool NoNarrativesInGeoscape;
var config bool NoNarrativesAtAll;

struct NarrativeToSkip
{
	var string Exclude;
	var string Include;
};
var config array<NarrativeToSkip> StrategyNarrativesToSkip;
