import std.stdio;
import std.typetuple:TypeTuple;
import vibe.http.router;
import vibe.http.server;
import vibe.web.web;
import vibe.aws.aws;
import vibe.aws.dynamodb;
import vibe.stream.tls;

import amazonlogin;

///
struct OpenWebIfDBEntry
{
	string amazonId;
	string username;
	string password;
	string url;
}

///
struct UserSettings {
	bool loggedIn = false;
	UserProfile profile;
	OpenWebIfDBEntry owifSettings;
	string state;
	string redirect_uri;
	string token;
}

///
class OpenWebIfDB
{
	
	OpenWebIfDBEntry owifItem;
	DynamoDB ddb;
	Table openwebifTable;

	this(){
		import std.process:environment;
		immutable accessKey = environment["AWS_ACCESS_KEY"];
		immutable secretKey = environment["AWS_SECRET_KEY"];
		immutable awsRegion = environment["AWS_DYNAMODB_REGION"];
		immutable owifTableName = environment["OPENWEBIF_TABLENAME"];
		auto creds = new StaticAWSCredentials(accessKey, secretKey);
		ddb = new DynamoDB(awsRegion, creds);
		openwebifTable = ddb.table(owifTableName);
	}

	///
	void writeEntry(string _url, string _username, string _password, string _auth, string _token)
	{
		auto openwebifItem = Item().set("accessToken", _token);
		openwebifItem.set("url",_url);
		if(_password.length)
			openwebifItem.set("password", _password);
		if(_username.length)
			openwebifItem.set("username", _username);
		openwebifItem.set("amazonId", _auth);
		openwebifTable.put(openwebifItem);
	}

	///
	OpenWebIfDBEntry getEntry(string amazonId)
	{
		import std.conv:to;
		import std.digest.sha:sha256Of;
		import std.digest.digest:toHexString;
		
		try {
			immutable accessToken = cast(string)(sha256Of(amazonId).toHexString());
			auto openwebifItem = openwebifTable.get("accessToken", accessToken);
			if(("password" in openwebifItem) !is null)
				owifItem.password = to!string(openwebifItem["password"]);	
			if(("username" in openwebifItem) !is null)	
				owifItem.username = to!string(openwebifItem["username"]);			
			owifItem.url = to!string(openwebifItem["url"]);
		} catch(Exception e)
		{
			stderr.writefln("%s has no entry in db: %s", amazonId, e);
		}
		return owifItem;
	}

}

///
shared static this()
{
	import vibe.http.fileserver:serveStaticFiles;

	URLRouter router = new URLRouter;
	router.registerWebInterface(new WebInterface);
	router.get("*", serveStaticFiles("public"));
	HTTPServerSettings settings = new HTTPServerSettings;
	settings.tlsContext = createTLSContext(TLSContextKind.server);
	settings.tlsContext.useCertificateChainFile("server.crt");
	settings.tlsContext.usePrivateKeyFile("server.key");
	settings.bindAddresses = ["0.0.0.0"];
	settings.port = 8080;
	settings.sessionStore = new MemorySessionStore;
	listenHTTP(settings, router);
}

///
struct TranslationContext {
	alias languages = TypeTuple!("en_US", "de_DE");
	mixin translationModule!"portal";
}

///
@translationContext!TranslationContext
class WebInterface {
	private {
		AmazonLoginApiFactory amazonLoginApiFactory;
		SessionVar!(UserSettings, "settings") m_userSettings;
	}
	this()
	{
		amazonLoginApiFactory = &createAmazonLoginApi;
	}

	///
	@path("/") void getHome()
	{
		redirect("/settings");
	}
	
	///
	void getLogin(HTTPServerRequest req)
	{
		import std.conv:to;
		import std.stdio:stderr;

		UserSettings settings = m_userSettings;
		
		if (("state" in req.query) !is null)
		{

			settings.state = req.query["state"];
			settings.redirect_uri = req.query["redirect_uri"];
			m_userSettings = settings;
		}

		if(("access_token" in req.query) !is null)
		{
			auto accessToken = req.query["access_token"];
			auto loginApi = amazonLoginApiFactory(accessToken);
			try{
				loginApi.tokeninfo(accessToken);
			}
			catch(Exception e){
				stderr.writefln("tokenInfo parsing error: %s",e);
			}
			immutable userProfile = loginApi.profile();
			settings.profile = userProfile;
			settings.loggedIn = true;
			m_userSettings = settings;
			redirect("/settings");
		}
		else
			render!("login.dt", req.host);
	}

	///
	void getLogout(scope HTTPServerResponse res)
	{
		m_userSettings = UserSettings.init;
		res.terminateSession();
		redirect("./");
	}

	///
	@auth
	void getSettings(HTTPServerRequest req, string _authUser, string _error = null)
	{
		OpenWebIfDB owif = new OpenWebIfDB();
		UserSettings settings = m_userSettings;
		settings.owifSettings = owif.getEntry(settings.profile.user_id);
		auto error = _error;
		render!("settings.dt", error, settings);
	}

	///
	@auth @errorDisplay!getSettings
	void postSettings(string owifurl, string owifusername, string owifpassword, string _authUser)
	{
		assert(m_userSettings.loggedIn);
		import std.conv:to;	
		import std.digest.digest:toHexString;
		import std.digest.sha:sha256Of;
		import std.string:format;

		OpenWebIfDB owif = new OpenWebIfDB();
		OpenWebIfDBEntry owifItem;
		owifItem.url = owifurl;
		owifItem.password = owifpassword;
		owifItem.username = owifusername;

		UserSettings settings = m_userSettings;
		settings.owifSettings = owifItem;
		settings.token = sha256Of(_authUser).toHexString();

		m_userSettings = settings;
		owif.writeEntry(owifurl, owifusername, owifpassword,_authUser, settings.token);

		if(settings.state.length)
		{
			auto redirect_uri = settings.redirect_uri;
			auto state = settings.state;
			settings.state = "";
			settings.redirect_uri = "";
			m_userSettings = settings;
			auto redirect_string = format("%s#state=%s&access_token=%s&token_type=Bearer",redirect_uri, state, settings.token);
			redirect(redirect_string);
		}		
		auto error = "Success";
		render!("settings.dt", error, settings);
	}

	private enum auth = before!ensureAuth("_authUser");

	///
	private string ensureAuth(scope HTTPServerRequest req, scope HTTPServerResponse res)
	{
		if (!WebInterface.m_userSettings.loggedIn) redirect("/login");
		return WebInterface.m_userSettings.profile.user_id;
	}

	mixin PrivateAccessProxy;

}

	
