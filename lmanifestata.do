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

void function genapifile(string scalar apifilepath, string scalar apikey, string scalar replace_opt) {
	/* to be included? */
	if (fileexists(apifilepath) == 1 & replace_opt == "") {
		display("The API Key file already exists. Specify the replace option if you want to replace your API Key file.")
	}
	
	if (fileexists(apifilepath) == 1 & replace_opt != "") {
		mm_outsheet(apifilepath,apikey,"replace")
	}
	
	if (fileexists(apifilepath) == 0) {
		mm_outsheet(apifilepath,apikey)
	}
	
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
		printf("{txt}{hline 58}\n")
		printf("{space 2}id{space 11}name\n")
		printf("{txt}{hline 58}\n")
		
		for (m=1; m<=rows(coreversions_matrix); m++) {
			printf("{res}{space 2}%-12s %-7s\n",
			coreversions_matrix[m,1],coreversions_matrix[m,2])
		}
		
		printf("{txt}{hline 58}\n")		
		printf("\n")
	}
	
}

void function corpusversions(string scalar apikey, | string scalar noresponse) {
	
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
			printf("{res}{space 2}%-17s %-7s\n",
			corpusversions_matrix[m,1],corpusversions_matrix[m,2])
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
	
	// define pointer 
	pointer() scalar p_tomaindataset
	pointer() scalar p_tomaindatasetvars
	
	pointer() scalar p_tomaindtadataset_nobs
	pointer() scalar p_tomaindtadataset_nvar
	pointer() scalar p_tomaindtadataset_varnames	

	pointer() scalar p_tomaindtadataset_numstr
	pointer() scalar p_tomaindtadataset_numvars
	pointer() scalar p_tomaindtadataset_strvars
	pointer() scalar p_tomaindtadataset_num
	pointer() scalar p_tomaindtadataset_str
	pointer() scalar p_tomaindtadataset_varlab
	
	// Nocache option not specified and no data in cache OR nocache option specified
	if (((cache_opt == "") & (findexternal("mymaindataset"+mpversion)) == NULL) | (cache_opt == "nocache")) {
		if ((cache_opt == "") & (findexternal("mymaindataset"+mpversion)) == NULL) "Nocache option not specified and no data in cache"
		if (cache_opt == "nocache") "Nocache option specified"
		
		// API call for main data set (base64)
		if (json_opt == "") {
			
			// define url for main data set
			url_maindataset_base64 = "quietly use " + `"""' + *p_url + "api_get_core.json" + "?api_key=" + api + "&key=" + mpversion + "&kind=dta&raw=true" + `"""' + ", " + clear_opt
			
			// load data set to stata memory
			stata(url_maindataset_base64,0)
			
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
			//if (currentversion>=1400) maindataset = subinstr(maindataset,"],[",char(13) + " ")
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
		}
	}
	
	// Nocache option not specified and data in cache
	if ((cache_opt == "") & (findexternal("mymaindataset"+mpversion)) != NULL) {
		"Nocache option not specified and data in cache"

		// take data set from cache (base64)
		if (json_opt == "") {
			
			// set pointer
			p_tomaindtadataset_nobs = findexternal("mymaindataset"+mpversion+"nobs")
			p_tomaindtadataset_nvar = findexternal("mymaindataset"+mpversion+"nvar") 
			p_tomaindtadataset_varnames = findexternal("mymaindataset"+mpversion+"varnames") 	

			p_tomaindtadataset_numstr = findexternal("mymaindataset"+mpversion+"numstr")
			p_tomaindtadataset_num = findexternal("mymaindataset"+mpversion+"num")
			p_tomaindtadataset_str = findexternal("mymaindataset"+mpversion+"str")
			p_tomaindtadataset_numvars = findexternal("mymaindataset"+mpversion+"numvars")		
			p_tomaindtadataset_strvars = findexternal("mymaindataset"+mpversion+"strvars")	
			p_tomaindtadataset_varlab = findexternal("mymaindataset"+mpversion+"varlab")				
			
			vec_varnames = *p_tomaindtadataset_varnames
			vec_numvar = *p_tomaindtadataset_numstr
			vec_varlabel = *p_tomaindtadataset_varlab
		
			stata(clear_opt)
			
			for(i=1;i<=cols(vec_numvar);i++) {
				if (vec_numvar[1,i]==1) idx = st_addvar("double", vec_varnames[1,i])
				else idx = st_addvar("str10", vec_varnames[1,i])
				st_varlabel(i,vec_varlabel[1,i])
			}
			
			st_addobs(*p_tomaindtadataset_nobs)
	
			st_store(.,*p_tomaindtadataset_numvars,*p_tomaindtadataset_num)
			st_sstore(.,*p_tomaindtadataset_strvars,*p_tomaindtadataset_str)

		}
		
		// take data set from cache (json)
		if (json_opt != "") {
		
			// set pointer
			p_tomaindataset = findexternal("mymaindataset"+mpversion)
			p_tomaindatasetvars = crexternal("mymaindatasetvars")
		
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
	
	// pass data set to cache			
		
		// if pointer not set (json)
		if (json_opt != "") {
			
			if ((p_tomaindataset = findexternal("mymaindataset"+mpversion)) == NULL) {
				p_tomaindataset = crexternal("mymaindataset"+mpversion)
			}
			
			if ((p_tomaindatasetvars = findexternal("mymaindatasetvars")) == NULL) {
				p_tomaindatasetvars = crexternal("mymaindatasetvars")
			}
			
			// set pointer
			*p_tomaindataset = maindataset
			*p_tomaindatasetvars = ddasd		
		}
		
		// if pointer not set (base64)
		if (json_opt == "") {

			if ((p_tomaindataset = findexternal("mymaindataset"+mpversion)) == NULL) {
				p_tomaindataset = crexternal("mymaindataset"+mpversion)
			}
		
			if ((p_tomaindtadataset_nobs = findexternal("mymaindataset"+mpversion+"nobs")) == NULL) {
				p_tomaindtadataset_nobs = crexternal("mymaindataset"+mpversion+"nobs")
			}	
			
			if ((p_tomaindtadataset_nvar = findexternal("mymaindataset"+mpversion+"nvar")) == NULL) {
				p_tomaindtadataset_nvar = crexternal("mymaindataset"+mpversion+"nvar")
			}	
			
			if ((p_tomaindtadataset_varnames = findexternal("mymaindataset"+mpversion+"varnames")) == NULL) {
				p_tomaindtadataset_varnames = crexternal("mymaindataset"+mpversion+"varnames")
			}	
			
			// set pointer
			*p_tomaindtadataset_nobs = st_nobs()
			*p_tomaindtadataset_nvar = st_nvar()
			*p_tomaindtadataset_varnames = st_varname(1..*p_tomaindtadataset_nvar)
			
			vec_numvar = J(2,st_nvar(),0)
			vec_varlabel = J(1,st_nvar(),"")
			vec_varvaluelabel = J(1,st_nvar(),"")
	
			for(i=1;i<=st_nvar();i++) {
				if (st_isnumvar(i)==1) {
					vec_numvar[1,i] = 1
					vec_numvar[2,i] = i
				}
				else vec_numvar[2,i] = i
				vec_varlabel[1,i] = st_varlabel(i)
				vec_varvaluelabel[1,i] = st_varvaluelabel(i)
			}
	
			sca_numvars = select(vec_numvar, vec_numvar[1,.]:==1)[2,]	
			mat_datasetnum = st_data(.,sca_numvars)
		
			sca_strvars = select(vec_numvar, vec_numvar[1,.]:==0)[2,]
			mat_datasetstr = st_sdata(.,sca_strvars)

			if ((p_tomaindtadataset_numstr = findexternal("mymaindataset"+mpversion+"numstr")) == NULL) {
				p_tomaindtadataset_numstr = crexternal("mymaindataset"+mpversion+"numstr")
			}	
					
			if ((p_tomaindtadataset_num = findexternal("mymaindataset"+mpversion+"num")) == NULL) {
				p_tomaindtadataset_num = crexternal("mymaindataset"+mpversion+"num")
			}	
			
			if ((p_tomaindtadataset_str = findexternal("mymaindataset"+mpversion+"str")) == NULL) {
				p_tomaindtadataset_str = crexternal("mymaindataset"+mpversion+"str")
			}	
			
			if ((p_tomaindtadataset_numvars = findexternal("mymaindataset"+mpversion+"numvars")) == NULL) {
				p_tomaindtadataset_numvars = crexternal("mymaindataset"+mpversion+"numvars")
			}	
			
			if ((p_tomaindtadataset_strvars = findexternal("mymaindataset"+mpversion+"strvars")) == NULL) {
				p_tomaindtadataset_strvars = crexternal("mymaindataset"+mpversion+"strvars")
			}	
		
			if ((p_tomaindtadataset_varlab = findexternal("mymaindataset"+mpversion+"varlab")) == NULL) {
				p_tomaindtadataset_varlab = crexternal("mymaindataset"+mpversion+"varlab")
			}	
		
			// set pointer
			*p_tomaindtadataset_numstr = vec_numvar
			*p_tomaindtadataset_num = mat_datasetnum
			*p_tomaindtadataset_str = mat_datasetstr	
			*p_tomaindtadataset_numvars = sca_numvars
			*p_tomaindtadataset_strvars = sca_strvars
			*p_tomaindtadataset_varlab = vec_varlabel

		}
		
		
		// ALTERNATIVE METHOD MUCH SLOWER vector with variable names
		//variables_vector = substr(maindataset,strpos(maindataset,"[[")+2,strpos(maindataset,"],[")-3)
		//wchars = pchars = (",")
		//variables_vector_tokens = tokeninit(wchars,pchars,"", 0, 0)
		//tokenset(variables_vector_tokens, variables_vector)
		//variables_vector = tokengetall(variables_vector_tokens)
		
		//maindataset = substr(maindataset,strpos(maindataset,"],[")+2,.)
		
		// tokenize json response
		//maindataset = subinstr(maindataset,"],[","][",.)
		//wchars = pchars = ("][")
		//qchars = ("")
		//corpusversions_tokens = tokeninit(wchars,pchars,qchars, 0, 0)
		//tokenset(corpusversions_tokens, maindataset)
		
		//m = 1
		//colnames_vector = ("name","tag")
		//corpusversions_matrix = J(1,cols(colnames_vector),"")
		//while((token = tokenget(corpusversions_tokens)) != "") {
			//wchars = pchars = (",")
			//qchars = (`""""')
			//corpusversions_vector_tokens = tokeninit(wchars,pchars,qchars, 0, 0)
			//tokenset(corpusversions_vector_tokens, token)
			//tokengetall(corpusversions_vector_tokens)
			//if (m==1) h = variables_vector \ tokengetall(corpusversions_vector_tokens)
			//else      h = h \ tokengetall(corpusversions_vector_tokens)
			//m = m +1
		//}
				
				
		// pass maindataset to cache 
		//variables_vector = cat(temp_file,1,1)
		//variables_vector_tokens = tokeninit(",",",","", 0, 0)
		//tokenset(variables_vector_tokens, variables_vector)
		//variables_vector = tokengetall(variables_vector_tokens)
		//maindataset_vector = cat(temp_file,2)
	
		//maindataset_cache = J(rows(maindataset_vector),cols(variables_vector),"")
		
		//wchars = pchars = (" ,")
		//qchars = (`""""')
		//maindataset_vector_tokens = tokeninit(wchars,pchars,qchars, 0, 0)
		//for (m=1;m<=rows(maindataset_vector);m++) {
		//	tokenset(maindataset_vector_tokens, maindataset_vector[m,.])
		//	n = 1
		//	while((token = tokenget(maindataset_vector_tokens)) != "") {
		//		maindataset_cache[m,n] = token
		//		n = n + 1
		//	}
		//}
		
		if (json_opt != "") {
			if (externalcall == "1") {
				st_local("file", temp_file)
			}
			
			if (externalcall == "") {
				// load data set to stata memory
				load_comm = "import delimited " + temp_file + `", delimiter(",") varnames(1)"' + clear_opt + " stripquotes(yes)"
				stata(load_comm,0)
				
				// save data set to temp file
				// temp_dtafile = st_tempfilename()
				// save temp_dtafile
				// st_local("dtafile", temp_dtafile)
			}
		}
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
			corpusversions(api, "noresponse")	
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
			
			// call metadata function
			metadata(key, api, "", "noresponse")
			
			// set pointer
			p_annotations = findexternal("myannotations")
			annotations = *p_annotations						
					
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
			urlkey = substr(key,1,strlen(key)-2)
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
			//addinfo_vector[idcount,1] = "0"
			//addinfo_vector[idcount,2] = substr(key,1,5)
			//addinfo_vector[idcount,3] = substr(key,7,.)
			//idcount = idcount + 1
		}
	}
	
	if (idcount>=1) {
		addinfo_vector = strtoreal(addinfo_vector)
		//for (i=1;i<=totalids;++i) {
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

void function metadata(string scalar ids, string scalar apikey, string scalar cache, | string scalar noresponse) {
	
	// declarations
	real scalar numberids
	struct struct_metadata scalar meta
	real scalar totalids
	
	// total number of specified ids
	totalids = cols(tokens(ids))
	
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
			corpusversions(api, "noresponse")	
		}
		
		// set pointer
		p_recentcorpusversion = findexternal("myrecentcorpusversion")
		mpversion = *p_recentcorpusversion
	
	// subset specified to be implemented
	// if (subset != "") {
	//	tokenssubset = tokeninit("&","&","",0,0)
	//	tokenset(tokenssubset,subset)
	//	subsetcond = tokengetall(tokenssubset)
	//	callmaindataset(subsetcond)
	// }
	
	// parse ID list
	ids_tokens = tokeninit(" ","","", 0, 0)
	tokenset(ids_tokens, ids)
	
	numberids = 1
	// API call for corpus
	while((key = tokenget(ids_tokens)) != "") {
		
		// define url for corpus
		url_metadata = *p_url+"api_metadata.json"+"?api_key="+api+"&keys[]="+key+"&version="+mpversion
		
		// open filehandle
		fh_metadata = fopen(url_metadata,"r")
		
		// call API
		metadata = fget(fh_metadata)
		
		// close filehandle
		fclose(fh_metadata)
	
		// parse json response
		missingitems = substr(metadata,strpos(metadata,`""missing_items":"'),.)
		missingitems = subinstr(missingitems,`"""',"")
		missingitems = subinstr(missingitems,"}","")
		missingitems = subinstr(missingitems,"{","")
		missingitems = subinstr(missingitems,"[","")
		missingitems = subinstr(missingitems,"]","")
		missingitems = subinstr(missingitems,":"," ")
		missingitems = tokens(missingitems)
		
		// if id does not exist
		if (cols(missingitems) == 2) {
			message = "\n No metadata found for key " + key + "\n"
			printf(message)
		}
		
		// if id exists
		if (cols(missingitems) == 1) {
		
			metadata = subinstr(metadata,`"{"items":[{"',"")
			metadata = subinstr(metadata,`"}],"missing_items":[]}"',"")
			metadata = subinstr(metadata,`"""',"")
		
			metadata_matrix = J(12,2,"")
			
			content = J(1,rows(metadata_matrix),NULL)
		
			tokens_metadata1 = tokeninit(",","","", 0, 0)
			tokenset(tokens_metadata1, metadata)
	
			m = 1
			while((token1 = tokenget(tokens_metadata1)) != "") {
				tokens_metadata2 = tokeninit(":","","", 0, 0)
				tokenset(tokens_metadata2, token1)
				n = 1
				while((token2 = tokenget(tokens_metadata2)) != "") {
					metadata_matrix[m,n] = token2
					++n
				}
				content[m] = &(metadata_matrix[m,2])
				++m
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
	
			// if pointer not set
			if ((p_annotations = findexternal("myannotations")) == NULL) {
				p_annotations = crexternal("myannotations")
			}
			
			// set pointer
			*p_annotations = meta.annotations
			
			// call display function
			if (noresponse == "") displaymetadata(meta,numberids,totalids)
			
			// counter
			numberids = numberids + 1
			
		}
	}
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

void function callmaindataset(string matrix subsetcond) {
	/* to be included! */
	
	// define pointer
	pointer() scalar p_tomaindataset
	pointer() scalar p_tomaindatasetvars
	
	// if pointer not set
	if ((p_tomaindataset = findexternal("mymaindataset")) == NULL) { 
		maindataset("clear","","","")
	}
	
	p_tomaindataset = findexternal("mymaindataset")
	p_tomaindatasetvars = findexternal("mymaindatasetvars")
	
	data = *p_tomaindataset
	varnames = *p_tomaindatasetvars
	
	// subsetcond
	// varindex = selectindex(varnames:==variablename)
	// subset = select(data,data[.,varindex]:>value)
	// subset
	
}

mata mlib create lmanifestata, dir(PERSONAL) replace
mata mlib add lmanifestata *()
mata mlib index
end
