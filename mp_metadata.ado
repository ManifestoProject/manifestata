*! mp_metadata v0.5.2 12september2016
program mp_metadata
	
	* define version *
	version 13.0
	
	* define syntax for ID list*	
	capture syntax anything(name=idlist id="ID list") [, APIkey(string) SAVing(string asis) noCACHE]
	
	* call metadata function *
	if !_rc {
		mata metadata("`idlist'","`apikey'",`"`saving'"',"`cache'")
	}
	
	* define syntax for if-qualifier *
	if _rc {
		
		* preserve current data set *
		preserve
		
		* parse API key *
		local apikey_com = substr("`0'",strpos("`0'","api"),.)	
		local apikey_com = substr("`apikey_com'",1+strpos("`apikey_com'","("),strpos("`apikey_com'",")")-strpos("`apikey_com'","(")-1)
		
		* load cached data set *
		quietly {
			mata maindataset("clear","","`apikey_com'","","")
		}		
		
		* define syntax *
		capture syntax if [, APIkey(string) SAVing(string asis) noCACHE]

		* select subset specified by if-qualifier *
		marksample touse
		mata selectsubset("`touse'")

		* restore current data set *
		restore
		
		* call metadata function *
		mata metadata("`idlist'","`apikey'",`"`saving'"',"`cache'")

		* restore current data set *
		* restore
	}
	
	* ID list and if-qualifier not specified *	
	if _rc {
		di "{err}Please specify an ID list or use the if-qualifier."
		exit 197
	}

end
