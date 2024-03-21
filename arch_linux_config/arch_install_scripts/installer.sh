#!/usr/bin/bash
_dir=$1
_config=$_dir/user_configuration.json
_creds=$_dir/user_credentials.json
archinstall --config $_config --creds $_creds
#echo $_config
#echo $_creds
