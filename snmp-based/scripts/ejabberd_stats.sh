#!/bin/bash
#
# Get ejabberd statistics for cacti
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

#EJABBERDCTL_CFG="/etc/ejabberd/ejabberdctl.cfg"
EJABBERDCTL_CFG="/etc/jabber/ejabberdctl.cfg"

EJABBERDCTL=${EJABBERDCTL:-$(which ejabberdctl)}
EJABBERDCTL_CFG=${EJABBERDCTL_CFG:-/etc/ejabberd/ejabberdctl.cfg}
source $EJABBERDCTL_CFG 2>/dev/null

function connected_users() {
   local ejabberdctl_cmd=connected_users_number
   local result=$(${EJABBERDCTL} ${ejabberdctl_cmd} 2>/dev/null)
   echo "$result"
}

function s2s_stats() {
   local cmd=$1

   if [[ $cmd == "in" ]]
   then
      local ejabberdctl_cmd=incoming_s2s_number
   else
      local ejabberdctl_cmd=outgoing_s2s_number
   fi

   local result=$(${EJABBERDCTL} ${ejabberdctl_cmd} 2>/dev/null)
   echo "$result"
}

function registered_vhosts() {
   local ejabberdctl_cmd=registered_vhosts
   local result=$(${EJABBERDCTL} ${ejabberdctl_cmd} 2>/dev/null | wc -l)
   echo "$result"
}

function threads() {
   local process=$1

   if [[ $process == "epmd" ]]
   then
      echo "$[$(ps -L -p $(pidof epmd) | wc -l)-1]"
   else
      echo "$[$(ps -L -p $(<$EJABBERD_PID_PATH) | wc -l)-1]"
   fi
}

function memory() {
   local process=$1
   local memory_type=$2

   if [[ $process == "epmd" ]]
   then
      local pid=$(pidof epmd)
   else
      local pid=$(<${EJABBERD_PID_PATH})
   fi

   memory_value=$(ps -p $pid -o $memory_type= | tr -d ' ')
   let memory_value=$memory_value*1024
   echo "$memory_value"
}

function open_files() {
   local process=$1

   if [[ $process == "epmd" ]]
   then
      echo "$[$($(which lsof) -np $(pidof epmd) | wc -l)-1]"
   else
      echo "$[$($(which lsof) -np $(<$EJABBERD_PID_PATH) | wc -l)-1]"
   fi
}

case $1 in
   cacti)
      connected_users
      s2s_stats in
      s2s_stats out
      registered_vhosts
      threads ejabberd
      memory ejabberd rss
      memory ejabberd vsz
      open_files ejabberd
      threads epmd
      memory epmd rss
      memory epmd vsz
      open_files epmd
      ;;

   *)
      OUTPUT="connected_users:$(connected_users)"
      OUTPUT+=" incoming_s2s:$(s2s_stats in)"
      OUTPUT+=" outgoing_s2s:$(s2s_stats out)"
      OUTPUT+=" registered_vhosts:$(registered_vhosts)"
      OUTPUT+=" threads:$(threads ejabberd)"
      OUTPUT+=" rss:$(memory ejabberd rss)"
      OUTPUT+=" vsz:$(memory ejabberd vsz)"
      OUTPUT+=" open_files:$(open_files ejabberd)"
      OUTPUT+=" epmd_threads:$(threads epmd)"
      OUTPUT+=" epmd_rss:$(memory epmd rss)"
      OUTPUT+=" epmd_vsz:$(memory epmd vsz)"
      OUTPUT+=" epmd_open_files:$(open_files epmd)"

      echo $OUTPUT
      ;;
esac

