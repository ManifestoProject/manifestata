log using test_output.txt, replace text
set more off

*** manifestata test script
clear 
capture log using "testlog", replace

mp_clearcache

*** mp_setapikey

* correct key from file
mp_setapikey using "manifesto_apikey.txt"
mp_coreversions

* set wrong key 
mp_setapikey, key(123456)
* should output message that key is wrong
mp_coreversions


**** mp_maindataset

clear 
mp_setapikey using "manifesto_apikey.txt"

* most recent * 
mp_maindataset
distinct

* get specific version version
mp_maindataset, clear version(MPDS2014b) 
distinct party

* should produce error as not cleared
mp_maindataset, version(MPDS2014a)
clear
mp_maindataset, version(MPDS2013a) // should put this into cache
clear

** should get the cached version
mp_maindataset, version(MPDS2013b) 

** should again get the uncached version
mp_maindataset, version(MPDS2014b) nocache clear


**** mp_corpusversions 
mp_corpusversions
* mp_corpusversions, dev
* commented, otherwise we would have to adopt this for every development version of the corpus. 


*** mp_metadata
mp_metadata 41113_200909, version(2016-1)
mp_metadata 41320_200509 41320_200909, version(2016-5)
mp_metadata 41320_200509 41320_200909 

mp_metadata if party==41111 | party == 41112 | party == 41113
mp_metadata if datasetorigin==90

*** save metadata
mp_metadata 41320_200509, saving(greens1, replace)
mp_metadata if party==41111, saving("greens", replace) 
mp_metadata if countryname == "France", saving(france, replace)


*** mp corpus
mp_corpus 41320_200909, clear version(2016-3)
clear
mp_corpus 41320_200909, clear version(2016-3)

mp_setcorpusversion 2015-4

mp_corpus 41320_200909, clear

mp_corpus if country == 41, clear

tab cmp_code


*** test caching functions
mp_clearcache
mp_setapikey using "manifesto_apikey.txt"
mp_corpus if country == 41, clear
mp_savecache using cache-saved.dta, replace
clear
mp_clearcache
mp_opencache using cache-saved.dta, clear



*** mp cite
mp_cite,core(MPDS2016a) corpus(2016-2)
mp_cite,core(MPDS2015a) 
mp_cite, corpus(20160205171117) /// I think we have not thought about how dev versions should be cited...


exit, clear

** end

