Clodo.ru - reboot
=================

Script to call API method to reboot your virtual server on Clodo.

clodo-reboot must be run by root only!



REQUIREMENTS
============

- curl
- awk
- bash



INSTALL
=======

Download file 'clodo-reboot', put it to /usr/local/sbin and change access modes to 500

    # wget --no-check-certificate -O /usr/local/sbin/clodo-reboot https://raw.github.com/vills/clodo-reboot/master/reboot.sh  
    # chmod 500 /usr/local/sbin/clodo-reboot

(you must be logged as root)



USAGE
=====

Create file ~/.clodo-reboot with such content:

    CLODO_USER="my_clodo_account"					# username at panel.clodo.ru
    CLODO_KEY="3021e68df9a7200135725c6331369a22"	# key to access Clodo API

Make sure access permissions on that file meet your security needs.

When you wish to reboot your server, just execute "clodo-reboot" at console.
