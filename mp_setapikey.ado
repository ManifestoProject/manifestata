*! mp_setapikey v0.3.0 03october2016
program mp_setapikey
	
	* define version *
	version 14.0
	
	* define syntax *
	syntax [using/] [, APIkey(string)]
	
	* using argument not specified * 
	if ("`using'" == "" & "`apikey'" == "") {
		di "{err}No API Key file specified. Please use the API Key option."
		exit 197
	}
	
	* using argument and apikey option specified * 
	if ("`using'" != "" & "`apikey'" != "") {
		di "{err}Option apikey() not allowed. Please specify either an API Key file or use the API Key option."
		exit 198
	}
	
	* call setapikey function *
	mata setapikey("`using'", "`apikey'")
	
end
