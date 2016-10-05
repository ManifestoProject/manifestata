*! mp_view_originals v0.4.0 03october2016
program mp_view_originals
	
	* define version *
	version 14.0
	
	* define syntax for ID list*	
	capture syntax anything(name=idlist id="ID list") [, APIkey(string) noCACHE]
	
	* loop over IDs
	if !_rc {
		foreach id in `idlist' {
	
			* call view_originals function *
			mata view_originals("`id'")
		
			* open browser *
			view browse `url'
		}
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
		capture syntax if [, APIkey(string) noCACHE]

		* select subset specified by if-qualifier *
		marksample touse
		mata selectsubset("`touse'")
		
		* call view_originals function *
		foreach id in `idlist' {
	
			* call view_originals function *
			local id = substr("`id'",1,strlen("`id'")-2)
			mata view_originals("`id'")
		
			* open browser *
			view browse `url'
		}		
		di "if-qualifier"

		* restore current data set *
		restore
	}

end
