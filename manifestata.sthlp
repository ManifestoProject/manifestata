{smcl}
{* *! version 0.4.0 October 21th 2016}{...}
{cmd: help manifestata}
{hline}

{title:Title}

{pstd}
{bf:manifestata} {hline 2} access and process data and documents of the Manifesto Project.


{title:Description}

{pstd}
manifestata provides access to data and documents of the Manifesto Project. 
The Manifesto Project analyses parties’ election programs in order to study parties’ policy preferences.
manifestata connects to the Manifesto API which distributes the Manifesto Project's Main Dataset and the Manifesto Corpus.
Check out the Manifesto Project's {browse "https://manifesto-project.wzb.eu/":website} for more information 
on data collection and coding and to generate an API-key. 

{pstd}
An API key is required to be able to use manifestata. In order to get one, create a 
profile on the Manifesto Project's website, go to your profile page, and generate an API-key.


{title:General Overview}

{col 5}{help manifestata##1 :Commands for controlling the API key}
{col 5}{help manifestata##2 :Commands for accessing the Manifesto Project Main Dataset}
{col 5}{help manifestata##3 :Commands for accessing the Manifesto Corpus}
{col 5}{help manifestata##4 :Commands for controlling the local cache}
{col 5}{help manifestata##5 :Miscellaneous commands}
{col 5}{help manifestata##6 :Exemplary workflow}

{marker 1}
   {c TLC}{hline 38}{c TRC}
{hline 3}{c RT}{it: Commands for controlling the API key }{c LT}{hline}
   {c BLC}{hline 38}{c BRC}

{cmd:{dlgtab:mp_setapikey}}
 
{col 5}{title:Syntax} 
{pstd}{cmd:mp_setapikey} using {it:{help filename}.txt}{cmd:} [{cmd:,}  {cmdab:api:key(}{it:string}{cmd:)}]

{col 5}{title:Description} 
{pstd}If you do not have an API key for the Manifesto API, you can create one via your
profile page on {browse "https://manifesto-project.wzb.eu"}. If you do not have an account, you can
register for free on the webpage.

{col 5}{title:Options} 
{pstd}{cmdab:apikey(}{it:string}{cmd:)} specifies the API key to use for this command.

{col 5}{title:Remarks} 

{col 5}{title:Examples} 
{col 5}{cmd:. mp_setapikey using "C:\mymanifestofolder\manifesto_apikey.txt"} 
{col 5}{cmd:. mp_setapikey, apikey({it:myapikey1234})} 

 {marker 2}  
   {c TLC}{hline 58}{c TRC}
{hline 3}{c RT}{it: Commands for accessing the Manifesto Project Main Dataset}{c LT}{hline}
   {c BLC}{hline 58}{c BRC}
 
{cmd:{dlgtab:mp_coreversions}}

{col 5}{title:Syntax} 
{pstd}{cmd:mp_coreversions} [{cmd:,}  {cmdab:api:key(}{it:string}{cmd:)}]

{col 5}{title:Description} 
{pstd}List the available versions of the Manifesto Project's Main Dataset.

{col 5}{title:Options} 
{pstd}{cmdab:apikey(}{it:string}{cmd:)} specifies the API key to use for this command.

{col 5}{title:Remarks} 

{col 5}{title:Examples}
{col 5}{cmd:. mp_coreversions}
{col 5}{cmd:. mp_coreversions, apikey({it:myapikey1234})} 


{cmd:{dlgtab:mp_maindataset}}

{col 5}{title:Syntax} 
{pstd}{cmd:mp_maindataset} [{cmd:,}  {cmdab:clear} {cmdab:ver:sion(}{it:string}{cmd:)} {cmdab:api:key(}{it:string}{cmd:)} {cmdab:nocache} {cmdab:json}]

{col 5}{title:Description} 
{pstd}Gets the Manifesto Project's Main Dataset from the project's web API or the local cache, if it was already downloaded before.

{col 5}{title:Options} 
{pstd}{cmdab:clear} specifies that it is okay to replace the data in memory, even though the current data have not been saved to disk.

{pstd}{cmdab:version(}{it:string}{cmd:)} specifies the version of the dataset you want to access. 
Use mp_coreversions for a list of available versions. If not specified, the most recent data set is obtained.

{pstd}{cmdab:apikey(}{it:string}{cmd:)} specifies the API key to use for this command.

{pstd}{cmdab:nocache} specifies not to use data from the local cache.

{pstd}{cmdab:json} non-documented option retrieving data via JSON (to be removed).

{col 5}{title:Remarks} 

{col 5}{title:Examples}
{col 5}{cmd:. mp_maindataset, clear}
{col 5}{cmd:. mp_maindataset, version(MPDS2015a) apikey({it:myapikey1234})}   
{col 5}{cmd:. mp_maindataset, version(MPDS2014b) nocache}

{marker 3}
   {c TLC}{hline 45}{c TRC}
{hline 3}{c RT}{it: Commands for accessing the Manifesto Corpus }{c LT}{hline}
   {c BLC}{hline 45}{c BRC}
   
{cmd:{dlgtab:mp_corpusversions}}

{col 5}{title:Syntax} 
{pstd}{cmd:mp_corpusversions} [{cmd:,}  {cmdab:api:key(}{it:string}{cmd:)} {cmdab:dev:elopment}]

{col 5}{title:Description} 
{pstd}The Manifesto Project Database API assigns a new version code whenever changes to the corpus texts or metadata are made.

{col 5}{title:Options} 
{pstd}{cmdab:apikey(}{it:string}{cmd:)} specifies the API key to use for this command.

{pstd}{cmdab:development} lists all development versions.

{col 5}{title:Remarks} 

{col 5}{title:Examples}
{col 5}{cmd:. mp_corpusversions}
{col 5}{cmd:. mp_corpusversions, apikey({it:myapikey1234})}   


{cmd:{dlgtab:mp_setcorpusversion}}

{col 5}{title:Syntax} 
{pstd}{cmd:mp_setcorpusversion} {it:versionid}

{col 5}{title:Description} 
{pstd}The local cache will be updated to the specified version and all future calls to the API will request for the specified version. 
Note that this versioning applies to the corpus' texts and metadata, and not the versions of the core dataset.

{col 5}{title:Remarks} 

{col 5}{title:Examples}
{col 5}{cmd:. mp_setcorpusversion 2015-4}   


{cmd:{dlgtab:mp_metadata}}

{col 5}{title:Syntax} 

{col 5}Access metadata via {it:idlist}:

{pstd}{cmd:mp_metadata} {it:idlist} [{cmd:, }{cmdab:ver:sion(}{it:string}{cmd:)} {cmdab:api:key(}{it:string}{cmd:)} {cmdab:sav:ing(}{it:{help filename}.dta}{cmd:[, replace])}]

{pstd} where {it:idlist} is a list of parties (as five-digit ids) and dates (as six-digit dates [yyyymm]), paired by an underscore character (see examples below).


{col 5}Access metadata via {it:{help if}}-qualifier:

{pstd}{cmd:mp_metadata} {it:{help if} exp} [{cmd:, }{cmdab:ver:sion(}{it:string}{cmd:)} {cmdab:api:key(}{it:string}{cmd:)} {cmdab:sav:ing(}{it:{help filename}.dta}{cmd:[, replace])}]

{pstd} where {it:exp} is an expression, such as country == 41 (see examples below).

{col 5}{title:Description} 
{pstd}Meta data contain information on the available documents for a given party and election date. 
This information comprises links to the text as well as original documents if available, language, versions checksums and more.

{col 5}{title:Options} 
{pstd}{cmdab:version(}{it:string}{cmd:)} specifies the version of the corpus you want to access. 
Use mp_corpusversions for a list of available versions. If not specified, the most recent data set is obtained.

{pstd}{cmdab:apikey(}{it:string}{cmd:)} specifies the API key to use for this command.

{pstd}{cmdab:saving} stores the metadata in {it:{help filename}.dta}. Specify the suboption {cmd:replace} to overwrite the existing dataset.

{col 5}{title:Remarks} 

{col 5}{title:Examples}
{col 5}{cmd:. mp_metadata 41320_200509 41320_200909}
{col 5}{cmd:. mp_metadata 41320_200509, apikey({it:myapikey1234})}    
{col 5}{cmd:. mp_metadata if country == 11 & date > 199900}    
{col 5}{cmd:. mp_metadata if country == 41, version (2016-3) saving("mymetadata.dta", replace)}

  
{cmd:{dlgtab:mp_corpus}}

{col 5}{title:Syntax} 

{col 5}Access corpus data via {it:idlist}:

{pstd}{cmd:mp_corpus} {it:idlist} [{cmd:, }{cmdab:clear} {cmdab:ver:sion(}{it:string}{cmd:)} {cmdab:api:key(}{it:string}{cmd:)} {cmdab:nocache}]

{pstd} where {it:idlist} is a list of partys (as five-digit ids) and dates (as six-digit dates [yyyymm]), paired by an underscore character (see examples below).


{col 5}Access corpus data via {it:{help if}}-qualifier:

{pstd}{cmd:mp_corpus} {it:{help if} exp} [{cmd:, }{cmdab:clear} {cmdab:ver:sion(}{it:string}{cmd:)} {cmdab:api:key(}{it:string}{cmd:)} {cmdab:nocache}]

{pstd} where {it:exp} is an expression, such as party == 41320 & date > 200000 (see examples below).

{col 5}{title:Description} 
{pstd}Documents are downloaded from the Manifesto Project Corpus Database. 
If CMP coding annotations are available, they are attached to the documents, otherwise raw texts are provided. The documents are cached in the working memory to ensure internal consistency, enable offline use and reduce online traffic.

{col 5}{title:Options} 
{pstd}{cmdab:clear} specifies that it is okay to replace the data in memory, even though the current data have not been saved to disk.

{pstd}{cmdab:version(}{it:string}{cmd:)} specifies the version of the corpus you want to access. 
Use mp_corpusversions for a list of available versions. If not specified, the most recent data set is obtained.

{pstd}{cmdab:apikey(}{it:string}{cmd:)} specifies the API key to use for this command.

{pstd}{cmdab:nocache} specifies not to use data from the local cache.

{col 5}{title:Remarks} 

{col 5}{title:Examples}
{col 5}{cmd:. mp_corpus 41320_200909, clear}
{col 5}{cmd:. mp_corpus 41320_200909, apikey({it:myapikey1234})}  
{col 5}{cmd:. mp_corpus if party == 41320 & date > 200000}    
{col 5}{cmd:. mp_corpus 41320_200909, clear version(2015-3)}  

{marker 4}
   {c TLC}{hline 42}{c TRC}
{hline 3}{c RT}{it: Commands for controlling the local cache }{c LT}{hline}
   {c BLC}{hline 42}{c BRC}  

{cmd:{dlgtab:mp_clearcache}}

{col 5}{title:Syntax} 
{pstd}{cmd:mp_clearcache}

{col 5}{title:Description} 
{pstd}Empty the local cache.


{cmd:{dlgtab:mp_savecache}}

{col 5}{title:Syntax} 
{pstd}{cmd:mp_savecache} using {it:{help filename}}{cmd:} [{cmd:,}  {cmdab:replace}]

{col 5}{title:Description} 
{pstd}Saves local cache to the file system. 
This function can and should be used to store downloaded snapshots of the Manifesto Project Corpus Database to your local hard drive. 
They can then be loaded via mp_opencache. 
Caching data in the file system ensures reproducibility of the scripts and analyses, enables offline use of the data and reduces unnecessary traffic and waiting times.

{col 5}{title:Options} 
{pstd}{cmdab:replace} specifies that it is okay to replace the data in memory, even though the current data have not been saved to disk. 

{col 5}{title:Remarks} 

{col 5}{title:Examples}  
{col 5}{cmd:. mp_savecache using mycache, replace}    


{cmd:{dlgtab:mp_opencache}}

{col 5}{title:Syntax} 
{pstd}{cmd:mp_opencache} using {it:{help filename}}{cmd:} [{cmd:,}  {cmdab:clear}]

{col 5}{title:Description} 
{pstd}Loads local cache from a file on your local harddrive.

{col 5}{title:Options} 
{pstd}{cmdab:clear} specifies that it is okay to replace the data in memory, even though the current data have not been saved to disk.

{col 5}{title:Remarks} 

{col 5}{title:Examples}  
{col 5}{cmd:. mp_opencache using mycache, clear}   


{marker 5}
   {c TLC}{hline 24}{c TRC}
{hline 3}{c RT}{it: Miscellaneous commands }{c LT}{hline}
   {c BLC}{hline 24}{c BRC}
  
{cmd:{dlgtab:mp_cite}}
   
{col 5}{title:Syntax} 
{pstd}{cmd:mp_cite} [{cmd:, }{cmdab:corp:us(}{it:string}{cmd:)} {cmdab:core(}{it:string}{cmd:)} {cmdab:api:key(}{it:string}{cmd:)}]

{col 5}{title:Description} 
{pstd}Print Manifesto Corpus citation information.

{col 5}{title:Options} 
{pstd}{cmdab:corpus(}{it:string}{cmd:)} corpus version for which citation should be printed.

{pstd}{cmdab:core(}{it:string}{cmd:)} core version for which citation should be printed.

{pstd}{cmdab:apikey(}{it:string}{cmd:)} specifies the API key to use for this command.

{col 5}{title:Remarks} 

{col 5}{title:Examples}
{col 5}{cmd:. mp_cite, corpus(2015-3) apikey({it:myapikey1234})}
{col 5}{cmd:. mp_cite, core(MPDS2015a)}       


{cmd:{dlgtab:mp_view_originals}}
   
{col 5}{title:Syntax} 

{col 5}Open original documents via {it:idlist}:

{pstd}{cmd:mp_view_originals } {it:idlist }[{cmd:, }{cmdab:api:key(}{it:string}{cmd:)}]


{col 5}Open original documents via {it:{help if}}-qualifier:

{pstd}{cmd:mp_view_originals } {it:{help if} exp}[{cmd:, }{cmdab:api:key(}{it:string}{cmd:)}]

{pstd} where {it:exp} is an expression, such as country == 41 & date == 201309 (see examples below).

{col 5}{title:Description} 
{pstd}Original documents are opened in the system's browser window. 
All original documents are stored on the Manifesto Project Website and the URLs opened are all from this site.

{col 5}{title:Options} 
{pstd}{cmdab:apikey(}{it:string}{cmd:)} specifies the API key to use for this command.

{col 5}{title:Remarks} 

{col 5}{title:Examples} 
{col 5}{cmd:. mp_view_originals 41320_200909}
{col 5}{cmd:. mp_view_originals 41320_200909, apikey({it:myapikey1234})} 
{col 5}{cmd:. mp_view_originals if country == 41 & date == 201309} 

{marker 6}
   {c TLC}{hline 20}{c TRC}
{hline 3}{c RT}{it: Exemplary workflow }{c LT}{hline}
   {c BLC}{hline 20}{c BRC}

{it:{dlgtab:1. Connecting to the Manifesto Project Database API}}

{p 4 4 2} 
To access the data in the Manifesto Corpus, an account for the Manifesto Project webpage with an API key is required. 
If you do not yet have an account, you can create one at {browse "https://manifesto-project.wzb.eu/signup"}. 
If you have an account, you can create and download the API key on your profile page.
For every Stata session using manifestata and connecting to the Manifesto Corpus database, you need to set the API key in your work environment. 
This can be done by passing either a key or the name of a file containing the key using manifestata's {cmd:mp_setapikey} command. 
Thus, your Stata Do-File using manifestata usually will start like this: 

{p 4 4 2} 
{cmd:. mp_setapikey using "manifesto_apikey.txt"}

{p 4 4 2}
This Stata code presumes that you have stored and downloaded the API key in a file name manifesto_apikey.txt in your current Stata working directory. Note that it is a security risk to store the API key file or a script containing the key in public repositories.


{it:{dlgtab:2. Downloading the Manifesto Project Dataset}}

{p 4 4 2}
You can download the Manifesto Project Dataset (MPDS) using the {cmd:mp_maindataset} command. 
By default the most recent update is returned, but you can specify older versions to get for reproducibility (use the {cmd:mp_coreversions} command for a list of versions). 


{it:{dlgtab:3. Downloading documents}}

{p 4 4 2}
Before downloading documents you may want to get meta data for the respective election programmes first. 
To obtain the metadata for the manifestos of the German SPD and FDP in 2009, type:

{p 4 4 2} 
{cmd:. mp_metadata 41320_200909 41420_200909} or alternatively {cmd: mp_metadata if inlist(party,41320,41420) & date == 200909}

{p 4 4 2}
(Bulk-)Downloading documents works using the {cmd:mp_corpus} command. To get the manifestos of the German SPD and FDP in 2013, type:

{p 4 4 2} 
{cmd:. mp_corpus 41320_201309 41420_201309} or alternatively {cmd: mp_corpus if inlist(party,41320,41420) & date == 201309}

{p 4 4 2}
The {cmd:mp_corpus} command returns a data set containing all the requested manifestos. The party ids (41320 and 41420 in the example) are the ids as in the Manifesto Project's main dataset. They can be found in the current dataset documentation at {browse "https://manifesto-project.wzb.eu/datasets"} or in the main dataset.


{it:{dlgtab:4 Viewing original documents}}

{p 4 4 2}
Apart from the machine-readable, annotated documents, the Manifesto Corpus also contains original layouted election programmes in PDF format. 
If available, they can be viewed via the function mp_view_originals, which takes exactly the format of arguments as mp_corpus (see above), e.g.:

{p 4 4 2} 
{cmd:. mp_view_originals 41320_201309 41420_201309}

{p 4 4 2}
The original documents are shown in you system's web browser. All URLs opened by this function refer only to the Manifesto Project's Website.

{title:Author and Citation}

{col 5} Alejandro Ecker, University of Mannheim, alejandro.ecker@mzes.uni-mannheim.de (author, creator)
{col 5} Nicolas Merz, WZB Berlin Social Science Center, {browse "mailto:nicolas.merz@wzb.eu":nicolas.merz@wzb.eu} (maintainer, contributor)
{col 5} Jirka Lewandowski, WZB Berlin Social Science Center, jirka.lewandowski@wzb.eu (contributor)
{col 5} Sven Regel, WZB Berlin Social Science Center, sven.regel@wzb.eu (contributor)

{pstd}
When using the package please cite as:

{pstd}
Ecker, Alejandro / Merz, Nicolas / Lewandowski, Jirka / Regel, Sven (2016): manifestata. 
A stata package to access the Manifesto Project's API. {browse "https://manifesto-project.wzb.eu/manifestata":https://manifesto-project.wzb.eu/manifestata }

{pstd}
When using the Manifesto Project Main dataset and the Manifesto Corpus, please use the function mp_cite to get the correct citation.
