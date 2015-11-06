# manifestata

manifestata ~is~ will be a Stata package that provides access to and facilitates the work with the Manifesto Project Dataset and the Manifesto Corpus. 
It is the Stata equivalent to the R package manifestoR (https://cran.r-project.org/web/packages/manifestoR/index.html and https://github.com/ManifestoProject/manifestoR ).

Desired functionality:

API related functions:
- Stata support for all functions of the Manifesto Project API: https://manifesto-project.wzb.eu/information/documents/api
- for examples, request available data, request main dataset, request (subsets of) corpus
- a user-friendly way to store the api key
- caching function for downloaded data to avoid too much traffic on the server (similar to the one implemented in manifestoR)
- show citation information and corpus version (from api when connecting to api)
- ensure correct encoding of downloaded data

Functions applied to downloaded data:
- recoding function from handbook v5 to v4.
- code counting function
- scaling functions: rile, logratio-scaling, vanilla-scaling, bipolar scaling(kim-fording), franzmann-kaiser (functions for corpus and dataset) 
- more scaling functions: measure of issue attention diversity by Green, niche party measures by (1) bischof, (2) meyer-miller and (3) wagner (do-files available, but rewriting required)
- uncertainty estimates by mcDonald and budge (do-files already exists - no equivalent in manifestoR)
- bootstrapped confidence intervals / uncertainty estimates by benoit, laver & mikhaylov (no do file yet)

Export Functions:
- export functions of all data to xls and csv

manifestata and manifestoR:
- the possibility to call manifestoR from stata (see eg. https://statlore.wordpress.com/2013/01/21/how-to-call-r-from-stata/ )

General:
- clear and meaningful error messages for potential errors 
- detailed comments in all parts of the code 
- support of stata 13 and higher (below might be difficult because stata 12- cannot handle unicode)
- all files necessary to install the package from the web (see help usersite)
- development of the software with git to ensure and facilitate transparency of the development and further development at a later point
- a collection of scripts that tests every major function of the package and (if possible) compares the results (eg. for scaling functions) with predefined results 

Documentation:
- detailed documentation with examples in stata format of all functions: execute "help examplehelpfile" in stata for an example
- a brief manual that describes the use of the package in Latex. This could also be or become a Stata Journal article. 



Helpful:
Stata package to read JSON data: https://ideas.repec.org/c/boc/bocode/s457407.html