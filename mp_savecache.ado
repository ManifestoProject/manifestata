*! mp_setapikey v0.1.0 03october2016
program mp_savecache
	
	* define version *
	version 14.0
	
	* define syntax *
	syntax using/ [, REPLACE]
		
	* call setapikey function *
	mata savecache("`using'", "`replace'")
	
end
