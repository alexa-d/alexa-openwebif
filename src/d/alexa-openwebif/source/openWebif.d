module openWebif;

import vibe.d;

///
struct Movie {
	string fullname;
	string eventname;
	string filename;
	string filename_stripped;
	string description;
	string descriptionExtended;
	string tags;
	long filesize;
	string length;
	string servicename;
	string begintime;
	string serviceref;
	long lastseen;
	long recordingtime;
}

///
struct MovieList
{
	string directory;
	Movie[] movies;
	string[] bookmarks;
}

///
struct Subservice
{
	string servicereference;
	string servicename;
}

///
struct Service
{
	string servicereference;
	string servicename;
	Subservice[] subservices;
}

///
struct ServicesList
{
	bool result;
	Service[] services;
}

///
struct CurrentServiceInfo
{
	string name;
}
struct CurrentServiceEPG
{
	string sname;
	string title;
	long begin_timestamp;
	long now_timestamp;
	string shortdesc;
	string longdesc;
}

///
struct CurrentService
{
	CurrentServiceInfo info;	
	CurrentServiceEPG now;
	CurrentServiceEPG next;
}

///
struct Zap
{
	string message;
	bool result;
}

///
struct Vol
{
	int current;
	string message;
	bool result;
	bool ismute;
}

///
struct Timer 
{
	string servicename;
	string name;
	string realbegin;
	string realend;
}

///
struct TimerList
{
	Timer[] timers;
	bool result;
	string[] locations;
}

///
struct SleepTimer
{
	string action;
	int minutes;
	string message;
	bool enabled;
}

///
struct RecordNow
{
	string message;
	bool result;
}

///
struct PowerState
{
	bool instandby;
	bool result;
}

///
interface OpenWebifApi {
	MovieList movielist();
	
	ServicesList getallservices();
	CurrentService getcurrent();
	TimerList timerlist();

	@method(HTTPMethod.GET)
	Zap zap(string sRef);
	/* vol expects a string containing up (increase by 5), down (decrease by 5), set<int> (set100) or mute for toogle mute state */ 
	@method(HTTPMethod.GET)
	Vol vol(string set);
	/* sleeptimer expects cmd=set|get action=standby|shutdown time=minutes 1-999 enabled=True|False */
	@method(HTTPMethod.GET)
	SleepTimer sleeptimer(string cmd, string action, int time, string enabled);
	@method(HTTPMethod.GET)
	RecordNow recordnow();
	/* powerstate expects 0 for toggle standby, 1 for deep stanbdy, 2 reboot box, 3 restart gui */
	@method(HTTPMethod.GET)
	PowerState powerstate(int newstate);
	
	Json message(string text, int type, int timeout);
}
