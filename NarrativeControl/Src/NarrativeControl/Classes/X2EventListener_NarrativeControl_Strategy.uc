class X2EventListener_NarrativeControl_Strategy extends X2EventListener config (NarrativeControl_Settings);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	//check if highlander exists and is at least version 1.9, before adding template
	if(IsCHHLMinVersionInstalled(1,9))
	{
		Templates.AddItem(CreateOverrideAddConversationListenerTemplate());
	}
	else
	{
		`log("X2WOTCCommunityHighlander is missing or is an old version! Please install the latest version and relaunch the game.",,'NC');
	}

	return Templates;
}

//event listener template that listens for the 'AddConversation' event in UINarrativeMgr:AddConversation)()
static function CHEventListenerTemplate CreateOverrideAddConversationListenerTemplate()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'OverrideAddConversation_NarrativeControl');

	Template.RegisterInTactical = false;
	Template.RegisterInStrategy = true;

	Template.AddCHEvent('AddConversation', OverrideAddConversation, ELD_Immediate);
	`log("Register Event OverrideAddConversation",,'NC');

	return Template;
}

static function EventListenerReturn OverrideAddConversation(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComLWTuple						OverrideTuple;
	local XComNarrativeMoment				Moment;
	local NarrativeControl_Settings 		settings;
	local XComHQPresentationLayer			pres;
	local int 								idx;				//used in for loop below
	local bool 								shouldReturn;		//used in for loop below

	OverrideTuple = XComLWTuple(EventData);
	settings = new class'NarrativeControl_Settings';
	Moment = XComNarrativeMoment(OverrideTuple.Data[1].o);
	pres = `HQPRES;
	shouldReturn = false;
	
	//Uncomment this log function to investigate SoundCue Names
	//`log("CueName:"@OverrideTuple.Data[2].n@"MomentType:"@Moment.eType@"bUISound:"@OverrideTuple.Data[4].b@"FadeSpeed:"@OverrideTuple.Data[5].f,,'NC');
	
	//`log("StrategyNarrativesToSkip Length:"@settings.StrategyNarrativesToSkip.length,,'NC');
	
	if(OverrideTuple == none)
	{
		//`REDSCREEN("OverrideAddConversation event triggered with invalid event data.");
		return ELR_NoInterrupt;
	}
	
	//return if tuple returned isn't the one we're expecting
	else if(OverrideTuple.Id != 'AddConversationOverride')
	{
		//`log("TUPLE ID DOES NOT MATCH",,'NC');
		return ELR_NoInterrupt;
	}
	
	//Do not block cinematic or tentpole narratives
	//Blocking cinematics can cause the camera to suddenly move to another room when the callback occurs, with no indication of why
	//The descriptions of each Narrative Moment Type can be found in the 'XComNarrativeMoment' class
	switch(Moment.eType)
	{
		case  eNarrMoment_Tentpole:
		case  eNarrMoment_Bink:
		case  eNarrMoment_Matinee:                
		case  eNarrMoment_MatineeModal:   
			return ELR_NoInterrupt;

		default:
			break;
	}
	
	if(settings.NoNarrativesAtAll)
	{
		OverrideTuple.Data[0].b = false;
		return ELR_NoInterrupt; 
	}

	//check custom exclusions
	else if(settings.StrategyNarrativesToSkip.length > 0)
	{
		for(idx = 0; idx < settings.StrategyNarrativesToSkip.length; ++idx )
		{
			//`log("Exclude:"@settings.StrategyNarrativesToSkip[idx].Exclude@"Include:"@settings.StrategyNarrativesToSkip[idx].Include,,'NC');
			
			//only exclude the narrative if the string from the 'Include' text isn't in the sound cue name
			if(InStr(OverrideTuple.Data[2].n,settings.StrategyNarrativesToSkip[idx].Exclude) != INDEX_NONE && 
				(settings.StrategyNarrativesToSkip[idx].Include == "" || 
				InStr(OverrideTuple.Data[2].n,settings.StrategyNarrativesToSkip[idx].Include) == INDEX_NONE) )
			{  
				OverrideTuple.Data[0].b = false;
				shouldReturn = true;
				break;
			}
		}
		
		if (shouldReturn)
		{
			//`log("NARRATIVE EXCLUDED",,'NC');
			return ELR_NoInterrupt;
		}	
	}

	//block narratives on the Geoscape
	if(settings.NoNarrativesInGeoscape && pres.StrategyMap2D != none)
	{
		//`log("Blocking Geoscape narrative",,'NC');
		
		OverrideTuple.Data[0].b = false;

		return ELR_NoInterrupt;
	}
	else if(settings.BradfordNarratives != "All" && InStr(OverrideTuple.Data[2].n,"SoundSpeechStrategyCentral") != INDEX_NONE)
	{	
		if (settings.BradfordNarratives == "Ambient Only" && (Moment.AmbientCriteriaTypeName != '' || Moment.AmbientConditionTypeNames.Length > 0))
		{
			//`log("CENTRAL AMBIENT MOMENT INCLUDED");
		}
		else
		{
			OverrideTuple.Data[0].b = false;
		}
		return ELR_NoInterrupt;
	}
	
	//stop the Shen/Tygan greeting narratives if there's already a narrative playing
	else if(settings.NoGreetingsWhenNarrativePlaying && (InStr(OverrideTuple.Data[2].n,"Shen_Greeting") != INDEX_NONE 
			|| InStr(OverrideTuple.Data[2].n,"Tygan_Greeting") != INDEX_NONE) )
	{
		Moment.bDontPlayIfNarrativePlaying = true;
		OverrideTuple.Data[1].o = Moment;
		return ELR_NoInterrupt;
	}	
	
	return ELR_NoInterrupt;
}

static function bool IsCHHLMinVersionInstalled(int iMajor, int iMinor)
{
    local X2StrategyElementTemplate VersionTemplate;

    VersionTemplate = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager().FindStrategyElementTemplate('CHXComGameVersion');
    if (VersionTemplate == none)
    {
        return false;
    }
    else
    {
        // DANGER TERRITORY
        // if this runs without the CHHL or equivalent installed, it crashes
        return CHXComGameVersionTemplate(VersionTemplate).MajorVersion > iMajor ||  (CHXComGameVersionTemplate(VersionTemplate).MajorVersion == iMajor && CHXComGameVersionTemplate(VersionTemplate).MinorVersion >= iMinor);
    }
}
