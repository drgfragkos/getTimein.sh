# @drgfragkos 2019 ################################################################
# 
# getTimein.sh -- Shows the current time in the specified time zone or 
# geographic zone. Without any argument, this shows UTC/GMT. 
# Use the word "list" to see a list of known geographic regions.
# Note that it is possible to match zone directories (regions),
# but that only time zone files (cities) are valid specifications.
# 
# The initial idea for the code for this script was found in the book Wicked Cool 
# Shell Scripts. There were a few mistakes in the original code which prevented it 
# from running succesfully. These have been corrected and the current version has 
# also been expanded to work under MacOS and use the 'say' feature. 
#
# Timezones can be found here: /usr/share/zoneinfo/
# For a list of timezones you can type: sudo systemsetup -listtimezones
# If a particular city is not listed (e.g. under /usr/share/zoneinfo/Europe/ for 
# Germany the capital Berlin already exists, while Munich is not present). 
# In that case, copy the Berlin file and rename it to Munich. (Due to the fact that
# Berlin and Munich will always belong to the exact same timezone)
# 
# Each file is a C library. 
# To get the output of the file, you can use one of two commands; 'zdump' or 'file' (see examples below):
#  > zdump /usr/share/zoneinfo/America/New_York
#  > file /usr/share/zoneinfo/America/New_York
#
# Time zone database ref: 
# https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
#


Example:

./getTimein.sh Munich

