*! mp_corpusversions v0.3.2 17august2016
program mp_corpusversions

	* define version *
	version 13.0
	
	* define syntax *
	syntax [, APIkey(string) DEVelopment]

	* call corpusversions function *
	mata corpusversions("`apikey'","`development'")
	
end
