into_major_nums = . %>% 
  group_by(year, add = T) %>% 
  filter(!is.na(degrees)) %>%
  mutate(year_total=sum(degrees)) %>% 
  group_by(year,CIPCODE,year_total, add=T) %>%
  summarize(degrees = sum(degrees)) %>% 
  mutate(percent = degrees/year_total)

cipsjoin =  . %>% left_join(cips,by=c("CIPCODE"="CIPCode"))

amacad = read_csv("AmacadCIPS.csv/2 CIP-HI Crosswalk (1987-pres)-Table 1.csv") %>% select(-starts_with("X")) %>% mutate(CIPCODE = str_pad(CIPCODE, width = 7, pad = "0"))

f = amacad %>% inner_join(cips, by = c("CIPCODE" = "CIP2010"))

amadjusted = f %>% select(CIPCODE = CIPCode, Discipline, Bachelors, Doctoral)

acadjoin = . %>% left_join(amadjusted)
