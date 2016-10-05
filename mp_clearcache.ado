*! mp_cite v0.1.0 03october2016
program mp_clearcache

	* define version *
	version 14.0
	
	* define syntax *
	syntax [, KEEP(string)]
	
	* call cite function *
	mata clearcache("`keep'")
	
end
