package br.com.stimuli.loading.utils {
    public class SmartURL  {
		public var rawString : String;
		public var protocol : String;
		public var port : int;
		public var host : String;
		public var path : String;
		public var queryString : String;
		public var queryObject : Object;
		public var queryLength : int = 0;
		public function SmartURL(rawString : String){
			this.rawString = rawString;
			// 
			var URL_RE : RegExp = /((?P<protocol>[a-zA-Z]+: \/\/)   (?P<host>[^:\/]*) (:(?P<port>\d+))?)?  (?P<path>[^?]*)? ((?P<query>.*))? /x; 
			//                   /((?P<protocol>[^\:]+:\/\/)?(?P<host>[^\/]+)?)?(?P<path>\/[^?]*)(?P<query>.*)?/ig; 
			var match : * = URL_RE.exec(rawString);
            /*for (var prop : String in match){
                if (int(prop) == 0)trace('\t', prop + ": " + match[prop])
            }*/
			if (match){
				protocol = Boolean(match.protocol) ? match.protocol : "http://";
				protocol = protocol.substr(0, protocol.indexOf("://"));
				host = match.host || null;
				port = match.port ? int(match.port) : 80;
				path = match.path;
				queryString = match.query;
				//print( queryString, type );
				if (queryString){
					queryObject = {};
					queryString = queryString.substr(1);
					var value : String;
					var varName : String;
					for each (var pair : String in queryString.split("&")){
						varName = pair.split("=")[0];
						value = pair.split("=")[1];
						queryObject[varName] = value;
						queryLength ++;
					}
				}
			}else{
				trace("no match")
			}
 			
			/**/
		}
		
		
		public function toString(...rest) : String{
			if (rest.length > 0 && rest[0] == true){
				return "[URL] rawString :" + rawString + ", protocol: " + protocol + ", port: " + port + ", host: " + host + ", path: " + path + ". queryLength: "  + queryLength;
			}
			return rawString;
		}
	}
}
