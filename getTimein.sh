#!/bin/bash

## getTimein.sh - @drgfragkos 2019 - Released under: GNU GENERAL PUBLIC LICENSE v3.0 ##############
##                                                                                               ##
## getTimein.sh -- Shows the current time in the specified time zone or geographic zone.         ##
## Without any argument, this shows UTC/GMT. Use the word "list" to see a list of known          ##
## geographic regions. Note that it is possible to match zone directories (regions), but that    ##
## only time zone files (cities) are valid specifications.                                       ##
## Note: You can use 'list' for all available timezone options: ./getTimein.sh list              ##
##                                                                                               ##
## The initial idea for the code for this script was found in the book Wicked Cool Shell Scripts.##
## There were a few mistakes in the original code which prevented it from running succesfully.   ##
## These have been corrected and the current version has also been expanded to work under MacOS  ##
## and use the 'say' feature.                                                                    ##
##                                                                                               ##
## You may modify, reuse and distribute the code freely as long as it is referenced back         ##
## to the author using the following line: ..based on getTimein.sh by @drgfragkos                ##
##                                                                                               ##
## Timezones can be found here: /usr/share/zoneinfo/                                             ##
## For a list of timezones you can type: sudo systemsetup -listtimezones                         ##
## If a particular city is not listed (e.g. under /usr/share/zoneinfo/Europe/ for                ##
## Germany the capital Berlin already exists, while Munich is not present).                      ##
## In that case, copy the Berlin file and rename it to Munich. (Due to the fact that Berlin and  ##
## Munich will always belong to the exact same timezone)                                         ##
##                                                                                               ##
## Each file is a C library.                                                                     ##
## To get the output of the file, you can use one of two commands; 'zdump' or 'file' :           ##
##  > zdump /usr/share/zoneinfo/America/New_York                                                 ##
##  > file /usr/share/zoneinfo/America/New_York                                                  ##
##                                                                                               ##
## Time zone database ref:                                                                       ##
## https://en.wikipedia.org/wiki/List_of_tz_database_time_zones                                  ##
##                                                                                               ##
## ANSI escape codes: https://en.wikipedia.org/wiki/ANSI_escape_code                             ##
## - https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux ##
## - http://ascii-table.com/ansi-escape-sequences-vt-100.php                                     ##
##                                                                                               ##
###################################################################################################
##                                                                                               ##
## Set Color values to use and the No Color value #################################################
##  Black        0;30     Dark Gray     1;30
##  Red          0;31     Light Red     1;31
##  Green        0;32     Light Green   1;32
##  Brown/Orange 0;33     Yellow        1;33
##  Blue         0;34     Light Blue    1;34
##  Purple       0;35     Light Purple  1;35
##  Cyan         0;36     Light Cyan    1;36
##  Light Gray   0;37     White         1;37
##
RED='\033[0;31m'        # e.g. ${RED} $text ${NC}
NC='\033[0m'            # No Color
##
## Set Bold values to use #########################################################################
## The possible integers are:
##   0 - Normal Style     # will cancel any color settings used
##   1 - Bold
##   2 - Dim
##   3 - Italic
##   4 - Underlined
##   5 - Blinking
##   7 - Reverse       # Back color / highlighter
##   8 - Invisible        
##
BoldON="\033[1m"             # ${BoldON}
BoldOFF="\033[0m"            # ${BoldOFF}  
##
###################################################################################################
###################################################################################################


zonedir="/usr/share/zoneinfo"

if [ ! -d $zonedir ] ; then
  echo "No time zone database at $zonedir." >&2 ; exit 1
fi

if [ -d "$zonedir/posix" ] ; then
  zonedir=$zonedir/posix        # modern Linux systems
fi

if [ $# -eq 0 ] ; then
  timezone="UTC"
  mixedzone="UTC"
elif [ "$1" = "list" ] ; then
  ( echo "All known time zones and regions defined on this system:"
    cd $zonedir
    find -L * -type f -print | xargs -n 2 | awk '{ printf "  %-38s %-38s\n", $1, $2 }' 
  ) | more
  exit 0
else

  region="$(dirname $1)"
  zone="$(basename $1)"

  # Is the given time zone a direct match? If so, we're good to go. 
  # Otherwise we need to dig around a bit to find things. Start by 
  # just counting matches.

  matchcnt="$(find -L $zonedir -name $zone -type f -print | wc -l | sed 's/[^[:digit:]]//g' )"

  # Check if at least one file matches
  if [ "$matchcnt" -gt 0 ] ; then
    # But exit if more than one file matches
    if [ $matchcnt -gt 1 ] ; then
      echo "\"$zone\" matches more than one possible time zone record." >&2
      echo "Please use 'list' to see all known regions and time zones" >&2
      exit 1
    fi
    match="$(find -L $zonedir -name $zone -type f -print)"
    mixedzone="$zone" 
  else # maybe we can find a matching time zone region, rather than a specific time zone
    # First letter capitalized, rest of word lowercase for region + zone
    mixedregion="$(echo ${region%${region#?}} | tr '[[:lower:]]' '[[:upper:]]')$(echo ${region#?} | tr '[[:upper:]]' '[[:lower:]]')"
    mixedzone="$(echo ${zone%${zone#?}} | tr '[[:lower:]]' '[[:upper:]]') $(echo ${zone#?} | tr '[[:upper:]]' '[[:lower:]]')"
    
    if [ "$mixedregion" != "." ] ; then
      # Only look for specified zone in specified region
      # to let users specify unique matches when there's more than one
      # possibility (e.g., "Atlantic")
      match="$(find -L $zonedir/$mixedregion -type f -name $mixedzone -print)"
    else
      match="$(find -L $zonedir -name $mixedzone -type f -print)"
    fi

    # If file exactly matched the specified pattern
    if [ -z "$match"  ] ; then
      # Check if the pattern was too ambiguous
      if [ ! -z $(find -L $zonedir -name $mixedzone -type d -print) ] ; then
         echo "The region \"$1\" has more than one time zone. " >&2
      else  # Or if it just didn't produce any matches at all
        echo "Can't find an exact match for \"$1\". " >&2
      fi
      echo "Please use 'list' to see all known regions and time zones." >&2
      exit 1
    fi
  fi
  timezone="$match"
fi

nicetz=$(echo $timezone | sed "s|$zonedir/||g")    # pretty up the output

clear

#### One line output ####
#echo It\'s $(TZ=$timezone date '+%A, %B %e, %Y, at %l:%M %p') in $nicetz
#
####

### Alternative Output with Say, adjusted to be printed and sound better. ####
#
echo -e It\'s $(TZ=$timezone date '+%A, %e %B %Y, %l:%M %p') in ${RED}${BoldON}$1${BoldOFF}${NC}             #Formated for better-looking printed output

#rAlt="In  $nicetz  it's  $(TZ=$timezone date '+%A, %e %B %Y, %l:%M %p')"                                    #Another option for printing the output
#echo $rAlt

if [[ "$OSTYPE" == "darwin"* ]]; then                                                                        #Check for MacOS to use the 'say' feature
  #echo -e $OSTYPE
  say "In $1 it's $(TZ=$timezone date '+%A, %e of %B %Y, %l:%M %p')"                                         #Formated for saying it a bit more natural
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
  echo -e $OSTYPE
  #in case you want to use a text-to-speak command (like eSpeak or similar) under Linux
  #add your text-to-speach command here#
elif [[ "$OSTYPE" == "cygwin" ]]; then
  echo -e $OSTYPE
  # POSIX compatibility layer and Linux environment emulation for Windows
fi

exit 0

#                                                                                                 #
###################################################################################################
###################################################################################################

