cacti-ejabberd
==============

Cacti Templates for ejabberd

Using these templates you can monitor several performance metrics of your ejabberd server.

    * Connected Users
    * Registered Vhosts
    * Server-to-Server Connections
    * ejabberd Memory Usage (RSS/VSZ)
    * ejabberd Threads
    * ejabberd Open Files
    * epmd Threads
    * epmd Open Files
    * epmd Memory Usage (RSS/VSZ)
    * Active Users per vhost
    * Registered Users per vhost

If you want to graph you ejabberd server running on the same host as your cacti system you can use the files in
the folder "script-based". If you want to graph a ejabberd server on a remote host you should use the files in
the folder "snmp-based".

If you use the snmp-based files you have to add the following code to your snmpd.conf file:

```
extend   ejabberd_stats       /var/www/localhost/htdocs/cacti/scripts/ejabberd_stats.sh cacti
extend   ejabberd_vhost_stats_index       /var/www/localhost/htdocs/cacti/scripts/snmp_ejabberd_vhost_stats.sh index
extend   ejabberd_vhost_stats_vhosts      /var/www/localhost/htdocs/cacti/scripts/snmp_ejabberd_vhost_stats.sh query vhosts
extend   ejabberd_vhost_stats_active_users   /var/www/localhost/htdocs/cacti/scripts/snmp_ejabberd_vhost_stats.sh query active_users
extend   ejabberd_vhost_stats_user_regs   /var/www/localhost/htdocs/cacti/scripts/snmp_ejabberd_vhost_stats.sh query user_regs
```

