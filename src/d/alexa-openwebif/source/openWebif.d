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

struct ServicesList
{
	bool result;
	Service[] services;
}

///
interface OpenWebifApi {
	MovieList movielist();
	
	ServicesList getallservices();

	@method(HTTPMethod.GET)
	Json message(string text, int type, int timeout);
}
