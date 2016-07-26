*! mp_coreversions v0.2.0 14april2016
program mp_coreversions

	* define version *
	version 13.0

	* define syntax *
	syntax [, APIkey(string)]
	
	* call coreversions function *
	mata coreversions("`apikey'")
	
end
