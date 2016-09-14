mata:
mata clear

void function setapikey(string scalar apifilepath, string scalar apikey) {
	
	// API Key file specified
	if (apifilepath!="") {
		
		// API Key file not found
		if (fileexists(apifilepath) == 0) {
			message = "Your API Key file " + apifilepath + " was not found."
			_error(message)
		}
		
		// API Key file found 
		if (fileexists(apifilepath) == 1) {
			filehandle = fopen(apifilepath, "r")
			api = fget(filehandle)
			fclose(filehandle)
		}
	}
	
	// API Key option specified
	if (apikey!="") {
		api = apikey
	}
	
	// define pointer 
	pointer() scalar p_api
	
	// API Key not set
	if ((p_api = findexternal("myapi")) == NULL) {
		p_api = crexternal("myapi")
		message = ("The API Key was not set." \ "The new API Key is:" + " " + api)
		display(message)
	}
	
	// API Key set
	else {
		message = ("The API Key was set to:" + " " + *p_api \ "The new API Key is:" + " " + api)
		display(message)
    }
	
	// set pointer 
	*p_api = api

}

void function coreversions(string scalar apikey, | string scalar noresponse) {
	
	// API Key option not specified
	if (apikey == "") {
		
		// define pointer
		pointer() scalar p_api
		
		// API Key not set
		if ((p_api = findexternal("myapi")) == NULL) {
			message = ("API Key not set. Please use the API Key option or the setapikey command.")
			display(message)
		}
		
		// API Key set
		else {
			p_api = findexternal("myapi")
			api = *p_api
		}
	}
	
	// API Key option specified
	if (apikey != "") {
		api = apikey
	}
	
	// set MARPOR url 
	if (findexternal("myurl")  == NULL) {
		seturl() 
	}
	
	pointer() scalar p_url
	p_url = findexternal("myurl")
	
	// API call for core versions
		// define url for core versions
		url_coreversions = *p_url+"api_list_core_versions.json"+"?api_key="+api

		// open filehandle
		fh_coreversions = fopen(url_coreversions,"r")
		// call API
		coreversions = fget(fh_coreversions)
		// close filehandle
		fclose(fh_coreversions)
		
		// parse json response
		s = strpos(coreversions,"[")+1
		l = strpos(coreversions,"]")-s
		coreversions = substr(coreversions,s,l)
		coreversions = subinstr(coreversions,`"""',"",.)
		
		colnames_vector = ("id","name")
		for(n=1;n<=cols(colnames_vector);++n) {
			coreversions = subinstr(coreversions,colnames_vector[1,n]+":","",.)
		}
		
		// tokenize json response
		coreversions_tokens = tokeninit("},{","","", 0, 0)
		tokenset(coreversions_tokens, coreversions)
		coreversions_matrix = colshape(tokengetall(coreversions_tokens),2)
		
		// add hyperlink to mp_maindataset command
		coreversions_matrix = coreversions_matrix,J(rows(coreversions_matrix),1,"")
		for (m=1; m<=rows(coreversions_matrix); m++) {
			coreversions_matrix[m,3] = "{stata mp_maindataset, clear version(" + coreversions_matrix[m,1] + "):   download}"
		} 
	
	// define pointer 
	pointer() scalar p_recentcoreversion
	
	// if pointer not set
	if ((p_recentcoreversion = findexternal("myrecentcoreversion")) == NULL) {
		p_recentcoreversion = crexternal("myrecentcoreversion")
	}
	
	// set pointer
	*p_recentcoreversion = coreversions_matrix[rows(coreversions_matrix),1]
	
	// display result 
	if (noresponse == "") {
		printf("\n")
		printf("{txt}{hline 70}\n")
		printf("{space 2}id{space 11}name{space 41}link\n")
		printf("{txt}{hline 70}\n")
		
		for (m=1; m<=rows(coreversions_matrix); m++) {
			printf("{res}{space 2}%-12s %-7s %-3s\n",
			coreversions_matrix[m,1],coreversions_matrix[m,2],coreversions_matrix[m,3])
		}
		
		printf("{txt}{hline 70}\n")		
		printf("\n")
	}
	
}

void function corpusversions(string scalar apikey, string scalar dev_opt, | string scalar noresponse) {
	
	// declarations
	real scalar tag
	real scalar name
	string scalar names
	string matrix corpusversions_matrix
	
	// API Key option not specified
	if (apikey == "") {
		
		// define pointer
		pointer() scalar p_api
		
		// API Key not set
		if ((p_api = findexternal("myapi")) == NULL) {
			message = ("API Key not set. Please use the API Key option or the setapikey command.")
			display(message)
		}
		
		// API Key set
		else {
			p_api = findexternal("myapi")
			api = *p_api
		}
	}
	
	// API Key option specified
	if (apikey != "") {
		api = apikey
	}
	
	// set MARPOR url 
	if (findexternal("myurl")  == NULL) {
		seturl() 
	}
	
	pointer() scalar p_url
	p_url = findexternal("myurl")
	
	// API call for corpus versions
		// define url for corpus versions
		url_corpusversions = *p_url+"api_list_metadata_versions.json"+"?api_key="+api+"&tag=true"

		// open filehandle
		fh_corpusversions = fopen(url_corpusversions,"r")
		// call API
		corpusversions = fget(fh_corpusversions)
		// close filehandle
		fclose(fh_corpusversions)
		
		// parse json response
		s = strpos(corpusversions,"[")+1
		l = strpos(corpusversions,"]")-s
		corpusversions = substr(corpusversions,s,l)
		corpusversions = subinstr(corpusversions,"},{","}{",.)

		// tokenize json response
		wchars = pchars = ("}{")
		corpusversions_tokens = tokeninit(wchars,pchars,"", 0, 0)
		tokenset(corpusversions_tokens, corpusversions)
		
		m = 1
		colnames_vector = ("name","tag")
		corpusversions_matrix = J(1,cols(colnames_vector),"")
		while((token = tokenget(corpusversions_tokens)) != "") {
			
			// parse token
			token = subinstr(token,`"""',"",.)
			for(n=1;n<=cols(colnames_vector);++n) {
				token = subinstr(token,colnames_vector[1,n]+":","",.)
			}
			
			// tokenize json response
			wchars = pchars = (",")
			corpusversions_vector_tokens = tokeninit(wchars,pchars,"", 0, 0)
			tokenset(corpusversions_vector_tokens, token)
			corpusversions_vector = tokengetall(corpusversions_vector_tokens)
			
			if (cols(corpusversions_vector) == 1) corpusversions_vector = corpusversions_vector, ""
			
			if (m == 1) corpusversions_matrix = corpusversions_vector
			else corpusversions_matrix = corpusversions_matrix \ corpusversions_vector
			
			m = m + 1
		}
		
	// define pointer 
	pointer() scalar p_recentcorpusversion
	
	// if pointer not set
	if ((p_recentcorpusversion = findexternal("myrecentcorpusversion")) == NULL) {
		p_recentcorpusversion = crexternal("myrecentcorpusversion")
	}
	
	// set pointer
	*p_recentcorpusversion = select(corpusversions_matrix, corpusversions_matrix[.,2]:!="")[rows(select(corpusversions_matrix, corpusversions_matrix[.,2]:!="")),2]
	
	// display result 
	if (noresponse == "") {
		printf("\n")
		printf("{txt}{hline 28}\n")
		printf("{space 2}name{space 14}tag\n")
		printf("{txt}{hline 28}\n")
		
		for (m=1; m<=rows(corpusversions_matrix); m++) {
			if (dev_opt != "") {
				printf("{res}{space 2}%-17s %-7s\n",
				corpusversions_matrix[m,1],corpusversions_matrix[m,2])
			}
			if (dev_opt == "") {
				if (corpusversions_matrix[m,2] != "") {
					printf("{res}{space 2}%-17s %-7s\n",
					corpusversions_matrix[m,1],corpusversions_matrix[m,2])				
				}
			}
		}
		
		printf("{txt}{hline 28}\n")
		printf("\n")
	}
	
}

void function maindataset(string scalar clear_opt, string scalar mpversion, string scalar apikey, string scalar cache_opt, string scalar json_opt, | string scalar externalcall) {
	
	// declarations
	real scalar currentversion
	
	// retrieve current stata version
	currentversion = stataversion()
	
	// API Key option not specified
	if (apikey == "") {
		
		// define pointer
		pointer() scalar p_api
		
		// API Key not set
		if ((p_api = findexternal("myapi")) == NULL) {
			message = ("API Key not set. Please use the API Key option or the setapikey command.")
			display(message)
		}
		
		// API Key set
		else {
			p_api = findexternal("myapi")
			api = *p_api
		}
	}
	
	// API Key option specified
	if (apikey != "") {
		api = apikey
	}
	
	// Version option not specified
	if (mpversion == "") {
		
		// define pointer
		pointer() scalar p_recentcoreversion
		
		// if pointer not set
		if ((p_recentcoreversion = findexternal("myrecentcoreversion")) == NULL) { 
			coreversions(api, "noresponse")	
		}
		
		// set pointer
		p_recentcoreversion = findexternal("myrecentcoreversion")
		mpversion = *p_recentcoreversion
	}	
	
	// set MARPOR url 
	if (findexternal("myurl") == NULL) {
		seturl() 
	}
	
	pointer() scalar p_url
	p_url = findexternal("myurl")
	
	// define pointer to store main data set in cache
	
		// define pointer (json)
		pointer() scalar p_tomaindataset
	
		// define pointer (base64)
		// -------------------------- Basic structure -------------------------- 
		// 1. Number of observations
		// 2. Number of variables
		// 3. Variable names
		// 4. Data set notes
		// ---------------------------------------------------------------------
		pointer() scalar p_tomaindtadataset_bstruct
	
		// ------------------------------- Data --------------------------------
		// 1. Numerical data
		// 2. String data
		// ---------------------------------------------------------------------	
		pointer() scalar p_tomaindtadataset_data
		
		// ------------------------ Variable attributes ------------------------
		// 1. Is numerical variable (0/1)
		// 2. Variable index
		// 3. Variable label
		// 4. Variable type
		// 5. Variable format
		// 6. Value label name
		// 7. Value label values
		// 8. Value label text
		// ---------------------------------------------------------------------
		pointer() scalar p_tomaindtadataset_varatt

	// Nocache option not specified and data in cache
	if ((cache_opt == "") & (findexternal("mymaindataset"+mpversion)) != NULL) {
		
		// Indicate whether cache is being used
		"Nocache option not specified and data in cache"

		// take data set from cache (base64)
		if (json_opt == "") {
			
			// set pointer
			p_tomaindtadataset_bstruct = findexternal("mymaindataset"+mpversion+"bstruct")
			vec_basic_structure = *p_tomaindtadataset_bstruct

			p_tomaindtadataset_data = findexternal("mymaindataset"+mpversion+"data")
			vec_data = *p_tomaindtadataset_data

			p_tomaindtadataset_varatt = findexternal("mymaindataset"+mpversion+"varatt")
			mat_variable_attributes = *p_tomaindtadataset_varatt
			
			// clear stata memory
			stata(clear_opt)
			
			// check for data in memory
			if ((st_updata()!=0)&(clear_opt=="")) _error("no; data in memory would be lost")
			
			// reconstruct data set from cache
				// Step 0: add dataset notes
				if(cols(vec_basic_structure)>3) {
					st_global("_dta[note0]",strofreal(cols(vec_basic_structure)-3))
					for(i=4;i<=cols(vec_basic_structure);i++) {
						st_global("_dta[note" + strofreal(i-3) + "]", *vec_basic_structure[1,i])
					}
				}
				
				// Step 1: define number of observations
				st_addobs(*vec_basic_structure[1,1])
				
				// Step 2: define variable name, variable labels, value labels etc.
				mat_numvars	= J(2,*vec_basic_structure[1,2],.)

				for(i=1;i<=*vec_basic_structure[1,2];i++) {
					idx = st_addvar(*mat_variable_attributes[4,i], (*vec_basic_structure[1,3])[1,i])
					st_varlabel(i,*mat_variable_attributes[3,i])
					st_varformat(i,*mat_variable_attributes[5,i])
					
					if (mat_variable_attributes[7,i]!=NULL) {
						st_vlmodify(*mat_variable_attributes[6,i],*mat_variable_attributes[7,i],*mat_variable_attributes[8,i])
						st_varvaluelabel(i, *mat_variable_attributes[6,i])
					}
					
					mat_numvars[1,i] = *mat_variable_attributes[1,i]
					mat_numvars[2,i] = *mat_variable_attributes[2,i]
				}
				
				// Step 3: add data
				st_store(.,(select(mat_numvars, mat_numvars[1,.]:==1)[2,]),*vec_data[1,1])
				st_sstore(.,(select(mat_numvars, mat_numvars[1,.]:==0)[2,]),*vec_data[1,2])

		}
		
		// take data set from cache (json)
		if (json_opt != "") {
		
			// set pointer
			p_tomaindataset = findexternal("mymaindataset"+mpversion)
		
			maindataset = *p_tomaindataset
		
			// open temp file
			temp_file = st_tempfilename()	
			fh_temp_file = fopen(temp_file, "w")
		
			// save to temp file
			fput(fh_temp_file, maindataset)
		
			// close filehandles
			fclose(fh_temp_file)
		}
		
	}
			
	// Nocache option not specified and no data in cache OR nocache option specified
	if (((cache_opt == "") & (findexternal("mymaindataset"+mpversion)) == NULL) | (cache_opt == "nocache")) {
		
		// Indicate whether cache is being used
		if ((cache_opt == "") & (findexternal("mymaindataset"+mpversion)) == NULL) "Nocache option not specified and no data in cache"
		if (cache_opt == "nocache") "Nocache option specified"
		
		// API call for main data set (base64)
		if (json_opt == "") {
			
			// define url for main data set
			url_maindataset_base64 = "quietly use " + `"""' + *p_url + "api_get_core.json" + "?api_key=" + api + "&key=" + mpversion + "&kind=dta&raw=true" + `"""' + ", " + clear_opt
			
			// load data set to stata memory
			stata(url_maindataset_base64,0)
			
			// Pass data set to cache			
				if ((p_tomaindataset = findexternal("mymaindataset"+mpversion)) == NULL) {
					p_tomaindataset = crexternal("mymaindataset"+mpversion)
				}
			
				// Basic structure
				if ((p_tomaindtadataset_bstruct = findexternal("mymaindataset"+mpversion+"bstruct")) == NULL) {
					p_tomaindtadataset_bstruct = crexternal("mymaindataset"+mpversion+"bstruct")
				}	
				
				// set pointer
				vec_basic_structure = J(1, 3, NULL)
				vec_basic_structure[1,1] = &(J(1,1,st_nobs()))
				vec_basic_structure[1,2] = &(J(1,1,st_nvar()))
				vec_basic_structure[1,3] = &(J(1,1,st_varname(1..st_nvar())))
				if(st_global("_dta[note0]")!="") {
				vec_basic_structure = vec_basic_structure, J(1, strtoreal(st_global("_dta[note0]")), NULL)
					for(i=1;i<=strtoreal(st_global("_dta[note0]"));i++) {
						vec_basic_structure[1,3+i] = &(st_global("_dta[note" + strofreal(i) + "]"))
					}
				}
				*p_tomaindtadataset_bstruct = vec_basic_structure
			
				// Variable attributes
				if ((p_tomaindtadataset_varatt = findexternal("mymaindataset"+mpversion+"varatt")) == NULL) {
					p_tomaindtadataset_varatt = crexternal("mymaindataset"+mpversion+"varatt")
				}
				
				// set pointer
				mat_variable_attributes = J(8,*vec_basic_structure[1,2],NULL)
				for(i=1;i<=st_nvar();i++) {
					mat_variable_attributes[1,i] = &(J(1,1,st_isnumvar(i)))
					mat_variable_attributes[2,i] = &(J(1,1,i))
					mat_variable_attributes[3,i] = &(J(1,1,st_varlabel(i)))
					mat_variable_attributes[4,i] = &(J(1,1,st_vartype(i)))
					mat_variable_attributes[5,i] = &(J(1,1,st_varformat(i)))
					if (st_varvaluelabel(i) != "") {
						st_vlload(st_varvaluelabel(i), values, text)
						mat_variable_attributes[6,i] = &(J(1,1,st_varvaluelabel(i)))
						mat_variable_attributes[7,i] = &(J(1,1,values))
						mat_variable_attributes[8,i] = &(J(1,1,text))
					}
				}
				*p_tomaindtadataset_varatt = mat_variable_attributes 
			
				// Data
				if ((p_tomaindtadataset_data = findexternal("mymaindataset"+mpversion+"data")) == NULL) {
					p_tomaindtadataset_data = crexternal("mymaindataset"+mpversion+"data")
				}	
			
				// set pointer
				mat_numvars	= J(2,st_nvar(),.)
				for(i=1;i<=st_nvar();i++) {
					mat_numvars[1,i] = *mat_variable_attributes[1,i]
					mat_numvars[2,i] = *mat_variable_attributes[2,i]
				}
			
				mat_datasetnum = st_data(.,(select(mat_numvars, mat_numvars[1,.]:==1)[2,]))
				mat_datasetstr = st_sdata(.,(select(mat_numvars, mat_numvars[1,.]:==0)[2,]))
				
				vec_data = J(1, 2, NULL)
				vec_data[1,1] = &(J(1,1,mat_datasetnum))
				vec_data[1,2] = &(J(1,1,mat_datasetstr))
				*p_tomaindtadataset_data = vec_data
		}
		
		// API call for main data set (json)
		if (json_opt != "") {
			
			// define url for main data set
			url_maindataset = *p_url+"api_get_core.json"+"?api_key="+api+"&key="+mpversion

			// open filehandle
			fh_maindataset  = fopen(url_maindataset, "r")
		
			// call API
			maindataset = ""
			while ((part_maindataset=fget(fh_maindataset))!=J(0,0,"")) {
				maindataset = maindataset + part_maindataset		
			}

			// parse json response
			maindataset = subinstr(maindataset,"[[","")
			maindataset = subinstr(maindataset,"]]","")			
			if (currentversion>=1400) maindataset = subinstr(maindataset,"],[",char(13))
			if (currentversion<1400)  maindataset = subinstr(maindataset,"],[",char(13))	
			maindataset = subinstr(maindataset,"null",".") 

			// open temp file
			temp_file = st_tempfilename()	
			fh_temp_file = fopen(temp_file, "w")
		
			// save to temp file
			fput(fh_temp_file, maindataset)
		
			// close filehandles
			fclose(fh_maindataset)
			fclose(fh_temp_file)
			
			// Pass data set to cache 
			if ((p_tomaindataset = findexternal("mymaindataset"+mpversion)) == NULL) {
				p_tomaindataset = crexternal("mymaindataset"+mpversion)
			}
			
			// set pointer
			*p_tomaindataset = maindataset			
		}
	}
						
	if (json_opt != "") {
		if (externalcall == "1") {
			st_local("file", temp_file)
		}
			
		if (externalcall == "") {
	
			// load data set to stata memory
			load_comm = "import delimited " + temp_file + `", delimiter(",") varnames(1)"' + clear_opt + " stripquotes(yes)"
			stata(load_comm,0)
		}
	}
		
	// display respective citation message
	printf("\n")
	cite("",mpversion,api)
	printf("\n")
}

void function cite(string scalar corpusversion, string scalar coreversion, string scalar apikey) {
	
	// API Key option not specified
	if (apikey == "") {
		
		// define pointer
		pointer() scalar p_api
		
		// API Key not set
		if ((p_api = findexternal("myapi")) == NULL) {
			message = ("API Key not set. Please use the API Key option or the setapikey command.")
			display(message)
		}
		
		// API Key set
		else {
			p_api = findexternal("myapi")
			// use pointer 
			api = *p_api
		}
	}
	
	// API Key option specified
	if (apikey != "") {
		api = apikey
	}
	
	// set MARPOR url 
	if (findexternal("myurl") == NULL) {
		seturl() 
	}
	
	pointer() scalar p_url
	p_url = findexternal("myurl")
		
	// API call corpus version
	if (corpusversion!="") {
		
		// define url for corpus citation
		url_corpuscitation = *p_url+"api_get_corpus_citation"+"?api_key="+api+"&key="+corpusversion
	
		// open filehandle
		fh_corpuscitation = fopen(url_corpuscitation,"r")
		
		// call API
		corpuscitation = fget(fh_corpuscitation)
		
		// close filehandle
		fclose(fh_corpuscitation)
		
		// parse json response
		corpuscitation = substr(corpuscitation,strpos(corpuscitation,"citation")+10,strlen(corpuscitation))
		corpuscitation = subinstr(corpuscitation,"}","")
		
		// display result 
		corpuscitation_result = "You are currently using corpus version "+corpusversion+". Please cite as: \n"+corpuscitation+"\n"+"\n"
		printf(ustrunescape(corpuscitation_result))
	}
	
	// API call core version 
	if (coreversion!="") {
		
		// define url for core citation
		url_corecitation = *p_url+"api_get_core_citation"+"?api_key="+api+"&key="+coreversion
	
		// open filehandle
		fh_corecitation = fopen(url_corecitation,"r")
		// call API
		corecitation = fget(fh_corecitation)
		// close filehandle
		fclose(fh_corecitation)
		
		// parse json response
		corecitation = substr(corecitation,strpos(corecitation,"citation")+10,strlen(corecitation))
		corecitation = subinstr(corecitation,"}","")
		
		// display result 
		corecitation_result = "You are currently using core version "+coreversion+". Please cite as: \n"+corecitation+"\n"
		printf(ustrunescape(corecitation_result))
	}
	
}

void function seturl() {
	
	// define pointer
	pointer() scalar p_url
	
	if ((p_url = findexternal("myurl")) == NULL) {
		p_url = crexternal("myurl")
	}
	
	// set pointer
	*p_url = "https://manifesto-project.wzb.eu/tools/"
	
}

void function corpus(string scalar ids, string scalar clear_opt, string scalar apikey, string scalar cache_opt) {
	
	// declarations
	real scalar numberids
	real scalar totalids
	real scalar currentversion
	
	// total number of specified ids
	totalids = cols(tokens(ids))

	// retrieve current stata version
	currentversion = stataversion()	
	
	// API Key option not specified
	if (apikey == "") {
		
		// define pointer
		pointer() scalar p_api
		
		// API Key not set
		if ((p_api = findexternal("myapi")) == NULL) {
			message = ("API Key not set. Please use the API Key option or the setapikey command.")
			display(message)
		}
		
		// API Key set
		else {
			p_api = findexternal("myapi")
			api = *p_api
		}
	}
	
	// API Key option specified
	if (apikey != "") {
		api = apikey
	}	
	
	// set MARPOR url 
	if (findexternal("myurl")  == NULL) {
		seturl() 
	}
	
	pointer() scalar p_url
	p_url = findexternal("myurl")
	
	// retrieve most current version 
		// define pointer
		pointer() scalar p_recentcorpusversion
		
		// if pointer not set
		if ((p_recentcorpusversion = findexternal("myrecentcorpusversion")) == NULL) { 
			corpusversions(api, "", "noresponse")	
		}
		
		// set pointer
		p_recentcorpusversion = findexternal("myrecentcorpusversion")
		mpversion = *p_recentcorpusversion
	
	// parse ID list
	ids_tokens = tokeninit(" ","","", 0, 0)
	tokenset(ids_tokens, ids)
	addinfo_vector = J(totalids,3,"")
	
	// counter
	idcount = 0
	
	// API call for corpus
	temp_file = st_tempfilename()
	while((key = tokenget(ids_tokens)) != "") {
		
		// retrieve metadata
			// define pointer
			pointer() scalar p_annotations
			pointer() scalar p_manifesto_id

			// call metadata function
			metadata(key, api, "", "", "noresponse")
			
			// set pointer
			p_annotations = findexternal("myannotations")
			annotations = *p_annotations						
		
			p_manifesto_id = findexternal("mymanifestourlkey")
			urlkey = *p_manifesto_id
		
		if (annotations=="true") {
		
		// set cache-key
		// define pointer
		pointer() scalar p_cache_corpus
		pointer() scalar p_cache_vars

		// set cache keys
		sca_cache_corpus = "cached"+key+"corpus"
		sca_cache_vars = "cached"+key+"vars"
		
		// Nocache option not specified and data in cache
		if ((cache_opt == "") & (findexternal(sca_cache_corpus)) != NULL) {
				"Nocache option not specified and data in cache"
				
				p_cache_corpus = findexternal(sca_cache_corpus)
				corpus = *p_cache_corpus
				
				p_cache_vars = findexternal(sca_cache_vars)
				vars = *p_cache_vars
		}
		
		// Nocache option not specified and no data in cache
		if (((cache_opt == "") & (findexternal(sca_cache_corpus)) == NULL) | (cache_opt == "nocache")) {
			if ((cache_opt == "") & (findexternal(sca_cache_corpus)) == NULL) "Nocache option not specified and no data in cache"
			if (cache_opt == "nocache") "Nocache option specified"
		
			// define url for corpus
			url_corpus = *p_url+"api_texts_and_annotations.json"+"?api_key="+api+"&keys[]="+urlkey+"&version="+mpversion
			
			// open filehandle
			fh_corpus = fopen(url_corpus,"r")
			
			// call API
			corpus = ""
			while ((part_corpus=fget(fh_corpus))!=J(0,0,"")) {
				corpus = corpus + part_corpus
			}
			
			// parse json response
			s = strpos(corpus,"content")-1
			//l = strpos(corpus,"missing_item")-s-4
			l = strpos(corpus,"missing_item")-s-6
			corpus = substr(corpus,s,l)
			variables_vector = "content","cmp_code","eu_code"
			for (i=1;i<=cols(variables_vector);i++) {
				corpus = subinstr(corpus,`"""'+variables_vector[.,i]+`"""'+":","")
				if (i==1) vars = `"""'+variables_vector[.,i]+`"""'
				if (i>1)  vars = vars+","+`"""'+variables_vector[.,i]+`"""'
			}
			if (currentversion>=1400) vars = vars+char(13)
			if (currentversion<1400)  vars = vars+char(13)

			// special case USA
			corpus = subinstr(corpus,`"\""',"'")

			corpus = subinstr(corpus,"NA",".")
			if (currentversion>=1400) corpus = subinstr(corpus,"},{",char(13))
			if (currentversion<1400)  corpus = subinstr(corpus,"},{",char(13))
			
			// close filehandle
			fclose(fh_corpus)
			
			if (cache_opt == "") {
				// pass data to cache
				p_cache_corpus = crexternal(sca_cache_corpus)
				*p_cache_corpus = corpus

				p_cache_vars = crexternal(sca_cache_vars)
				*p_cache_vars = vars
			}
		}

		// 
		idcount = idcount + 1
				
		// retrieve number of quasi sentences
		token_getobs = tokeninit(char(13),"","", 0, 0)
		tokenset(token_getobs, corpus)
		obs = cols(tokengetall(token_getobs))
		addinfo_vector[idcount,1] = strofreal(obs)

		// set party id
		addinfo_vector[idcount,2] = substr(key,1,5)
		addinfo_vector[idcount,3] = substr(key,7,.)
		
		// open temp file
		if (idcount==1) {
			corpus = vars + corpus
			fh_temp_file = fopen(temp_file, "w")
		}
		if (idcount>1) {
			fh_temp_file = fopen(temp_file, "a")
		}

		// save to temp file
		fput(fh_temp_file, corpus)
		
		// close filehandle
		fclose(fh_temp_file)

	}
		if (annotations=="false") {
			message = ("No corpus data found for key: " + key)
			display(message)
		}
	}
	
	if (idcount>=1) {
		addinfo_vector = strtoreal(addinfo_vector)
		for (i=1;i<=idcount;++i) {
			if(i==1) {
				mat_ids = J(addinfo_vector[i,1],1,addinfo_vector[i,2]) , J(addinfo_vector[i,1],1,addinfo_vector[i,3])
			}
			else {
				mat_ids = mat_ids \ (J(addinfo_vector[i,1],1,addinfo_vector[i,2]) ,J(addinfo_vector[i,1],1,addinfo_vector[i,3]))
			}
		}
	
		load_comm = "quietly import delimited " + temp_file + `", delimiter(",") varnames(1)"' + clear_opt
		
		stata(load_comm,0)
		
		idx = st_addvar(("double","double"),("party","date"))
		st_store(., idx, mat_ids)
	}
	
	// display respective citation message
	printf("\n")
	cite(mpversion,"",api)
	printf("\n")
	
}

void function view_originals(string scalar id) {
	
	// set url
	url_originals = "https://manifesto-project.wzb.eu/down/originals/"
	
	// generate complete url
	url_call = url_originals + id + ".pdf"
	
	// pass url to mp_view_originals via local
	st_local("url", url_call)
	
}

struct struct_metadata {
	
	string scalar party_id, election_date, language, source, has_eu_code, is_primary_doc, may_contradict_core_dataset, manifesto_id, md5sum_text, url_original, md5sum_original, annotations
	
}

void function metadata(string scalar ids, string scalar apikey, string scalar saving, string scalar cache, | string scalar noresponse) {
	
	// declarations
	real scalar numberids
	struct struct_metadata scalar meta
	real scalar totalids
	
	// total number of specified ids
	totalids = cols(tokens(ids))
	
	// keys for bundled call
	keys = ""
	for (i=1;i<=cols(tokens(ids));++i) {
		keys = keys + "&keys[]="+tokens(ids)[1,i]
	}
	
	// API Key option not specified
	if (apikey == "") {
		
		// define pointer
		pointer() scalar p_api
		
		// API Key not set
		if ((p_api = findexternal("myapi")) == NULL) {
			message = ("API Key not set. Please use the API Key option or the setapikey command.")
			display(message)
		}
		
		// API Key set
		else {
			p_api = findexternal("myapi")
			api = *p_api
		}
	}
	
	// API Key option specified
	if (apikey != "") {
		api = apikey
	}	
	
	// set MARPOR url 
	if (findexternal("myurl")  == NULL) {
		seturl() 
	}
	
	pointer() scalar p_url
	p_url = findexternal("myurl")
	
	// retrieve most current version 
		// define pointer
		pointer() scalar p_recentcorpusversion
		
		// if pointer not set
		if ((p_recentcorpusversion = findexternal("myrecentcorpusversion")) == NULL) { 
			corpusversions(api, "", "noresponse")	
		}
		
		// set pointer
		p_recentcorpusversion = findexternal("myrecentcorpusversion")
		mpversion = *p_recentcorpusversion
		
	// bundled API call for metadata
		// define url for metadata
		url_metadata = *p_url+"api_metadata.json"+"?api_key="+api+keys+"&version="+mpversion
		
		// open filehandle
		fh_metadata = fopen(url_metadata,"r")
		
		// call API
		metadata = ""
		while ((part_metadata=fget(fh_metadata))!=J(0,0,"")) {
			metadata = metadata + part_metadata
		}		
		
		// close filehandle
		fclose(fh_metadata)	
				
		// parse json response (missing ids)
		s = strpos(metadata,`""missing_items":"')
		missingitems = substr(metadata,s,.)
		missingitems = subinstr(missingitems,`"""',"")
		missingitems = subinstr(missingitems,"}","")
		missingitems = subinstr(missingitems,"{","")
		missingitems = subinstr(missingitems,"[","")
		missingitems = subinstr(missingitems,"]","")
		missingitems = subinstr(missingitems,":"," ")
		missingitems = tokens(missingitems)
		
		// display missing ids 
		if (cols(missingitems) == 2) {
			nokeys = subinstr(tokens(missingitems[1,2]),","," ")
			totalids = totalids - cols(tokens(nokeys))
			message = "\n No metadata found for key(s) " + nokeys + "\n"
			printf(message)
		}

		// parse json response (non-missing ids)
		s = strlen(`"{"items":"')+2
		metadata = substr(metadata,s,.)		
		l = strpos(metadata,`""missing_items":"')-3
		metadata = substr(metadata,1,l)
		metadata = subinstr(metadata,`"""',"")
		metadata = subinstr(metadata,"null",".")
		metadata = subinstr(metadata,":","},{")			
		
		// display non-missing ids 
		metadata_tokens = tokeninit("},{","","", 0, 0)
		tokenset(metadata_tokens, metadata)

		metadata_matrix = colshape(tokengetall(metadata_tokens),24)
		metadata_matrix = metadata_matrix[.,select((1..cols(metadata_matrix)), !mod((1..cols(metadata_matrix)),2))]
		
		content = J(1,cols(metadata_matrix),NULL)
		
		numberids = 1
		while(numberids<=rows(metadata_matrix)){
			for(m=1;m<=cols(metadata_matrix);m++) {
				content[m] = &(metadata_matrix[numberids,m])
			}
			
			// populate structure
			meta.party_id = 					*content[1]
			meta.election_date = 				*content[2]
			meta.language = 					*content[3]
			meta.source = 						*content[4]
			meta.has_eu_code = 					*content[5]
			meta.is_primary_doc = 				*content[6]
			meta.may_contradict_core_dataset = 	*content[7]
			meta.manifesto_id = 				*content[8]
			meta.md5sum_text = 					*content[9]
			meta.url_original = 				*content[10]
			meta.md5sum_original = 				*content[11]
			meta.annotations = 					*content[12]
						
			// define pointer 
			pointer() scalar p_annotations
			pointer() scalar p_manifesto_id
		
			// if pointer not set
			if ((p_annotations = findexternal("myannotations")) == NULL) {
				p_annotations = crexternal("myannotations")
			}
			
			if ((p_manifesto_id = findexternal("mymanifestourlkey")) == NULL) {
				p_manifesto_id = crexternal("mymanifestourlkey")
			}
			
			// set pointer
			*p_annotations = meta.annotations
			*p_manifesto_id = meta.manifesto_id
			
			// call display function
			if (noresponse == "") displaymetadata(meta,numberids,totalids)
			
			// increase counter
			numberids = numberids + 1
		
		}
		
		// call store function
		if (saving != "") storemetadata(saving,metadata_matrix,numberids)
	
}

function displaymetadata(struct struct_metadata scalar x, real scalar count, real scalar total) {
	
	// if first id
	if (count==1) {
		printf("\n")
		printf("{txt}{hline 130}\n")
		printf("{space 2}party{space 2}date{space 4}language{space 12}source{space 2}has_eu_code{space 2}is_primary_doc{space 2}may_contradict_core_dataset{space 2}manifesto_id{space 2}annotations\n")
		printf("{hline 130}\n")
	}
	
	// print results
	printf("{res}{space 2}%-6s %-7s %-19s %-7s %-12s %-15s %-28s %-13s %-12s\n",
		x.party_id,x.election_date,x.language,x.source,x.has_eu_code,x.is_primary_doc,x.may_contradict_core_dataset,x.manifesto_id,x.annotations)
	
	// if last id
	if (count==total) printf("{txt}{hline 130}\n")
	
}

function storemetadata(string scalar path, matrix x, real scalar obs) {
	
	// preserve and clear current data set
	stata("preserve",0)
	stata("clear",0)
	
	// add number of observations
	st_addobs(obs-1)
	
	// generate and store numeric variables
	idx_num = st_addvar("float",("party","date"))
	st_store(.,idx_num,strtoreal(x[.,1..2]))
	
	// generate and store string variables
	idx_str = st_addvar(10, ("language","source","has_eu_code","is_primary_doc","may_contradict_core_dataset","manifesto_id","md5sum_text","url_original","md5sum_original","annotations"))	
	st_sstore(.,idx_str,x[.,3..12])
	
	// store data set
	store_comm = "save " + path
	stata(store_comm,0)	
	
	// restore current data set
	stata("restore",0)
}

void function selectsubset(touse) {
	
	// generate empty idlist
	idlist = ""

	// take view of data set
	st_view(subset, ., "party date",touse)
	
	// loop over ids
	for (i=1;i<=rows(subset);i++) {
		key = strofreal(subset[i,1]) + "_" + strofreal(subset[i,2])
		idlist = idlist + " " + key
	}
	
	// pass local idlist to routine
	st_local("idlist", idlist)
	
}

void function tostring_v5 (string scalar varnames) {
	for(i=1;i<=cols(tokens(varnames));i++){
		stata(("quietly tostring " + tokens(varnames)[i] + ", replace"),0)		
	}
	
}

mata mlib create lmanifestata, dir(PERSONAL) replace
mata mlib add lmanifestata *()
mata mlib index
end
