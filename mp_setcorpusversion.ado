*! mp_setapikey v0.1.0 03october2016
program mp_setcorpusversion
	
	* define version *
	version 14.0
	
	* define syntax *
	syntax anything(name=version id="corpus version")
	
	* call setcorpusversion function *
	mata setcorpusversion("`version'")
	
end
