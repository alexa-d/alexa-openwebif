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