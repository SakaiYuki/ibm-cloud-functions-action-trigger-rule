#!/bin/bash
#
# Copyright 2016-2018 IBM Corp. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the “License”);
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an “AS IS” BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

function usage() {
  echo -e "Usage: $0 [--install,--uninstall]"
}

function install() {
  ibmcloud fn action create handler handler.js

  ibmcloud fn trigger create every-20-seconds \
    --feed  /whisk.system/alarms/alarm \
    --param cron '*/20 * * * * *' \
    --param stopDate `date +%s%3N -d'5min'`

  ibmcloud fn rule create \
    invoke-periodically \
    every-20-seconds \
    handler
}

function uninstall() {
  ibmcloud fn rule disable invoke-periodically
  ibmcloud fn rule delete invoke-periodically
  ibmcloud fn trigger delete every-20-seconds
  ibmcloud fn action delete handler
}

case "$1" in
"--install" )
install
;;
"--uninstall" )
uninstall
;;
* )
usage
;;
esac
