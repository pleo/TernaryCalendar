#!/bin/bash

#    This is a ternary calendar for an X window managers.
#    Copyright (C) 2012  Leon Pajk
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Convert a number to ternary trytes(base-3 number).
function number_to_ternary_tryte() {
  if [ "$#" -ne "1" ]
  then
      echo "Usage: ${FUNCNAME} number" >&2
      return
  fi
  
  local divisor=$1
  local quotient=0
  local tryte=""

  while (true)
  do
      quotient=$((divisor % 3))
      divisor=$(printf "%.0f" $((divisor / 3)))
      
      if [ "${quotient}" -eq "0" ]
      then
          tryte="0${tryte}"
      elif [ "${quotient}" -eq "1" ]
      then
          tryte="+${tryte}"
      else
          tryte="-${tryte}"
          divisor=$((divisor += 1))
      fi
      
      if [ "${divisor}" -lt "3" ]
      then
          if [ "${divisor}" -eq "0" ]
          then
              tryte="0${tryte}"
          elif [ "${divisor}" -eq "1" ]
          then
              tryte="+${tryte}"
          else
              tryte="+-${tryte}"
          fi
          break;
      fi
  done
  
  local tryte_length="${#tryte}"
  if [ "${tryte_length}" -lt "4" ]
  then
      local i
      for ((i="${tryte_length}"; i<4; i++))
      do
        tryte="0${tryte}"
      done
  fi
  echo "${tryte}"
}

export -f number_to_ternary_tryte

PROGRAM='dzen2'
if pgrep $PROGRAM > /dev/null
then
    killall $PROGRAM
else

TODAY=`date +'%d'`
TODAY3=$(number_to_ternary_tryte $TODAY)

MONTH=`date +'%m'`

YEAR=`date +'%Y'`
YEAR3=$(number_to_ternary_tryte $YEAR)
YEAR3PLUS1=$(number_to_ternary_tryte $(expr $YEAR + 1))

(echo '^bg(#111111)^fg(#3488DE)' \
`date +'%A'` "${TODAY3}" `date +'%B'` "${YEAR3}";
echo
\
# The current month, highlight first two lines and today date
  cal \
    | perl -ne '(($. == 3) # padding-left in the third line
                 ? ($a = $_, $_ =~ s/[^\d]+/,/g, $l = split(/,/, $_),
                    $b = "x" x (4 + 6 * (7 - $l)), print "$b$a")
                 : print "$_")' \
    | sed -re 's/^/   /' \
    | sed -rn 's/([0-9a-zA-Z]+)/echo "\1"/g;p' \
    | sed -rn 's/([0-9]+)/$(number_to_ternary_tryte \1)/g;p' \
    | bash \
    | sed 's/echo//g' \
    | sed -e '1,2s/^\(.*[A-Za-z][A-Za-z]*.*\)$/^fg(#3488DE)^bg(#111111)\1/' \
    | sed -re "s/(^|[ ])(${TODAY3//+/\+})($|[ ])/\1^bg(#3488DE)^fg(#111111)\2^fg(#6c6c6c)^bg(#111111)\3/" \
    | sed -re '2s/ /  /g' \
    | sed -re 's/^/   /' \
    | sed -re '1s/ /              /' \
    | sed -re '2s/ /  /' \
    | sed -re '3s/x/ /g'

# The newline separator
echo

# The next month, highlight first two lines
[ $MONTH -eq 12 ] && YEAR=$(($YEAR + 1))
cal `expr $MONTH % 12 + 1` $YEAR \
    | perl -ne '(($. == 3) # padding-left in the third line
                 ? ($a = $_, $_ =~ s/[^\d]+/,/g, $l = split(/,/, $_),
                    $b = "x" x (4 + 6 * (7 - $l)), print "$b$a")
                 : print "$_")' \
    | sed -rn 's/([0-9a-zA-Z]+)/echo "\1"/g;p' \
    | sed -rn 's/([0-9]+)/$(number_to_ternary_tryte \1)/g;p' \
    | bash \
    | sed 's/echo//g' \
    | sed -e '1,2s/^\(.*[A-Za-z][A-Za-z]*.*\)$/^fg(#3488DE)^bg(#111111)\1/' \
    | sed -re '2s/ /  /g' \
    | sed -re 's/^/   /' \
    | sed -re '1s/ /              /' \
    | sed -re '2s/ /  /' \
    | sed -re '3s/x/ /g'
) \
    | dzen2 -p -fg '#6c6c6c' -bg '#111111' \
            -fn '-*-fixed-*-*-*-*-12-*-*-*-*-*-*-*' \
            -x 0 -y 0 \
            -w 274 -l 17 \
            -e 'onstart=uncollapse;key_Escape=ungrabkeys,exit'
fi

# EOF
