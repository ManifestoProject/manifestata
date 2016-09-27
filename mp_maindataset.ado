*! mp_maindataset v0.3.0 11june2016
program mp_maindataset
	
	* define version *
	version 13.0
		
	* define syntax *	
	syntax [, CLEAR VERsion(string) APIkey(string) noCACHE JSON]
	
	* call maindataset function *
	mata maindataset("`clear'","`version'","`apikey'","`cache'","`json'")

end
