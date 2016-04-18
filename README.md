# ArchivesSpace Instance Joiner Plugin

This plugin will take all resource and archival_object records and glue all
their instances together.

# Why? 

EAD does not have the concept of an instance, and for awhile the EAD importer
took container tags in the EAD and created multiple instances, instead of a
single instance with multiple container values. 

## To Install:

Download and unpack the plugin to your ArchivesSpace plugins directory
Add "instance_joiner" to your config/config.rb AppConfig[:plugins] list
Restart ArchivesSpace

## To Use:
Logged in as a repository administrator, go to Plugins --> Instance Joiner. 
Click submit and all the records in the selected repository will be modified.

