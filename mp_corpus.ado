*! mp_corpus v0.3.7 12september2016
program mp_corpus
	
	* define version *
	version 13.0
	
	* define syntax for ID list*	
	capture syntax anything(name=idlist id="ID list") [, CLEAR APIkey(string) noCACHE]
	
	* call maindataset function *
	if !_rc {
		mata corpus("`idlist'","`clear'","`apikey'","`cache'")
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
		capture syntax if [, CLEAR APIkey(string) noCACHE]

		* select subset specified by if-qualifier *
		marksample touse
		mata selectsubset("`touse'")

		* restore current data set *
		restore
		
		* call corpus function *
		mata corpus("`idlist'","`clear'","`apikey'","`cache'")
	}
	
	* ID list and if-qualifier not specified *	
	if _rc {
		di "{err}Please specify an ID list or use the if-qualifier."
		exit 197
	}
	
	* tostring variables cmp-code and eu-code in line with handbook version 5
	mata tostring_v5("cmp_code eu_code")

end
