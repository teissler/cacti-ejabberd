#!/bin/bash
#
# Get ejabberd vhosts statistics for cacti
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

function usage() {
   echo -en "usage:\n\n"
   echo -en "$0 index\n"
   echo -en "$0 num_indexes\n"
   echo -en "$0 query {vhost,user_regs,active_users}\n"
   echo -en "$0 get {user_regs,active_users} vhost\n"
   exit 0
}

function registered_vhosts() {
   local ejabberdctl_cmd=registered_vhosts
   local result=$(${EJABBERDCTL} ${ejabberdctl_cmd} 2>/dev/null)
   echo "$result"
}

case $1 in
   "index")
      vhosts=$(registered_vhosts)
      for vhost in $vhosts
      do
         echo $vhost
      done
      ;;

   "num_indexes")
      result=$(registered_vhosts | wc -w)
      echo $result
      ;;

   "query")
      if [ "$2" == "user_regs" ] || [ "$2" == "active_users" ] || [ "$2" == "vhost" ]
      then
         vhosts=$(registered_vhosts)
         for vhost in $vhosts
         do
            if [ "$2" == "user_regs" ]
            then
               ejabberdctl_cmd=registered_users
               result=$(${EJABBERDCTL} ${ejabberdctl_cmd} ${vhost} 2>/dev/null | wc -l)
               echo "${vhost}:${result}"
            elif [ "$2" == "active_users" ]
            then
               ejabberdctl_cmd=connected_users
               result=$(${EJABBERDCTL} ${ejabberdctl_cmd} 2>/dev/null | egrep -i ".*@${vhost}/.*" | wc -l)
               echo "${vhost}:${result}"
            else
               echo "${vhost}:${vhost}"
            fi
         done
      else
         usage
      fi
      ;;

   "get")
      if [ "$3" == "" ]
      then
         usage
      fi
      if [ "$2" == "user_regs" ] || [ "$2" == "active_users" ]
      then
         vhosts=$(registered_vhosts)
         for vhost in $vhosts
         do
            if [ "$3" != "$vhost" ]
            then
               continue
            fi
            if [ "$2" == "user_regs" ]
            then
               ejabberdctl_cmd=registered_users
               result=$(${EJABBERDCTL} ${ejabberdctl_cmd} ${vhost} 2>/dev/null | wc -l)
               echo "${result}"
            else
               ejabberdctl_cmd=connected_users
               result=$(${EJABBERDCTL} ${ejabberdctl_cmd} 2>/dev/null | egrep -i ".*@${vhost}/.*" | wc -l)
               echo "${result}"
            fi
         done
      else
         usage
      fi
      ;;

   *)
      usage
      ;;
esac

