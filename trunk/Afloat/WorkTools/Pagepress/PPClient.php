<?php

# Pagepress 2 Client-side API

require_once dirname(__FILE__) . '/JSON.php';
global $_PP_JSON;
$_PP_JSON =& new Services_JSON(SERVICES_JSON_LOOSE_TYPE);

function _PPErrDump($x) {
	ob_start(); var_dump($x); error_log(ob_get_clean());
}

function _PPLocalizedName($path, $tag) {
	if ($tag == null || $tag == '')
		return $path;

	$dir = dirname($path); $fn = basename($path);
	
	if (strlen($dir) > 0 && $dir{strlen($dir) - 1} == '/')
		$dir = substr($dir, 0, strlen($dir) - 1);
	
	if (strlen($fn) > 0 && $dir{strlen($fn) - 1} == '/')
		$fn = substr($fn, 0, strlen($fn) - 1);
		
	// var_dump($dir); var_dump($fn);
	
	if (($i = strrpos($fn, '.')) !== false)
		$fn = substr($fn, 0, $i) . "-$tag" . substr($fn, $i);
	else
		$fn = "$fn-$tag";
		
	return "$dir/$fn";
}

function _PPStripExtension($name) {
	$p = strrpos($name, '.');
	return $p === false? $name : substr($name, 0, $p);
}

class PPTemplate {
	var $_Strings;
	function PPTemplate($locale, $allLocales) {
		$this->_Strings = array();
		$this->_Lang = $locale;
		$this->_AllLangs = $allLocales;
		
		$this->_Ext = 'html';
	}
	
	function SetExtension($ext) { $this->_Ext = (string) $ext; }
	function Extension() { return (string) $this->_Ext; }
	
	function Locales() { return (array) $this->_AllLangs; }
	
	function L($string) {
		if (@isset($this->_Strings[$string]))
			return $this->_Strings[$string];
			
		return $string;
	}
	
	function Locale() { return (string) $this->_Lang; }
	
	function PathTo($path) {
		$loc = _PPLocalizedName($path, $this->_Lang);
	
		if (is_file($loc) || is_dir($loc))
			return $loc;
		
		return $path;
	}
	
	function MergeStrings($strings) {
		$this->_Strings = array_merge($this->_Strings, (array) $strings);
		_PPErrDump($this->_Strings);
	}
	
	function LoadConfigFile($file) {
		error_log("About to load $file");
		
		$this->_LoadSingleConfigFile($file);
		$loc = _PPLocalizedName($file, $this->_Lang);
		$this->_LoadSingleConfigFile($loc);
	}
	
	function _LoadSingleConfigFile($file) {
		global $_PP_JSON;
		
		if (is_file($file)) {
			error_log(" - Found $file");
			$strings = $_PP_JSON->decode(file_get_contents($file));
			if (is_array($strings))
				$this->MergeStrings($strings);
		}	
	}
	
	function RenderWith($tpl) {
		$this->LoadConfigFile(_PPStripExtension($tpl) . '.json');
	
		$loc = _PPLocalizedName($tpl, $this->_Lang);
		if (is_file($loc))
			require realpath($loc);
		else
			require realpath($tpl);
	}
	
	function Quote($quote) {
		return '<'."?php $quote ?".'>';
	}
}

?>