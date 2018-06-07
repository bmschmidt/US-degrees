# US-degrees
Notebook for looking at 35 years of historical US degrees data from NCES-IPEDS. Thrown up with no attempt to clean things.

Data downloaded from the IPEDS series of the National Center for Education Statistics. Ones ending with '.txt' are pre-cleaned.

Primary exploration file called 'bookworming.Rmd' for elusive reasons.
Past about halfway through, the blocks are all legacy code from 2016 that won't run.

Tidying done in 'read_cips.R' (also not really the right name for the file).

Data is encoded. Information about majors is in `adjusted CIPS.csv`; information about institutions is in `hd2017.csv`.

Because parsing the individual year data files takes a while, `read_cips.R` creates intermediate `.feather` files to load on subsequent runs.
