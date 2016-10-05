*! mp_cite v0.3.0 03october2016
program mp_cite

	* define version *
	version 14.0
	
	* define syntax *
	syntax [, CORPus(string) CORE(string) APIkey(string)]
	
	* corpus and core option not specified *
	if ("`corpus'" == "" & "`core'" == "") {
		di "{err}Please specify either a corpus or a core version for which citation should be printed."
		exit 197
	}
	
	* call cite function *
	mata cite("`corpus'","`core'","`apikey'")
	
end
