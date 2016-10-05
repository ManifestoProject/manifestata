*! mp_coreversions v0.3.0 03october2016
program mp_coreversions

	* define version *
	version 14.0

	* define syntax *
	syntax [, APIkey(string)]
	
	* call coreversions function *
	mata coreversions("`apikey'")
	
end
