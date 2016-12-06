# Drupal 8 Custom Factory version 0.1.0

This project is just a **SANDBOX** for the moment. **No stable version is provided yet**

 * [The goals](#the-goals-are)
 * [Installation](#installation)
 * [Compatibility](#compatibility)


## The goals are

 * Provide a Drupal 8 distribution (profile, set of modules, theme, and npm packages) for developers and services companies to develop multi sites Drupal8 / AngularJS2 [ / Ionic 2 ] projects.
 * Find a way for backend developers to work with frontend developers in same time (frontend should do not have to wait data from backend to work).
 * Avoid problem of SEO with angular (not a full single page application or use of snapshot auto generated by Drupal).
 * Give a standalone Distribution of Drupal 8 to develop with Angular (composer, and nodejs are downloaded locally in the project, no global tool needed). Only PHP CLI and a web server (suggest Apache) are needed.
 * Stay 100% compatible Drupal, Angular, Ionic. (No core modifications, Drupal, Angular and Other libraries are downloaded from official sources and use latest version)
 * Provide a Drupal distribution with a maximum quality for redactor to manage content, images... (pre-configured roles and permissions for administrator redactor and anonymous user, pre-configured CKEditor, a set of mandatories modules : pathauto...) (Improved backoffice capability : imageMagik ...), based on [Drupal 7 custom factory](https://github.com/fauconv/ctm_drupal7)
 * Provide several configuration options:
     * Choice between : Internet site or Intranet site,
     * Choice between : Only AngularJS 2 site or AngularJS 2 + Inoic 2 site,
     * In case of AngularJS 2 only, choice between: Single Page Application or Multi Pages Website with possibility of dynamic load of several block with Angular,
     * In case of Multi Pages Website, choice between: Angular website based on the REST API exposed by Drupal or Drupal website generating Angular template.


## Installation

 * Download the DCF Manager script:
     * [here](https://raw.githubusercontent.com/fauconv/dcf/master/scripts/project.sh) 
     * Or by using wget: `wget https://raw.githubusercontent.com/fauconv/dcf/master/scripts/project.sh` 
     * Or using curl:

```     
curl -o project.sh https://raw.githubusercontent.com/fauconv/dcf/master/scripts/project.sh
```

 * Place the script in the root directory of the future project. The document root of websites will be in `web` subdirectory. Exemple : if you place DCF Manager in `/var/www/dcf`, the DOCUMENT_ROOT of your web server must be set to `/var/www/dcf/web`
 * Give execution right to DCF Manager : `chmod 700 project.sh`
 * Launch the installation of DCF with the DCF Manager : `./project.sh create "my project name" "my project description"`
 * Read [wokflow documentation](https://raw.githubusercontent.com/fauconv/dcf/master/docs/DCF_8_workflow.md) and [general documentation](https://raw.githubusercontent.com/fauconv/dcf/master/docs/DCF_8_documentation.md) for more information


## Compatibility

DCF work on :
 * Linux
 * Windows 7 + cygwin
 * MacOs X 10

DCF need installation of :
  * PHP 5.5.9 or higher [see drupal's PHP requirements](https://www.drupal.org/docs/7/system-requirements/php)
  * a PHP web server (Apache, IIS...)
  [see drupal's Web Server requirements](https://www.drupal.org/docs/7/system-requirements/web-server)
  * a DataBase server (MySQL, MariaDB...) [see drupal's Database server requirements](https://www.drupal.org/docs/7/system-requirements/database-server)


