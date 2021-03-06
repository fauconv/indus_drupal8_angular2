#!/bin/bash
#+-----------------------------------------------------------+
#|                                                           |
#| DCF Manager                                               |
#|                                                           |
#| Batch to Manage the entire multi-site/farm/factory/project|
#|                                                           |
#+-----------------------------------------------------------+
#| version : VERSION_SCRIPT                                  |
#+-----------------------------------------------------------+

#paths and init
SOURCE_PATH='dcf'
SOURCE_SCRIPT='path.sh'
SCRIPT_NAME=$(basename $0)
ABS_SCRIPT_PATH=$(dirname `readlink -e $0`);
if [ "$ABS_SCRIPT_PATH" = "" ]; then
  ABS_SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)
fi
if [ ! -f "${ABS_SCRIPT_PATH}/${SOURCE_PATH}/${SOURCE_SCRIPT}" ]; then
  echo ""
  echo -e "\e[31m\e[1mDCF is not correctly installed\e[0m"
  echo ""
  exit 1
fi
source ${ABS_SCRIPT_PATH}/${SOURCE_PATH}/${SOURCE_SCRIPT}
source ${ABS_SCRIPT_PATH}/${SOURCE_PATH}/deploy.sh
source ${ABS_SOURCE_PATH}/site_deploy.sh
source ${ABS_SOURCE_PATH}/site_back.sh
source ${ABS_SOURCE_PATH}/site_remove.sh
source ${ABS_SOURCE_PATH}/list.sh
source ${ABS_SOURCE_PATH}/site_dump.sh
if [ -f ${ABS_SCRIPT_PATH}/${SOURCE_PATH}/env ]; then
  source ${ABS_SCRIPT_PATH}/${SOURCE_PATH}/env
fi
cd ${ABS_ROOT_PATH}

#
# display help
#
function showHelp {
  echo ""
  echo " Drupal Custom Factory Manager Version ${VERSION_SCRIPT}"
  echo ""
  echo " = Usage :"
  echo " ========="
  echo "  commands about the entire farm:"
  echo "  -------------------------------"
  echo ""
  echo "  ${SCRIPT_NAME} deploy (dev|prod) : deploy or update DCF -> get or update DCF composer packages for "
  echo "                                     the project and set project name."
  echo "                                     => need internet access"
  echo "  ${SCRIPT_NAME} list              : list all web-site (site-id) in this project"
  echo "  ${SCRIPT_NAME} update            : update and rebuild all web-site in production or dev "
  echo "  ${SCRIPT_NAME} set (dev|prod)    : the file right protection. dev => all file writable"
  echo ""
  echo "  commands about a site of the farm:"
  echo "  ----------------------------------"
  echo ""
  echo "  ${SCRIPT_NAME} site deploy <site_id>   : create or install (if already exist) a web-site in the "
  echo "                                          project for development (drupal install)"
  echo "                                          => you must set <ID>${LOCAL_CONF} and <ID>${GLOBAL_CONF} before."
  echo "  ${SCRIPT_NAME} site remove <site-id>   : remove an web-site (installed or not)"
  echo "  ${SCRIPT_NAME} site update <site-id>   : update and rebuild a web-site in production or dev"
  echo "  ${SCRIPT_NAME} site back <site-id> [file] : site configuration and data go back before the last snapshot."
  echo "                                              if a file is specified, the script use that file as snapshot instead of the last snapshot"
  echo "                                              The file must be in dump directory"
  echo "  ${SCRIPT_NAME} site snapshot <site-id> : make a snapshot (backup) of the site to go back to this point later"
  echo ""
  echo " = More help :"
  echo " ============="
  echo "  Read install.md in \"docs\" directory for more information"
  echo ""
  echo ""
  exit 1
}

#
#
# check site exist
#
validate_exist() {
  if [ -e ${ABS_CONFIG_PATH}/settings-${DIR_NAME}.php ]; then
    echo -e "This site is already installed                                        \e[31m\e[1m[fail]\e[0m"
    exit 1
  fi
}

#
#set access right
#
function setRight {
  if [ "$1" = "prod" ]; then
    chmod -R 550 ${ABS_ROOT_PATH} ${ABS_ROOT_PATH}/*
    for f in ${ABS_MEDIAS_PATH}/*; do
      chmod -R 770 ${f} ${f}/*
    done
  else
    chmod -R 770 ${ABS_ROOT_PATH} ${ABS_ROOT_PATH}/*
  fi
}

#
# check Composer exist
#
function checkConposer {
  echo "CheckComposer:"
  if [ ! -f "${ABS_SCRIPTS_PATH}/composer.phar" ]; then
    cd ${ABS_SCRIPTS_PATH}
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php composer-setup.php
    rm composer-setup.php
  else
    echo "Composer self install OK"
  fi
}

#
#update index.php
#
function setIndex {
  cd ${ABS_DOCUMENT_ROOT}
  if [ "$1" = "dev" ]; then
    sed "s|prod|dev|" index.php > index.php2
  else 
    sed "s|dev|prod|" index.php2 > index.php
  fi
  rm index.php
  mv index.php2 index.php
}

#
# check php exist and accessible
#
function checkPhp {
  echo "CheckPhp:"
  if command -v php &>/dev/null; then
    echo "PHP detected"
  else
    echo -e "\e[31m\e[1mPHP absent or unreachable\e[0m"
    exit 1
  fi
}

#
#
#
function displaytime {
  runtime=$((end-start))
  res=`date --date="@${runtime}" +%M\'%S`
  echo ""
  echo -e "script executed in \e[32m\e[1m${res}\e[0m"
}

#
# main
#
start=`date +%s`
if [ "$1" = "" ]; then
    showHelp
fi
checkPhp
while true; do
  case $1 in
    deploy )
      deploy "$2"
      shift;
      ;;
    set )
      setRight "$2"
      shift;
      ;;
    list )
      list
      ;;
    site )
      if [ "$3" = "" ]; then
        echo ""
        echo -e "\e[31m\e[1mSite id missing !\e[0m"
        showHelp;
      fi
      ID=`echo $3 | sed 's|[^a-z]+||g'`
      if [ "$ID" = "" ]; then
        echo ""
        echo -e "\e[31m\e[1mSite id can only contain lowercase !\e[0m"
        echo ""
        exit 1
      fi
      SITE_PATH=${SITES_PATH}/$ID
      ABS_SITE_PATH=${ABS_SITES_PATH}/$ID
      ABS_MEDIA_PATH=${ABS_MEDIAS_PATH}/$ID
      case $2 in
        deploy )
          site_deploy
          shift;
          ;;
        dump )
          dump
          shift;
          ;;
        remove )
          site_remove
          shift;
          ;;
        back )
          site_back $4
          shift;
          ;;
        * )
          echo ""
          echo -e "\e[31m\e[1mUnknown command : $1 $2 !\e[0m"
          showHelp
          ;;
      esac
      shift;
      ;;
    "")
      break
      ;;
    * )
      echo ""
      echo -e "\e[31m\e[1mUnknown command : $1 !\e[0m"
      showHelp
      break
      ;;
  esac
  shift;
done
end=`date +%s`
displaytime
echo ""
exit 0
