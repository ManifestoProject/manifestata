*! mp_corpusversions v0.2.0 14april2016
program mp_corpusversions

	* define version *
	version 13.0
	
	* define syntax *
	syntax [, APIkey(string)]

	* call corpusversions function *
	mata corpusversions("`apikey'")
	
end
