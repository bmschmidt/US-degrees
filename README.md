# US-degrees

This is a notebook for looking at 35 years of historical US degrees
data from NCES-IPEDS.

Initial exploration for the blog post
[here](http://sappingattention.blogspot.com/2018/07/mea-culpa-there-is-crisis-in-humanities.html)
is in the file `Bookworming.Rmd`.  The full-text and code for the
Atlantic article is in `Atlantic.Rmd`. That file does not contain the
file edits on the piece.

The taxonomy used here is a modified version of one developed by the
American Academy of Arts and Sciences for the Humanities Indicators. I
generally defer to their categories, but believe communications to be
in the social sciences (not humanities) and don't put "General
Studies" into the humanities bin. The precise taxonomy is in the
folder `AmacadCIPS.csv`, using the file `CIP-HI Crosswalk
(1987-pres)-Table 1.csv`. ([Direct Link](https://github.com/bmschmidt/US-degrees/blob/master/AmacadCIPS.csv/2%20CIP-HI%20Crosswalk%20(1987-pres)-Table%201.csv))
I have changed this file to include some disciplines for
non-humanities majors as well as to reflect my changed definition of the humanities.
You can examine the versioning history on it if you want to see my exact changes.

Data downloaded from the IPEDS series of the National Center for
Education Statistics. Ones ending with '.txt' are pre-cleaned.

Tidying done in 'read_cips.R' (also not really the right name for the
file).

A few dplyr functions are bundled into 'EDA_functions.R'.

`functions.R` is legacy code that was used to build the pre-1998 data.

Data is encoded. Information about majors is in `adjusted CIPS.csv`;
information about institutions is in `hd2017.csv`.

Because parsing the individual year data files takes a while,
`read_cips.R` creates intermediate `.feather` files to load on
subsequent runs. This will take up additional disk space.
