*! mp_corpusversions v0.4.0 03october2016
program mp_corpusversions

	* define version *
	version 14.0
	
	* define syntax *
	syntax [, APIkey(string) DEVelopment]

	* call corpusversions function *
	mata corpusversions("`apikey'","`development'")
	
end
