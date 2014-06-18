#!/bin/bash
#
# Get ejabberd vhost statistics for cacti
#
#    Copyright (C) 2014  Timo Eissler (timo@teissler.de)
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

EJABBERDCTL=${ejabberdctl:-$(which ejabberdctl)}

function registered_vhosts() {
   local ejabberdctl_cmd=registered_vhosts
   local result=$(${EJABBERDCTL} ${ejabberdctl_cmd} 2>/dev/null)
   echo "$result"
}

case ${1} in
   "index")
      vhosts=$(registered_vhosts)

      i=0
      for vhost in $vhosts
      do
         i=$(( ${i} + 1 ))
         echo ${i}
      done
      ;;

   "num_indexes")
      result=$(registered_vhosts | wc -w)
      echo $result
      ;;

   "query")
      case ${2} in
         vhosts)
            registered_vhosts
            ;;
         active_users)
            for vhost in $(registered_vhosts)
            do
               ejabberdctl_cmd=connected_users
               result=$(${EJABBERDCTL} ${ejabberdctl_cmd} 2>/dev/null | egrep -i ".*@${vhost}/.*" | wc -l)
               echo "$result"
            done
            ;;
         user_regs)
            for vhost in $(registered_vhosts)
            do
               ejabberdctl_cmd=registered_users
               result=$(${EJABBERDCTL} ${ejabberdctl_cmd} ${vhost} 2>/dev/null | wc -l)
               echo "$result"
            done
            ;;
      esac
esac

