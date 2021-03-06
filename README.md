# Drupal 8 Custom Factory version 0.1.0

This project is just a **SANDBOX** for the moment. **No stable version is provided yet**

 * [The goals](#the-goals-are)
 * [Installation](#installation)
 * [Compatibility](#compatibility)

[![Software License](https://img.shields.io/badge/license-GPL%203-blue.svg)](https://github.com/fauconv/dcf)

## The goals are

 * Provide a Drupal 8 STANDALONE DISTRIBUTION (profiles, set of modules, theme, tools, npm/composer packages, angularJS 2 API for Drupal 8, versions management...) for developers and services companies to develop multi-sites Drupal8 / AngularJS2 ( / Ionic 2 ) (with material design) projects.
 * Provide profiles by use case:
     * internet site:
          * Angular-Drupal single page application (with ionic) (with material design)
          * Angular-Drupal multi-pages site
          * Drupal site
     * intranet:
          * Angular-Drupal single page site
          * Angular-Drupal multi-pages site
          * Drupal site
 * Find a way for backend developers to work with frontend developers in same time (frontend should do not have to wait data from backend to work).
 * In case of single page application, avoid problem of SEO with angular by using of snapshot auto generated by Drupal.
 * DCF is standalone (composer, nodejs and packages are downloaded locally in the project, no global tool needed). Only PHP CLI and a web server are needed. Environment variables are not used.
 * Stay 100% compatible Drupal, Angular, Ionic. (No core modifications, Drupal, Angular and Other libraries are downloaded from official sources and use latest version)
 * Provide a Drupal distribution with a maximum quality for redactor to manage content, images... (pre-configured roles and permissions for administrator redactor and anonymous user, pre-configured CKEditor, a set of mandatories modules: pathauto...) (Improved backoffice capability : imageMagik ...), based on [Drupal 7 custom factory](https://github.com/fauconv/ctm_drupal7)
 * DCF manage drupal multi-sites with or without apache aliases automaticaly (http://example.com/alias)



## Installation

 1. Download DCF:
     * directly on github
     * or using git
     `git clone --depth 1 https://github.com/fauconv/dcf.git; rm -rf .git`
     * or if you already have composer you can use it : 
     `composer create-project fauconv/dcf -n --repository "{\"type\":\"vcs\", \"url\":\"https://github.com/fauconv/dcf\"}" -s dev`
 2. The document root of websites will be in `web` subdirectory. Exemple: if you place DCF in `/var/www/dcf`, the DOCUMENT_ROOT of your web server must be set to `/var/www/dcf/web`
 3. Deploy DCF: `scripts/project.sh deploy dev`
 4. Optionaly launch `source scripts/path.sh` to set environment path for DCF. Environment is only set for your current session, no side effect. You must launch it eachtime you open a terminal or place this command line in your .bashrc file
 5. in `config` directory create a global config file and a local config file named my_site_id.config.global.ini and my_site_id.config.local.ini for your site by using the samples file. my_site_id, is a unique id freely choosen in space: [a-z_]+. In global config file you can choose between 2 profile provided by DCF "internet" or "intranet". You can also create your own profile or use standard drupal profiles.
 6. create a new drupal site: `scripts/project.sh site deploy my_site_id`
 7. Read [workflow documentation](https://raw.githubusercontent.com/fauconv/dcf/master/docs/DCF_8_workflow.md) and [general documentation](https://raw.githubusercontent.com/fauconv/dcf/master/docs/DCF_8_documentation.md) for more information


## Compatibility

DCF work on :
 * Linux
 * Windows 7 + cygwin (To improve twig performance for windows, you can find php_twig.dll in https://github.com/fauconv/php-for-windows)
 * MacOs X 10

DCF need installation of:
  * PHP 5.5.9 or higher [see drupal's PHP requirements](https://www.drupal.org/docs/7/system-requirements/php)
  * a PHP web server (Nginx, Apache, IIS, lightHttp...) and PHP cli
  [see drupal's Web Server requirements](https://www.drupal.org/docs/7/system-requirements/web-server)
  * a DataBase server (MySQL, MariaDB...) [see drupal's Database server requirements](https://www.drupal.org/docs/7/system-requirements/database-server)
  * wget and bsdtar system package (for drush)
