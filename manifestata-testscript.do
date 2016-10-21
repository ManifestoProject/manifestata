capture log close
log using test_output.smcl, replace smcl
set more off
set linesize 255

*** check functions ***
	
	* check setapikey *
	capture noisily mp_setapikey, api
	* -> OK: error -> option api incorrectly specified
	
	capture noisily mp_setapikey using api_key.txt, api(ffkhsfksdh)
	* -> OK: error -> Option apikey() not allowed. Please specify either an API Key file or use the API Key option.
	
	mp_setapikey using manifesto_apikey.txt
	* -> OK: works
	
	mp_setapikey, api(1212386318)
	* -> OK: works
	
	mp_setapikey, apikey(121238asdas6318)
	* -> OK: works
	
	mp_setapikey using manifesto_apikey.txt
	* -> OK: works
	
	
	* check coreversions *
	mp_coreversions
	* -> OK: works

	capture noisily mp_coreversions, api(1212386318)
	* -> OK: error -> authorization required by server

	mp_setapikey using manifesto_apikey.txt
	* -> OK: works
	
	* check corpusversions *
	mp_corpusversions
	* -> OK: works	
	
	*mp_corpusversions, dev (commented out, otherwise every dev version will break building manifestata)
	* -> OK: works	
	
	* check cite *
	capture noisily mp_cite
	* -> OK: error -> Please specify either a corpus or a core version for which citation should be printed.
	
	mp_cite, corpus(2016-2)
	* -> OK: works
	
	mp_cite, core(MPDS2014a)
	* -> OK: works
	
	foreach version in MPDS2012a MPDS2012b MPDS2013a MPDS2013b MPDS2014a MPDS2014b MPDS2015a MPDS2016a {
		mp_cite, core(`version')
	}
	* -> OK: works
	
	foreach version in 2016-4 2016-3 2016-2 2016-1 2015-5 2015-4 2015-3 2015-2 2015-1  {
		mp_cite, corpus(`version')
	}	
	* -> OK: works
	
	
	* check maindataset *
	* mp_maindataset, clear json

	mp_maindataset, clear
	* -> OK: works

	foreach version in MPDS2012a MPDS2012b MPDS2013a MPDS2013b MPDS2014a MPDS2014b MPDS2015a MPDS2016a {
		mp_maindataset, clear version(`version')
		d,s
		notes
	}
	* -> OK

	* in Cache?
	foreach version in MPDS2012a MPDS2012b MPDS2013a MPDS2013b MPDS2014a MPDS2014b MPDS2015a MPDS2016a {
		mp_maindataset, clear version(`version')
		d,s
		notes
	}
	* -> OK

	* no-Cache option?
	foreach version in MPDS2012a MPDS2012b MPDS2013a MPDS2013b MPDS2014a MPDS2014b MPDS2015a MPDS2016a {
		mp_maindataset, clear version(`version') nocache
		d,s
	}
	* -> OK
	
	* saving, clear and then load cache
	mp_savecache using allmaindatasets, replace
	mp_clearcache
	
	mp_setapikey using manifesto_apikey.txt
	mp_maindataset, clear version(MPDS2014a)
	list party date rile in 1/5
	* -> OK: From API
	mp_maindataset, clear 
	* -> OK: From API
	
	mp_opencache using allmaindatasets
	mp_maindataset, clear version(MPDS2014a)
	list party date rile in 1/5
	* -> OK: From cache
	mp_maindataset, clear 
	* -> OK: From cache
		
		
	* check metadata *
	*use "U:\projects\manifestata\data\MPDS_2015a.dta", clear
	*levelsof country, local(countries)
	*foreach country in `countries' {
	*	mp_metadata if country == `country'
	*}	
	* -> OK: works
	
	foreach version in 2016-4 2016-3 2016-2 2016-1 2015-5 2015-4 2015-3 2015-2 2015-1  {
		mp_metadata if country == 41

	}
	* -> OK: works
	
	foreach country in `countries' {
		mp_metadata if country == `country'
	}	
	
	* -> OK: works
	
	mp_metadata if country == 33, saving("metadata.dta", replace)
	
	erase "metadata.dta"	
	* -> OK: works

	mp_metadata 11220_201009 11320_201009 41320_200909 41320_200509
	* -> OK: works
	
	mp_metadata if country == 11
	* -> OK: works
	
	mp_metadata if country == 41, saving("metadata_ger.dta", replace)
	use "metadata_ger.dta", clear
	erase "metadata_ger.dta"
	* -> OK: works
	
	mp_metadata 13320 235343 
	* -> OK: works
	
	mp_metadata 13320 11220_201009 11320_201009 235343 41320_200909 41320_200509
	* -> OK: works
		
	
	* check corpus *
	mp_corpus if party==42110 & date>199501 , clear
	list * in 1/5
	
	capture noisily mp_corpus if party==42110 & date>199501	
	* -> OK: error -> no; data in memory would be lost
	
	mp_corpus 41320_200909 41320_200509, clear
	* -> OK: works
	
	* in Cache?
	mp_corpus if party == 41320, clear
	list * in 1/5
	* -> OK: works
	
	* no-Cache option?
	mp_corpus if party == 41320, clear nocache
	* -> OK: works	

	* saving, clear and then load cache
	mp_savecache using mycorpus, replace
	mp_clearcache
	
	mp_setapikey using manifesto_apikey.txt
	mp_corpus if party == 41320, clear
	* -> OK: From API

	mp_opencache using mycorpus
	mp_corpus if party == 41320, clear
	* -> OK: From cache
	
	* version option
	mp_clearcache
	mp_setapikey using manifesto_apikey.txt	
	foreach version in 2016-4 2016-3 2016-2 2016-1 2015-5 2015-4 2015-3 2015-2 2015-1  {
		mp_corpus if party == 41320, version(`version') clear
	}
	* -> OK: From API
	
	mp_corpus if party == 41320, clear

	mp_setapikey using manifesto_apikey.txt	
	foreach version in 2016-4 2016-3 2016-2 2016-1 2015-5 2015-4 2015-3 2015-2 2015-1  {
		mp_corpus if party == 41320, version(`version') clear
		list content cmp_code in 1/5
	}
	
	mp_corpus if party == 41320, clear
	* -> OK: From cache
	
	capture log close

exit, clear

** end


