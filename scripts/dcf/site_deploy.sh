#!/bin/bash
#+-----------------------------------------------------------+
#|                                                           |
#| code for the site deploy command                          |
#|                                                           |
#+-----------------------------------------------------------+
#| version : 1                                               |
#+-----------------------------------------------------------+

#
# create sites.php in config
#
function create_sites {
  if [ ! -e "${ABS_CONFIG_PATH}/sites.php" ]; then
    echo "<?php" > ${ABS_CONFIG_PATH}/sites.php
    chmod 777 ${ABS_CONFIG_PATH}/sites.php
  fi
}

#
# create site directory
#
function create_site {
  if [ ! -d "${ABS_SITE_PATH}" ]; then
    echo "Create site directory..."
    setRight dev
    cp -r ${ABS_SITES_PATH}/default ${ABS_SITE_PATH}
    cp -R  ${ABS_MEDIAS_PATH}/default ${ABS_MEDIA_PATH}
    chmod -R 777 ${ABS_SITE_PATH} ${ABS_MEDIA_PATH}
    cp ${ABS_SOURCE_PATH}/default.settings.php ${ABS_SITE_PATH}/settings.php
    rm ${ABS_SITE_PATH}/default.settings.php
    echo -e "Create site directory...                                                        \e[32m\e[1m[ok]\e[0m"
  else
    echo "Reinitializing installation of site..."
    setRight dev
    if [ ! -d ${ABS_MEDIA_PATH} ]; then
      cp -R  ${ABS_MEDIAS_PATH}/default ${ABS_MEDIA_PATH}
    fi
    chmod -R 777 ${ABS_MEDIA_PATH}
    mv ${ABS_SITE_PATH}/settings.php ${ABS_SITE_PATH}/settings.php.orig
    cp ${ABS_SOURCE_PATH}/default.settings.php ${ABS_SITE_PATH}/settings.php
    echo -e "Reinitializing installalation of site...                                \e[32m\e[1m[ok]\e[0m"
  fi
  echo "Configuring site..."  
  cd ${ABS_CONFIG_PATH}
  grep ${ID} sites.php -v > sites2.php
  cp -f sites2.php sites.php
  for f in ${URL_SETTING}
  do
    grep ${f} sites.php -v > sites2.php
    echo -n "\$sites[" >> sites2.php
    echo -n ${f}  >> sites2.php
    echo -n "] = '" >> sites2.php
    echo -n ${ID} >> sites2.php
    echo "';" >> sites2.php
    cp sites2.php sites.php
  done
  rm -f sites2.php
  cp ${ABS_SITE_PATH}/settings.php ${ABS_SITES_PATH}/default/default.settings.php
  chmod 777 ${ABS_SITES_PATH}/default/default.settings.php
  echo -e "Configuring site...                                                   \e[32m\e[1m[ok]\e[0m"
}

#
# read configuration files for a site
#
function read_config {

  #local
  local_file=${ABS_CONFIG_PATH}/${ID}${LOCAL_CONF}
  if [ ! -f ${local_file} ]; then
    example_local=${ABS_CONFIG_PATH}/${EXAMPLE}${LOCAL_CONF}
    echo ""
    echo -e "\e[31m\e[1mFile ${local_file} is missing create it by copy of ${example_local}\e[0m"
    echo ""
    exit 1
  fi
  source ${local_file}
  if [ "${SITE_URLS}" = "" ] || [ "${DATABASE}" = "" ] || [ "${DATABASE}" = "mysql://db_user:db_password@localhost:3306/db_name" ] || [ "${ADMIN_MAIL}" = "" ]; then
    echo ""
    echo -e "\e[31m\e[1mFile ${global_file} is empty\e[0m"
    echo ""
    exit 1
  fi

  #global
  global_file=${ABS_CONFIG_PATH}/${ID}${GLOBAL_CONF}
  if [ ! -f ${global_file} ]; then
    example_global=${ABS_CONFIG_PATH}/${EXAMPLE}${GLOBAL_CONF}
    echo ""
    echo -e "\e[31m\e[1mFile ${global_file} is missing create it by copy of ${example_global}\e[0m"
    echo ""
    exit 1
  fi
  source ${global_file}
  if [ "${SITE_NAME}" = "" ] || [ "${LANG}" = "" ] || [ "${PROFIL}" = "" ] ; then
    echo ""
    echo -e "\e[31m\e[1mFile ${global_file} is empty or wrong values\e[0m"
    echo ""
    exit 1
  fi
  source ${ABS_SOURCE_PATH}/url.sh
}

#
# create drush alias for the site
#
function create_drush_alias {
  cd $ABS_DRUSH_ALIAS
  echo "<?php" > ${ID}.alias.drushrc.php
  echo "\$options['uri'] = '${URL0}';" >> ${ID}.alias.drushrc.php
  echo "\$options['root'] = '${ABS_DOCUMENT_ROOT}';" >> ${ID}.alias.drushrc.php
}

#
# get po file
#
function get_lang {
  DRUPAL_VERSION=`${ABS_DCRIPTS_PATH}/drush st | grep "Drupal version" | grep -o "8\.[0-9]\.[0-9]"`
  pofile="drupal-${DRUPAL_VERSION}.${LANG}.po"
  popath="${ABS_SITES_PATH}/${ID}/${TRANSLATIONS_PATH}/${pofile}"
  pofull="${popath}/${pofile}"
  if [ ! -f $popath ]; then
    echo "Download translation : http://ftp.drupal.org/files/translations/8.x/drupal/${pofile}"
    if command -v curl >/dev/null 2>&1; then
      curl -sL "http://ftp.drupal.org/files/translations/8.x/drupal/${pofile}" > ${pofull}
    else
      if ! command -v wget >/dev/null 2>&1; then
        cd ${popath}
        wget "http://ftp.drupal.org/files/translations/8.x/drupal/${pofile}"
        cd $ABS_DCF_PATH
      else
        echo "Download fail ! installation continu..."
      fi
    fi
  fi
}

#
# create htaccess for alias
#
function create_htaccess {
  cd ${ABS_DOCUMENT_ROOT}
  for f in ${URL_ALIAS}
  do
    f=${f}/
    ALIAS=`echo ${f} | sed "s|'||ig" | sed 's|[^/]*/||i' | sed 's|/$||g'`
    if [ ! "${ALIAS}" = "" ]; then
      FOUND=`grep "/${ALIAS}/index.php" .htaccess`
      if [ "$FOUND" = "" ]; then
        TEXT="DCF_MANAGER_TAG\nRewriteCond %{REQUEST_URI} ^/${ALIAS}/\nRewriteRule ^ /${ALIAS}/index.php [L]\n"
        sed "s|DCF_MANAGER_TAG|${TEXT}|" .htaccess > .htaccess2
        rm .htaccess
        mv .htaccess2 .htaccess
      fi
    fi
  done
}

#
# cutting of setting.php file
#
function finalize {
  echo "Cutting settings..."
  setRight dev
  cp ${ABS_CONFIG_PATH}/example.mock-default.xml ${ABS_CONFIG_PATH}/mock-${ID}.xml
  cp ${ABS_CONFIG_PATH}/example.masquerade-default.xml ${ABS_CONFIG_PATH}/masquerade-${ID}.xml
  cp ${ABS_SOURCE_PATH}/default.settings.php ${ABS_SITES_PATH}/default
  setRight $ENV
  echo -e "Cutting settings...                                                   \e[32m\e[1m[ok]\e[0m"
}

function addcmd {
  sed "s|drush.php \"|drush.php @${ID} \"|1" ${ABS_SCRIPTS_PATH}/drush > ${ABS_SCRIPTS_PATH}/@${ID}
}

#
# site deploy
#
function site_deploy {
  read_config
  setRight dev
  create_sites
  create_site
  create_htaccess
  create_drush_alias
  if [ "${LANG}" = "en" -o "${LANG}" = "EN" ]; then
    LOCAL=""
  else
    LOCAL="--locale=\"${LANG}\""
    get_lang
  fi
  cd $ABS_DOCUMENT_ROOT
  ${ABS_SCRIPTS_PATH}/drush site-install $PROFIL -y $LOCAL --account-name="${ADMIN_NAME}" --account-mail="${ADMIN_MAIL}" --site-mail="no-reply@${HOST0}" --site-name="${SITE_NAME}" --sites-subdir="${ID}" --db-url="${DATABASE}"
  cd $ABS_DCF_PATH
  finalize
  addcmd
  setRight $ENV
  echo ""
  echo "DONT FORGET TO NOTE the administrator password display above this message"
}

