*! mp_setapikey v0.1.0 03october2016
program mp_opencache
	
	* define version *
	version 14.0
	
	* define syntax *
	syntax using/ [, CLEAR]
		
	* call setapikey function *
	mata opencache("`using'", "`clear'")
	
end
