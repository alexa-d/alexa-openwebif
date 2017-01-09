module amazonlogin;

import vibe.data.serialization:optional;

///
struct TokenInfo
{
	/// this needs to be validated against our Client-Id
	string aud;
	///
	long exp;
	///
	string iss;
	///
	string user_id;
	///
	string app_id;
	///
	long iat;
}

///
struct UserProfile
{
	///
	@optional
	string name;
	///
	@optional
	string email;
	///
	string user_id;
}

///
interface AmazonLoginApi
{
	import vibe.web.rest:method,path;
	import vibe.http.common:HTTPMethod;

	///
	@path("auth/o2/tokeninfo")
	@method(HTTPMethod.GET)
	TokenInfo tokeninfo(string access_token);

	///
	@path("user/profile")
	@method(HTTPMethod.GET)
	UserProfile profile();
}

///
alias AmazonLoginApiFactory = AmazonLoginApi function(string);
///
static AmazonLoginApi createAmazonLoginApi(string access_token)
{
	import vibe.web.rest:RestInterfaceClient;
	import vibe.http.client:HTTPClientRequest;
	auto res = new RestInterfaceClient!AmazonLoginApi("https://api.amazon.com/");

	res.requestFilter = (HTTPClientRequest req){
		import std.algorithm:endsWith;
		if(req.requestURL.endsWith("user/profile"))
		{
			req.headers["Authorization"] = "bearer "~access_token;
		}
	};

	return res;
}
