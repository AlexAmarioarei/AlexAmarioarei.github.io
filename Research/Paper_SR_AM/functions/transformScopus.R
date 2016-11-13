transformScopus = function(titleIn, titleOut){
  
  
  # Create the City dataset 
  #------------------------
  mun = read.delim("dataIn/Municipii/MunicipiiC.txt", sep = "\t",stringsAsFactors = FALSE) # create the list of towns 
  names(mun) = c("City")
  mun$ID = 1:length(mun$City)
  
  # split by space and - 
  nw = lapply(mun$City, function(x){unlist(str_split(x, " |-"))})
  nw2 = unlist(lapply(nw, length)) # how many words per city
  
  # create a new data frame with the city names 
  munDF = as.data.frame(lapply(mun, function(x){rep(x, times = nw2)}), stringsAsFactors = FALSE)
  munDF$City = unlist(nw)
  
  # remove the entries == "de" (as for example in Curtea de Arges, etc.)
  munDF2 = munDF[munDF$City != "de", ]
  
  # remove the entries == "Mare" (as for example in Baia Mare, etc.)
  munDF2 = munDF2[munDF2$City != "Mare", ]
  
  # remove the second Magurele
  
  iM = which(munDF2$City == "Magurele")
  munDF2 = munDF2[-iM[2],]
  
  # transform to lower case 
  mun2 = str_to_lower(munDF2$City)
  
  # Reading the document and modifying its structure
  #===================================================
  doc = read.csv(paste0("dataIn/", titleIn), encoding = "UTF-8", stringsAsFactors = FALSE)
  
  # colnames(doc)[1] = "Authors"
  
  # remove the duplicates 
  if (length(unique(doc$Title))!=length(doc$Title)){
    doc = doc[!duplicated(doc$Title), ]
  }
  
  # split the affiliations 
  affils = lapply(doc$Affiliations, function(x){unlist(strsplit(x, split = ";"))})
  len_affils = lapply(affils, length)
  
  
  # find the affiliations from Romania
  
  affils_Ro = lapply(affils, function(x){grep("Romania", x, value = TRUE)})
  
  # how many are with more than 1 affiliation ?
  nr_affils_Ro = lapply(affils_Ro, length) # in this case 26 entries 
  
  #affils_Ro
  nrep = unlist(nr_affils_Ro)
  
  doc2 = as.data.frame(lapply(doc, function(x){rep(x, times = nrep)}), encoding = "UTF-8", stringsAsFactors = FALSE) # recreate the document with respect to the number of copies 
  
  doc2$Affiliations = unlist(affils_Ro)
  doc2$Affiliations = gsub("^ ", "", doc2$Affiliations) # remove the space from the begining of the affiliation names 
  
  doc2$Affiliations2 = str_to_lower(doc2$Affiliations, "en") # by using str_to_lower function we get better results
  
  # Determine the city of each affiliation 
  #----------------------------------------
  city = unlist(lapply(doc2$Affiliations2, function(x){
    kk = unlist(str_split(x, " |,|-|/"))
    lk = length(kk)
    l = kk %in% mun2
    l2 = which(l)
    
    if ((sum(l)>=1)&&(l2[length(l2)] == lk-2)){
      id2 = l2[length(l2)]
      m = kk[id2]
      id = munDF2$ID[mun2 %in% m]
      mun$City[which(mun$ID == id)]
    }else if ((sum(l)>=1)&&(l2[length(l2)] != lk-2)){
      id2 = l2[1]
      m = kk[id2]
      id = munDF2$ID[mun2 %in% m]
      id = id[1]
      mun$City[which(mun$ID == id)]
    }else{
      ""
    }
  }))
  
  doc2$City = city
  
  # transform Bucuresti -> Bucharest
  doc2$City[which(doc2$City == "Bucuresti")] = "Bucharest"
  doc2$City[which(doc2$City == "Bucarest")] = "Bucharest"
  doc2$City[which(doc2$City == "Bukarest")] = "Bucharest"
  
  # transform Constantza -> Constanta
  doc2$City[which(doc2$City == "Constantza")] = "Constanta"
  doc2$City[str_detect(doc2$Affiliations2, "marine .*grigore antipa")] = "Constanta"
  
  # transform Iassy -> Iasi
  doc2$City[which(doc2$City == "Iassy")] = "Iasi"
  
  # recheck for some cities such Sfantu Gheorghe (not to be Iasi) 
  indSF = which(doc2$City == "Sfantu Gheorghe")
  indIS = str_detect(doc2$Affiliations2[indSF], "asachi")
  
  if (sum(indIS)>=1){
    doc2$City[indSF[indIS]] = "Iasi" 
  }
  
  # try to improve the results for the rest 
  #-----------------------------------------
  
  indC = which(doc2$City == "")
  affilsNG = doc2$Affiliations2[indC] # the affiliations that don't have a city attached 
  cityNG = doc2$City[indC]
  cityNG
  
  munC = read.delim("dataIn/Municipii/MunicipiiC2.txt", sep = "\t",stringsAsFactors = FALSE) # create the list of towns 
  names(munC) = c("City")
  lc = length(munC$City)/2
  munC$ID = rep(1:lc, each = 2)
  
  munC$City[seq(2,length(munC$City), by = 2)] = str_to_lower(munC$City[seq(2,length(munC$City), by = 2)])
  
  for (i in seq(2,length(munC$City), by = 2)){
    city2 = unlist(lapply(as.list(affilsNG), function(x){
      kk = unlist(str_split(x, " |,|-"))
      l = str_detect(kk, munC$City[i])
      
      # l = str_detect(x, munC$City[i])
      
      if (sum(l)>=1){
        munC$City[i-1]
      }else{
        ""
      } 
    }))
    
    indC2 = which(city2 != "")
    
    cityNG[indC2] = city2[indC2]
  }
  
  doc2$City[indC] = cityNG
  
  # OBS: for all the entries that contains Romanian academy -> Bucharest
  
  
  # add the County and CountyCode columns 
  # -------------------------------------
  
  docCounty = read.csv("dataIn/Municipii/MunicipiiC3.csv", encoding = "UTF-8", stringsAsFactors = FALSE)
  
  MunCity = docCounty$City
  County = docCounty$County
  CountyCode = docCounty$CountyCode
  
  doc2$County = rep("", length(doc2$City))
  doc2$CountyCode = rep("", length(doc2$City))
  
  for (i in 1:length(MunCity)){
    indCounty = which(str_detect(doc2$City, MunCity[i]))
    doc2$County[indCounty] = County[i]
    doc2$CountyCode[indCounty] = CountyCode[i]
  }
  
  
  # # Determine the department of each paper
  # #----------------------------------------
  # dept = c("dept", "department")
  # dept2 = paste(dept, collapse = "|")
  # 
  # department = unlist(lapply(doc2$Affiliations2, function(x){
  #   d = unlist(str_split(x, ","))
  #   sdept = str_detect(d, dept2)
  #   if (is.na(sum(sdept))|sum(sdept)==0){
  #     ""
  #   }else{
  #     a = d[sdept]
  #     a[1]
  #   }
  # }))
  # 
  # department = gsub("^ ", "", department) # remove the space from the begining of the department names 
  # 
  # # Determine the faculty of each paper
  # #----------------------------------------
  # fac = c("faculty", "centre", "center", "clinic", "museum", "station", "laboratory", "association", "rompan")
  # fac2 = paste(fac, collapse = "|")
  # 
  # faculty = unlist(lapply(doc2$Affiliations2, function(x){
  #   f = unlist(str_split(x, ","))
  #   sfac = str_detect(f, fac2)
  #   if (is.na(sum(sfac))|sum(sfac)==0){
  #     ""
  #   }else{
  #     a = f[sfac]
  #     a[1]
  #   } 
  # }))
  # 
  # faculty = gsub("^ ", "", faculty) # remove the space from the begining of the department names 
  # 
  # 
  # # Determine the institution of each paper
  # #----------------------------------------
  # inst = c("univ", "academy", "institute", "agency", "s\\.a\\.", "s\\.c\\.", "hospital", "incd", "s\\.r\\.l\\.", "srl")
  # inst2 = paste(inst, collapse = "|")
  # 
  # institution = unlist(lapply(doc2$Affiliations2, function(x){
  #   instit = unlist(str_split(x, ","))
  #   sinst = str_detect(instit, inst2)
  #   if (is.na(sum(sinst))|sum(sinst)==0){
  #     ""
  #   }else{
  #     a = instit[sinst]
  #     a[1]
  #   } 
  # }))
  # 
  # institution = gsub("^ ", "", institution) # remove the space from the begining of the department names 
  # 
  # 
  # # Determine the institution type: university, research institute, hospital, firm, other
  # #---------------------------------------------------------------------------------------
  # 
  # institutionType = unlist(lapply(doc2$Affiliations2, function(x){
  #   
  #   instit = unlist(str_split(x, ","))
  #   
  #   # universities  
  #   univ.inst = str_detect(instit, "univ|facult")
  #   
  #   if (is.na(sum(univ.inst))|sum(univ.inst)==0){
  #     
  #     # research institutes
  #     ri.inst = str_detect(instit, "institute|incd|inst\\.|centre|station|nird.|institut.|research and development|i\\.n\\.c\\.d\\.")
  #     
  #     if (is.na(sum(ri.inst))|sum(ri.inst)==0){
  #       
  #       # academy
  #       acad.inst = str_detect(instit, "academy")
  #       
  #       if (is.na(sum(acad.inst))|sum(acad.inst)==0){
  #         
  #         # firms - companies
  #         firm.inst = str_detect(instit, "s\\.a\\.|s\\.c\\.|srl|s\\.r\\.l\\.|sc |comp\\.|holding")
  #         
  #         if (is.na(sum(firm.inst))|sum(firm.inst)==0){
  #           
  #           # hospital
  #           hospital.inst = str_detect(instit, "hospital")
  #           
  #           if (is.na(sum(hospital.inst))|sum(hospital.inst)==0){
  #             
  #             # centers, laboratories, agencies, etc.
  #             cent.inst = str_detect(instit, "agenc.|center |laborator.|group")
  #             
  #             if (is.na(sum(cent.inst))|sum(cent.inst)==0){
  #               "Other"
  #             }else{
  #               "Centers, laboratories"
  #             } 
  #             
  #           }else{
  #             "Hospitals"
  #           } 
  #           
  #         }else{
  #           "Companies"
  #         } 
  #         
  #       }else{
  #         "Romanian Academy"
  #       } 
  #       
  #     }else{
  #       "Research Institutes"
  #     } 
  #     
  #   }else{
  #     "Universities"
  #   } 
  #   
  # }))
  # 
  # # Add the department, faculty, institution and institution type columns
  # doc2$Department = department
  # doc2$Faculty = faculty
  # doc2$Institution = institution
  # doc2$InstitutionType = institutionType
  
  # Save the datasets 
  #============================
  
  # Save the datasets 
  
  write.csv(doc2, file = paste0("dataOut/", titleOut,".csv"), quote = TRUE, row.names = FALSE)
  
  table(doc2$City)
  
  # Return the data.frame
  #======================
  return(doc2)
}