library(tidyverse)

return_data = function() {
  
  variable_fields = 
    read.csv("variable_fields_crosswalk.csv") %>% 
    gather(oldness,counttype,-label) %>%
    filter(!is.na(counttype))
  
  goodnames = c("UNITID","CIPCODE","MAJORNUM","AWLEVEL",variable_fields$counttype)
  total_fields = c("CTOTALM", "CTOTALW", "CRACE15", "CRACE16")
  
  read_completions = function(filename) {
    
    newfile = paste0(filename, ".feather")
    if (file.exists(newfile)) {
      library(feather)
      return(read_feather(newfile))
    }
    message(filename)
    y2015 = 
      read_csv(filename, col_types = cols())
    names(y2015) = toupper(names(y2015))
    y2015 = y2015 %>% filter(CIPCODE != "99", CIPCODE != "99.0000")
    
    if (!"MAJORNUM" %in% names(y2015)) {
      y2015$MAJORNUM = 1
    }
    y2015 = y2015[,colnames(y2015) %in% goodnames]
    
    output2 = y2015 %>% mutate(AWLEVEL=as.character(AWLEVEL))
    gathered = output2 %>% 
      gather(counttype,degrees,-UNITID,-CIPCODE,-MAJORNUM,-AWLEVEL) %>%
      mutate(degrees = as.numeric(degrees)) %>%
      filter(!is.na(degrees)) %>% 
      filter(degrees>0)
    provisional = gathered %>% 
      inner_join(variable_fields) %>% 
      separate(label,c("race","gender"),"_") %>% select(-counttype)
    unknowns = provisional  %>%
      group_by(UNITID, CIPCODE, MAJORNUM, AWLEVEL, gender) %>% 
      summarize(degrees = sum(2*degrees[race=="All"] - sum(degrees))) %>%
      ungroup %>%
      filter(degrees > 0) %>%
      mutate(race="Unknown")
    
    totals = provisional %>% filter(race!="All") %>% bind_rows(unknowns)
    totals %>% group_by(race, gender) %>% tally(degrees)  
    library(feather)
    write_feather(totals, newfile)
    totals
  }
  
  data = 
    data_frame(filename = list.files()) %>% 
    filter(grepl("c[0-9]{4}(_a).*.csv",filename)) %>% 
    mutate(year = gsub(".*([0-9]{4}).*","\\1",filename)) %>% 
    # Take only the first file for each year--ie, the revised one.
    group_by(year) %>% 
    arrange(year, filename) %>% slice(1) %>%
    group_by(year,filename) %>% do(
      read_completions(.$filename[1])
    )
  
  older = data_frame(filename = list.files()) %>% 
    filter(grepl("19...txt",filename)) %>%
    mutate(year=as.numeric(gsub(".txt","",filename))) %>%
    filter(!year %in% data$year) %>%
    group_by(year,filename) %>%
    do(read_tsv(.$filename[1],
                col_names = c("CIPCODE","LEVEL","year","UNITID","counttype","degrees"),
                col_types = "ciiici" )) %>%
    mutate(MAJORNUM=1) %>% 
    inner_join(variable_fields) %>% separate(label,c("race","gender"),"_")
  
  data %<>% ungroup %>% mutate(year = as.numeric(year))
  output = data %>% bind_rows(older) %>% mutate(AWLEVEL=ifelse(is.na(AWLEVEL),LEVEL,AWLEVEL))
  
}

return_cips = function() {
  fix_nums = . %>% 
    gsub('["=]','',.) %>%
    #gsub("(\\.)$","\\10000",.) %>%
    #gsub("(\\...)$","\\100",.) %>%
    gsub("^([0-9]+$)","\\1.",.) %>% 
    gsub("^([0-9]\\.)","0\\1",.)
  
  add_deprecated_rows = function(new,old) {
    old_label = names(old)[1]
    names(old) = c("previous","CIPCode")
    old = old %>% mutate(previous = fix_nums(previous),CIPCode = fix_nums(CIPCode))
    
    obsolete_codes = old %>% 
      filter(previous!=CIPCode) %>% 
      filter(!is.na(previous)) %>%
      left_join(new) %>% 
      mutate(CIPCode=previous) %>%
      select(-previous)
    
    bind_rows(new,obsolete_codes)
  }
  
  cips = read_csv("Adjusted CIPS.csv",col_types="ccccccccc") %>% 
    mutate(CIP2010 = fix_nums(CIPCode)) %>%
    mutate(CIPCode = fix_nums(CIPCode))
  cipsold1 = read_csv("Crosswalk2000to2010 (1).csv",col_types="c___c_",col_names=c("CIP2000","CIPCode"),skip=1)
  cipsold2 = read_csv("1990to2000XWalk.csv",col_types="c_c_",col_names=c("CIP1990","CIPCode"))
  cipsold3 = read_csv("1985to1990XWalk.csv",col_types="c_c_",col_names=c("CIP1985","CIPCode"))
  
  full_x_walk = cips %>% 
    add_deprecated_rows(cipsold1) %>% 
    add_deprecated_rows(cipsold2) %>% 
    add_deprecated_rows(cipsold3)
  
  # CIPCodes that are split are assigned to the first 2010 entry.
  cips = full_x_walk %>% 
    filter(!grepl("Moved from", CIPDefinition)) %>%
    group_by(CIPCode) %>% 
    slice(1)
}

cips_forward = function() {
  return_cips = function() {
    fix_nums = . %>% 
      gsub('["=]','',.) %>%
      #gsub("(\\.)$","\\10000",.) %>%
      #gsub("(\\...)$","\\100",.) %>%
      gsub("^([0-9]+$)","\\1.",.) %>% 
      gsub("^([0-9]\\.)","0\\1",.)
    
    add_deprecated_rows = function(new,old) {
      old_label = names(old)[1]
      names(old) = c("previous","CIPCode")
      old = old %>% mutate(previous = fix_nums(previous),CIPCode = fix_nums(CIPCode))
      
      obsolete_codes = old %>% 
        filter(previous!=CIPCode) %>% 
        filter(!is.na(previous)) %>%
        left_join(new) %>% 
        mutate(CIPCode=previous) %>%
        select(-previous)
      
      bind_rows(new,obsolete_codes)
    }
    
    cips = read_csv("Adjusted CIPS.csv",col_types="ccccccccc") %>% 
      mutate(CIP2010 = fix_nums(CIPCode)) %>%
      mutate(CIPCode = fix_nums(CIPCode))
    cipsold1 = read_csv("Crosswalk2000to2010 (1).csv",col_types="c___c_",col_names=c("CIP2000","CIPCode"),skip=1)
    cipsold2 = read_csv("1990to2000XWalk.csv",col_types="c_c_",col_names=c("CIP1990","CIPCode"))
    cipsold3 = read_csv("1985to1990XWalk.csv",col_types="c_c_",col_names=c("CIP1985","CIPCode"))
    
    full_x_walk = cips %>% 
      add_deprecated_rows(cipsold1) %>% 
      add_deprecated_rows(cipsold2) %>% 
      add_deprecated_rows(cipsold3)
    
    # CIPCodes that are split are assigned to the first 2010 entry.
    cips = full_x_walk %>% 
      filter(!grepl("Moved from", CIPDefinition)) %>%
      group_by(CIPCode) %>% 
      slice(1)
  }
}