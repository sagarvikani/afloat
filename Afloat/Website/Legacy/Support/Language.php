<?php

require_once dirname(__FILE__) . '/geoip.inc.php';
define ('kL0GeoIPDatabasePath', dirname(__FILE__) . '/geoip.dat');

global $L0PotentialPriorityCountries;
$L0PotentialPriorityCountries = array('pl');

function L0GetLanguageInfo() {
	$res = null;

	// polonia patch:
	global $L0PotentialPriorityCountries;
	$gi = geoip_open(kL0GeoIPDatabasePath, GEOIP_STANDARD);
	if ($gi) {
		$countryFrom = strtolower(geoip_country_code_by_addr($gi, $_SERVER['REMOTE_ADDR']));
		if (in_array($countryFrom, $L0PotentialPriorityCountries))
			$res = array($countryFrom => '1.0');
		geoip_close($gi);
	}
	
	if (is_array($res))
		return $res;

	$vals = (string) @$_SERVER['HTTP_ACCEPT_LANGUAGE'];
	$vals = explode(',', $vals);
	$res = array();
	
	foreach ($vals as $language) {
		$language = trim($language);
		if (strlen($language) < 2)
			continue;
			
		$lcode = substr($language, 0, 2);
		if (strlen($lcode) < 2)
			continue;

		if (($i = strpos($language, ';q=')) !== false)
			$quota = (float) substr($language, $i + 3);
		else
			$quota = 1.0;
		$res[$lcode] = $quota;	
	}
	
	return $res;
}

function L0ChooseLanguage($inorder, $default = null) {
	if ($default !== null)
		return in_array($default, $inorder)? $default : $inorder[0];
	
	$choice = null; $choicequota = null;
	$langs = L0GetLanguageInfo();
	
	foreach ($inorder as $lcode) {
		if ($choice === null || (isset($langs[$lcode]) && $choicequota < $langs[$lcode])) {
			$choice = $lcode;
			$choicequota = (float) @$langs[$lcode];
		}
	}
	
	return $choice;
}
?>