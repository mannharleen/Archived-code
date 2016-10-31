public class oauthv2Controller {
    public class fromJSON{
        public Integer last_authenticated;	//
        public String access_token;	//.
        public Integer expires_in;	//
        public String token_type;	//
        public String scope;	//profile
        public String refresh_token;	//
    }
	public class userinfo{
        public String picture;	
        public String first_name;	
        public String last_name;	
        public String uuid;	
        public String rider_id;	
        public String email;	
        public boolean mobile_verified;
        public String promo_code;	
    }
    
    public string authcode{get;set;}
    public string accesstoken{get;set;}
    public string refreshtoken{get;set;}    
    public string uname{get;set;}
    public string uemail{get;set;}
    public string upromocode{get;set;}
    
    public pagereference info() {
        
        if (accesstoken != null) {
            //call data to get data
            Integer responseStatusCode = data();
            if(responseStatusCode - (math.mod(responseStatusCode,100)) == 400) {
                if(refreshtoken != null) {
                    refreshtoken();
                    info();
                }
            }
            return null;
        } else {
            if (authcode == null) {
                //get authtoken from url
                authcode = ApexPages.currentPage().getParameters().get('code');
                if (authcode == null) {
                    pagereference p = authcode();
                    return p;
                } else {
                    info();
                }
                
            } else {
                accesstoken();
                info();
                
            }
            return null;
        }
        
    }
    public pagereference authcode() {
        system.debug('Sending Auth request..');
        pagereference p=new pagereference('https://login.uber.com/oauth/v2/authorize?client_id=<CLIENT_ID>&response_type=code&scope=profile&redirect_uri=https://<ORG_URL>.force.com/apex/oauthv2');
        return p;
    }    
    public void accesstoken() {
        Http http = new http();
        Httprequest request = new HttpRequest();
        request.setendpoint('https://login.uber.com/oauth/v2/token');
        request.setMethod('POST');
        system.debug('requesting Access token with auth code= '+authcode);
        request.setBody('client_secret=<CLIENT_SECRET>&client_id=<CLIENT_ID>&grant_type=authorization_code&redirect_uri=https://<ORG_URL>.force.com/apex/oauthv2&code='+authcode);
        Httpresponse response = http.send(request);
        system.debug('Access token response= '+response.getBody()); 
        
        fromJSON jsonapex = new fromJSON();
        jsonapex = (fromJSON) System.JSON.deserialize(response.getBody(), fromJSON.class);
        accesstoken = jsonapex.access_token;
        refreshtoken = jsonapex.refresh_token;                    
        
    }
    public void refreshtoken() {
        Http http = new http();
        Httprequest request = new HttpRequest();
        request.setendpoint('https://login.uber.com/oauth/v2/token');
        request.setMethod('POST');
        system.debug('requesting Access token with refresh token = '+refreshtoken);
        request.setBody('client_secret=<CLIENT_SECRET>&client_id=<CLIENT_ID>&grant_type=authorization_code&redirect_uri=https://<ORG_URL>.force.com/apex/oauthv2&refresh_token='+refreshtoken);
        Httpresponse response = http.send(request);
        system.debug('Access token via refresh token response= '+response.getBody()); 
        
        fromJSON jsonapex = new fromJSON();
        jsonapex = (fromJSON) System.JSON.deserialize(response.getBody(), fromJSON.class);
        accesstoken = jsonapex.access_token;
        refreshtoken = jsonapex.refresh_token;         
        
    }
    
    public Integer data() {
        Http http1 = new http();
        Httprequest request1 = new HttpRequest();
        request1.setendpoint('https://api.uber.com/v1/me');
        request1.setMethod('GET');
        request1.setHeader('Authorization', 'Bearer '+accesstoken);
        Httpresponse response1 = http1.send(request1);
        system.debug('Data response= '+response1.getBody()); 
        userinfo user = new userinfo();
        user = (userinfo) System.JSON.deserialize(response1.getBody(), userinfo.class);
        uname = user.first_name + user.last_name;
        uemail = user.email;
        upromocode = user.promo_code;
        	
        return response1.getStatusCode();
    }
    public pagereference revoke() {
        //if (accesstoken != null) {
            Http http2 = new http();
            Httprequest request2 = new HttpRequest();
            request2.setendpoint('https://login.uber.com/oauth/revoke');
            request2.setMethod('POST');
            request2.setBody('client_secret=<CLIENT_SECRET>&client_id=<CLIENT_ID>&token='+accesstoken);
            Httpresponse response2 = http2.send(request2);
            accesstoken = null;
            refreshtoken = null;
            authcode = null;
            uname = '';
            uemail = '';
            upromocode = '';        
            system.debug('Revoke response= '+response2.getBody());
            pagereference p=new pagereference('https://<ORG_URL>.force.com/apex/oauthv2');
        	return p;
        //}
    }

}//end of class
