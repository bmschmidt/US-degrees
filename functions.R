library(plyr)

readIPEDS = function(year) {
  message("reading ",year)
  files = list.files("~/Dropbox/degreeData/raw/",full.names=T)
  file = files[grep(year,files)]
  if (length(file)==0) {
    file =  files[grep(substr(paste0(as.character(year),"_"),3,5),files)]
  }
  file = file[grep("csv",file)]
  file = file[grep("ic",file,invert=T)]
  file = file[grep("hd",file,invert=T)]
  file = file[grep("rv",file,invert=T)]
  totals =  read.csv(file,stringsAsFactors=F)
  totals$YEAR = year
  head(totals)
  names(totals) = toupper(names(totals))
  totals = (totals[,names(totals) %in% c("UNITID","CIPCODE","MAJORNUM","AWLEVEL","YEAR","CTOTALT","CTOTALM","CTOTALF","CRACE15","CRACE16")])
  totals$TOTAL = yearFrameTotal(totals)
  library(reshape2)
  if ("MAJORNUM" %in% names(totals)) {
    tot = melt(totals,id.vars = c("CIPCODE","AWLEVEL","YEAR","UNITID","MAJORNUM")) 
    } else {
      tot = melt(totals,id.vars = c("CIPCODE","AWLEVEL","YEAR","UNITID"))
    }
  tot$CIPCODE[tot$CIPCODE > 100] = tot$CIPCODE[tot$CIPCODE > 100]/10000
  return(tot)
}
#f = (readIPEDS(1985))

yearFrameTotal = function(frame) {
  if ("CTOTALT" %in% names(frame)) {return (frame$CTOTALT)}
  if ("CRACE15" %in% names(frame)) {return(frame$CRACE15+frame$CRACE16)}
}



treemapFormat = function(data=data[as.character(data$AWLEVEL)=="5" & data$MAJORNUM==1,],fields=c("two","four","six"),countField="total") {
  reduce = function(frame,classes) {
    #This takes a frame and any remaining classes, and breaks it into a suitable form for Bostock's D3 table.
    if(length(classes)==1) {
      return(unname(dlply(frame,classes[1],function(frame2) {
        return(list(
          name=as.character(frame2[[classes[1]]][1]),
          value = frame2[[countField]][1]))})))
    } else {
      return(
        unname(dlply(frame,classes[1],function(frame2) {
          list("name" = frame2[[classes[1]]][1],
               "children" =     (reduce(frame2,classes[2:length(classes)]))
          )})))
      
    }
  }
  
  require(rjson)
  vals = reduce(totals,fields)
  outer = list(name="All Degrees","children"=vals)
  values = (toJSON(outer))
  return(values)
}


alignCodebooks = function(totals,codes) {
  
  totals$code = as.character(totals$CIP)
  
  totals$code[as.numeric(totals$code)<10]=paste("0",totals$code[as.numeric(totals$code)<10],sep="")
  codes$code = gsub("=","",codes$CIPCode)
  totals$two = codes$CIPTitle[match(substr(totals$code,1,2),codes$code)]
  totals$four = codes$CIPTitle[match(substr(totals$code,1,5),codes$code)]
  totals$title = codes$CIPTitle[match(totals$code,codes$code)]       
  
  #Special Supercategory
  totals$class = "Other"
  
  totals$class[substr(totals$code,1,2) %in% c(16,24,30,50,38,23,39,"05")] = "Humanities"
  totals$class[substr(totals$code,1,2) %in% c(42,45,54)] = "Social Sciences and History"
  totals$class[substr(totals$code,1,2) %in% c(52)] = "Business"
  totals$class[substr(totals$code,1,2) %in% c(27,40,26,41)] = "Natural Sciences"
  totals$class[substr(totals$code,1,2) %in% c(13)] = "Education"
  totals$class[substr(totals$code,1,2) %in% c(11,14,15)] = "Computer Sciences and Engineering"
  return(totals)
}
