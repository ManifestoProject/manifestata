log using test_output.txt, replace text
set more off

*** manifestata test script

mp_setapikey using "manifesto_apikey.txt"

mp_coreversions

** most recent
clear 
mp_maindataset


** specific version
mp_maindataset, clear version(MPDS2014b) 

clear

** should get the cached version
mp_maindataset, version(MPDS2014b) 

** should again get the uncached version
mp_maindataset, version(MPDS2014b) nocache clear

** 
mp_corpusversions
mp_corpusversions, dev


*** metadata
mp_metadata 41320_200509 41320_200909

mp_metadata if party==41111
mp_metadata if datasetorigin==90

*** save metadata
mp_metadata 41320_200509, saving(greens1, replace)
mp_metadata if party==41111, saving("greens", replace) 
mp_metadata if countryname == "France", saving(france, replace)


*** mp corpus
mp_corpus 41320_200909, clear

*mp_corpus if country == 41 // if clear is not specified he first checks for all data, then downloads the relevant data and then realizes that there is still data in memory and it is not cleared. would be better if check whether memory is clear came before contacting the api?
mp_corpus if country == 41, clear

tab cmp_code


*** mp cite
mp_cite,core(MPDS2016a) corpus(2016-2)
mp_cite,core(MPDS2015a) 
mp_cite, corpus(20160205171117) /// I think we have not thought about how dev versions should be cited...


exit, clear

** end

