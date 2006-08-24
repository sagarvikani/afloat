<?php

error_reporting(E_ALL);
define ('kL0Day', 86400);
require_once dirname(__FILE__) . '/Support/Language.php';

$langs = array('en', 'it', 'zh-tw', 'de', 'es', 'pl');

$def = @$_GET['lang'];
if (!$def) $def = @$_COOKIE['L0SiteLanguage'];

$lang = L0ChooseLanguage($langs, $def);
if (!in_array($lang, $langs))
	$lang = 'en';

if (@$_COOKIE['L0SiteLanguage'] !== $lang)
	setcookie('L0SiteLanguage', $lang, time() + (7 * kL0Day), '/Afloat/', 'millenomi.altervista.org', 0);

readfile("index-$lang.html");

?>