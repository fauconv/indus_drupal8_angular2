#!/bin/bash
#+-----------------------------------------------------------+
#|                                                           |
#| DCF Manager                                               |
#|                                                           |
#| Batch to Manage the entire multi-site/farm/factory/project|
#|                                                           |
#+-----------------------------------------------------------+
#| version : ${VERSION_SCRIPT}                               |
#+-----------------------------------------------------------+

#
# const
#
VERSION_SCRIPT="0.1.0"
DCF_URL=https://github.com/fauconv/dcf
DCF_TAG=master
DCF_URL_GIT=${DCF_URL}.git
DCF_URL_DOWNLOAD=${DCF_URL}/tarball/${DCF_TAG}


#dcf file names
LOCAL_CONF=.config.local.sh
EXAMPLE=example

#DCF paths
SCRIPT_NAME=$(basename $0)
ABS_SCRIPT_PATH=$(dirname `readlink -e $0`);
if [ "$ABS_SCRIPT_PATH" = "" ]; then
ABS_SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)
fi
IS_GET=false
if [ -f "${ABS_SCRIPT_PATH}/dcf/dcf_path" ]; then
  source ${ABS_SCRIPT_PATH}/dcf/dcf_path
  cd ${ABS_DCF_PATH}
else
  IS_GET=true
  cd $ABS_SCRIPT_PATH
fi
chmod 750 .

#admin user
ADMIN_NAME=developer
SITE_PROFIL=internet

#
# showHelp
#
function showHelp {
  echo ""
  echo "  Drupal Custom Factory Manager Version ${VERSION_SCRIPT}"
  echo ""
  echo "  = Usage :"
  echo "  ========="
  if [ "${IS_GET}" = "true" ]; then
    echo "    ${SCRIPT_NAME} get                                            : get DCF (project skeleton) from gitHub."
    echo "                                                                     => need git, or curl, or wget and internet access"
  else
    echo "    ${SCRIPT_NAME} deploy (dev | prod) <name> [description]        : deploy or update DCF -> get or update DCF composer packages for the project and set project name."
    echo "                                                                     => need internet access"
    echo "    ${SCRIPT_NAME} site deploy (dev | prod) <site_id>              : create or install (if already exist) a web-site in the project for development (create skeleton + install packages(composer, npm, build) + install drupal)"
    echo "                                                                     If --intranet is set, intranet profil is used, else internet profil is used."
    echo "    ${SCRIPT_NAME} site rebuild (dev | prod) <site-id>             : compil and build a site for frontend in development"
    echo "    ${SCRIPT_NAME} site fix <site-id>                              : Fix packages version (composer and npm) used for this site, usefull for production server, avoid unwanted update of package"
    echo "    ${SCRIPT_NAME} site unfix <site-id>                            : Unfix packages version (composer and npm) used for this site, usefull to try update website package in development"
    echo "    ${SCRIPT_NAME} fix                                             : as \"site fix\" but for the common packages of the project"
    echo "    ${SCRIPT_NAME} unfix                                           : as \"site unfix\" but for the common packages of the project"
    echo "    ${SCRIPT_NAME} list                                            : list all web-site (site-id) in this project"
    echo "    ${SCRIPT_NAME} site remove <site-id>                           : remove an web-site (installed or not)"
    echo "    ${SCRIPT_NAME} package                                         : create a package for deployment in production of a project without web-site."
    echo "    ${SCRIPT_NAME} site package <site-id>                          : create a package for deployment in production of a specific web-site"
    echo "    ${SCRIPT_NAME} update                                          : update and rebuild all web-site in production or dev "
    echo "    ${SCRIPT_NAME} site update <site-id>                           : update and rebuild a web-site in production or dev"
  fi
  echo ""
  echo "  = More help :"
  echo "  ============="
  echo "  Read install.md in \"docs\" directory for more information"
  echo ""
  echo ""
  exit 1
}

#
# check CUrl exist
#
function trycurl {
  if ! command -v curl >/dev/null 2>&1; then
    trywget
    return
  fi
  curl -sL $DCF_URL_DOWNLOAD | tar xz
  RETURN=$?
  if [ ! $RETURN = 0 ]; then
    echo ""
    echo -e "\e[31m\e[1mInstallation fail, curl cannot retrive component! Check your internet connection or try again later\e[0m"
    exit
  fi
  mv *-dcf*/* *-dcf*/.* .
  rm -rf *-dcf*
  rm ${SCRIPT_NAME}
}

#
# check wget exist
#
function trywget {
  if ! command -v wget >/dev/null 2>&1; then
    echo ""
    echo -e "\e[31m\e[1mInstallation fail, You need git; curm or wget to use 'get' option. install one of it or download DCF directly from github: ${DCF_URL}\e[0m"
    exit
  fi
  wget --no-check-certificate $DCF_URL_DOWNLOAD -O - | tar xz
  RETURN=$?
  if [ ! $RETURN = 0 ]; then
    echo ""
    echo -e "\e[31m\e[1mInstallation fail, wget cannot retrive component! Check your internet connection or try again later\e[0m"
    exit
  fi
  mv *-dcf*/* *-dcf*/.* .
  rm -rf *-dcf*
  rm ${SCRIPT_NAME}
}

#
# check Git exist
#
function trygit {
  if [ -d ".git" ]; then
    if [ "$1" = "1" }; then
      echo ""
      echo -e "\e[31m\e[1mInstallation fail, root directory of DCF can not containt \".git\" directory at this step or install unzip + curl or wget!\e[0m"
      exit
    else
      trycurl
      return
    fi
  fi
  git clone $DCF_URL_GIT --single-branch --depth=1 --branch $DCF_TAG clone
  RETURN=$?
  if [ ! $RETURN = 0 ]; then
    echo ""
    echo -e "\e[31m\e[1mInstallation fail, git cannot retrive component! Check your internet connection or try again later\e[0m"
    exit
  fi
  rm -rf clone/.git
  mv clone/* . 2> /dev/null
  mv clone/.* . 2> /dev/null
  rm -rf clone
  rm ${SCRIPT_NAME}
}

#
# display node version
#
function nodeVersion {
  echo -n "Node version "
  ${ABS_SCRIPTS_PATH}/node -v
  echo -n "NPM version "
  ${ABS_SCRIPTS_PATH}/npm -v
  php ${ABS_SCRIPTS_PATH}/composer.phar -V
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
    cd $ABS_DCF_PATH
  else
    echo "Composer self install OK"
  fi
}

#
# check if is windows
#
validate_os() {
  IS_WINDOW=false
  if [ ! -z $OS ]; then
    WIN=`echo ${OS} | grep -i Windows`
    if [ ! -z $WIN ]; then
      IS_WINDOW=true
    fi
  fi
}

#
# get
#
function get {
  if ! command -v unzip >/dev/null 2>&1; then
    if ! command -v git >/dev/null 2>&1; then
      echo ""
      echo -e "\e[31m\e[1mInstallation fail, You need git or unzip with curl or wget to use \"deploy get\". Try to download directly DCF from github ${DCF_URL}\e[0m"
      exit 1
    else
      trygit 1
    fi
  else
    if command -v git >/dev/null 2>&1; then
      trygit 2
    fi
  fi
  chmod -R 550 scripts
  source scripts/dcf/dcf_path
  chmod 750 ${CONFIG_PATH}
  chmod 550 ${CONFIG_PATH}/*
  chmod -R 550 ${DOC_PATH}
  chmod -R 750 ${DOCUMENT_ROOT}
  chmod -R 550 ${SCRIPTS_PATH}
  echo ""
  echo "Now use :"
  echo "source ${SCRIPTS_PATH}/path.sh (optional)"
  echo "${SCRIPTS_PATH}/${SCRIPT_NAME} deploy dev <project name> [project description]\" to deploy DCF"
  echo ""
}

#
# deploy
# TODO : change part of it in composer plugin
#
function deploy {
  if [ "$2" = "" ]; then
      echo ""
      echo -e "\e[31m\e[1mProject's name missing !\e[0m"
      showHelp;
  fi
  echo "setup project $2..."
  project=$(echo $2 | sed "s| |_|")
  validate_os
  sed "s|^.+\n +\"name\": \".*\"|\"name\": \"${project}\"|" composer.json > composer.json2
  sed "s|\"description\": \".*\"|\"description\": \"$3\"|" composer.json2 > composer.json
  sed "s|\"name\": \".*\"|\"name\": \"${project}\"|" package.json > package.json2
  sed "s|\"description\": \".*\"|\"description\": \"$3\"|" package.json2 > package.json

  #export COMPOSER_HOME=${DCF_HOME}/composer
  #sed "s|\"bin-dir\": \".*\"|\"bin-dir\": \"${DCF_HOME}/${SCRIPTS_PATH}\"|" composer.json > composer.json2
  #sed "s|\"vendor-dir\": \".*\"|\"vendor-dir\": \"${DCF_HOME}/${VENDOR_PATH}\"|" composer.json2 > composer.json
  #sed "s|\"home\": \".*\"|\"home\": \"${COMPOSER_HOME}\"|" composer.json > composer.json2
  #sed "s|\"cache-dir\": \".*\"|\"cache-dir\": \"${COMPOSER_HOME}/cache\"|" composer.json2 > composer.json
  #sed "s|\"data-dir\": \".*\"|\"data-dir\": \"${COMPOSER_HOME}/data\"|" composer.json > composer.json2

  rm composer.json2 package.json2
  chmod -R 750 ${SCRIPTS_PATH}
  checkConposer
  PROD="--no-dev"
  if [ ! "$1" = "prod" ]; then
    PROD=""
  fi
  if [ -f "composer.lock" ]; then
    php ${SCRIPTS_PATH}/composer.phar update $PROD --no-suggest
    RETURN=$?
  else
    php ${SCRIPTS_PATH}/composer.phar install $PROD --no-suggest
    RETURN=$?
  fi
  if [ ! ${RETURN} = 0 ]; then
    exit 1
  fi
  chmod -R 550 ${SCRIPTS_PATH}
  #if [ ${IS_WINDOW} = true ]; then
    #correct bug of php + cygwin on windows
    #sed "s|return require __DIR__.*|return require __DIR__ . '/../${VENDOR_PATH}/autoload.php';|" ${DOCUMENT_ROOT}/autoload.php > ${DOCUMENT_ROOT}/autoload.php2
    #rm ${DOCUMENT_ROOT}/autoload.php
    #mv ${DOCUMENT_ROOT}/autoload.php2 ${DOCUMENT_ROOT}/autoload.php
  #fi
  #nodeVersion
  #if [ "$1" = "prod" ]; then
    #echo "NPM install (prod) :"
    #${SCRIPTS_PATH}/npm install . --only=prod --nodedir=${SCRIPTS_PATH}/. --prefix=${DOCUMENT_ROOT}
  #else
    #echo "NPM install (dev)"
    #${SCRIPTS_PATH}/npm install . --nodedir=${SCRIPTS_PATH}/. --prefix=${DOCUMENT_ROOT}
  #fi
  example_local=${ABS_CONFIG_PATH}/${EXAMPLE}${LOCAL_CONF}
  example2_local=${ABS_CONFIG_PATH}"/<site_id>"${LOCAL_CONF}
  echo ""
  echo "Now you can create a site or install an existing one:"
  echo " - Copy ${example_local} into"
  echo "        ${example2_local}"
  echo "   and fill it with your information"
  echo " - Then install your site by calling"
  echo "   ${ABS_SCRIPTS_PATH}/${SCRIPT_NAME} site deploy dev <site-id>"
  echo ""
}

#
# create sites.php in config
#
create_sites() {
  if [ ! -e "${CONFIG_PATH}/sites.php" ]; then
    chmod 750 ${CONFIG_PATH}
    echo "<?php" > ${CONFIG_PATH}/sites.php
  fi
}

#
# create site directory
#
create_site() {
  if [ ! -d "${SITE_DIR}" ]; then
    echo "Create site directory..."
    chmod 770 $SITES_PATH
    cp -r ${SITES_PATH}/default $SITE_DIR
    chmod -R 770 $SITE_DIR
    mv $SITE_DIR/default.settings.php $SITE_DIR/settings.php
  else
    echo "Reinitializing site settings..."
    chmod -R 770 $SITE_DIR
    rm $SITE_DIR/settings.php
    cp $SITE_DIR/../default/default.settings.php $SITE_DIR/settings.php
  fi
  chmod 770 ${CONFIG_PATH}/sites.php
  for f in ${URL}
  do
    echo -n "\$sites[" >> ${CONFIG_PATH}/sites.php
    echo -n ${f}  >> ${CONFIG_PATH}/sites.php
    echo -n "] = '" >> ${CONFIG_PATH}/sites.php
    echo -n ${ID} >> ${CONFIG_PATH}/sites.php
    echo "';" >> ${CONFIG_PATH}/sites.php
  done
  chmod 550 ${CONFIG_PATH}/sites.php
}

#
# read configuration files for a site
#
read_config() {
  local_file=${ABS_CONFIG_PATH}/${ID}${LOCAL_CONF}
  example_local=${ABS_CONFIG_PATH}/${EXAMPLE}${LOCAL_CONF}
  if [ ! -f ${local_file} ]; then
    echo ""
    echo -e "\e[31m\e[1mFile ${local_file} is missing create it by copy of ${example_local}\e[0m"
    echo ""
    exit 1
  fi
  source ${local_file}
  URL0=`echo $SITE_URLS | sed 's|,.*||g' | sed "s|'||g"`
  URL0_HTTP=`echo $URL0 | sed 's|http[s]*://||g' |sed 's|/.*||g'`
  URL=`echo $SITE_URLS | sed 's|,| |g' | sed 's|http[s]*://||g' | sed 's|/|\.|g'`
}

#
# create drush alias for the site
#
create_drush_alias() {
  cd $ABS_DCF_PATH/drush/site-aliases
  echo "<?php" > ${ID}.alias.drushrc.php
  echo "\$options['uri'] = '${URL0}';" >> ${ID}.alias.drushrc.php
  echo "\$options['root'] = '${ABS_DCF_PATH}';" >> ${ID}.alias.drushrc.php
}

#
# site deploy
#
function site_deploy {
  if [ "$2" = "" ]; then
      echo ""
      echo -e "\e[31m\e[1mSite id missing !\e[0m"
      showHelp;
  fi
  ID=`echo $2 | sed 's|[^a-z]+||g'`
  if [ "$ID" = "" ]; then
      echo ""
      echo -e "\e[31m\e[1mSite id can only contain lowercase !\e[0m"
      echo ""
      exit 1
  fi
  SITE_DIR=${SITES_PATH}/$ID
  read_config
  create_sites
  create_site
  cd $DOCUMENT_ROOT
  ${ABS_VENDOR_BIN_PATH}/drush site-install $SITE_TYPE -y --account-name="developer" --account-mail="${ADMIN_MAIL}" --site-mail="no-reply@${URL0_HTTP}" --site-name="${SITE_NAME}" --sites-subdir="${ID}" --db-url="${DATABASE}"
  cd $ABS_DCF_PATH
  create_drush_alias

}

#
# main
#
if [ "$1" = "" ]; then
    showHelp
fi
if [ "${IS_GET}" = "true" ]; then
  if [ ! $1 = "get" ]; then
    showHelp
  fi
else
  if [ "$1" = "get" ]; then
    echo ""
    echo -e "\e[31m\e[1mGet not allowed in this context\e[0m"
    showHelp
  fi
fi

case $1 in
  deploy )
          deploy "$2" "$3" "$4"
          ;;
  get )
          get
          ;;
  site )
          case $2 in
            deploy )
                  site_deploy "$3" "$4" "$5"
                  ;;
            rebuild )
                  site_rebuild "$3" "$4"
                  ;;
            * )
                  echo ""
                  echo -e "\e[31m\e[1mUnknown command : $1 $2 !\e[0m"
                  showHelp
                  ;;
          esac
          ;;
  * )
          echo ""
          echo -e "\e[31m\e[1mUnknown command : $1 !\e[0m"
          showHelp
          ;;
esac
exit 0
