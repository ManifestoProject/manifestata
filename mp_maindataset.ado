*! mp_maindataset v0.4.0 03october2016
program mp_maindataset
	
	* define version *
	version 14.0
		
	* define syntax *	
	syntax [, CLEAR VERsion(string) APIkey(string) noCACHE JSON]
	
	* call maindataset function *
	mata maindataset("`clear'","`version'","`apikey'","`cache'","`json'")

end
