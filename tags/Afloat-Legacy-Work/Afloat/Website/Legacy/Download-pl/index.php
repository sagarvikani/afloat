<?php

require_once dirname(__FILE__) . '/../Download/Code/StatFile.php';

function _L0ReduceServerToInterestingInfoOnly() {
	$s = $_SERVER;
	$k = array_keys($s);
	
	foreach ($k as $key) {
		if (!(substr($key, 0, 5) == 'HTTP_' || $key == 'REMOTE_ADDR'))
			unset($s[$key]);
	}
	
	return $s;
}

$here = dirname(__FILE__);
$stats = $here . '/../Download/StatsDB.php';

if (!is_file($stats) || filesize($stats) < 5242880 /* 5 MB */) {
	$dl = array(
		'UniqID' => uniqid('download', true),
		'Date' => time(),
		'HeaderInfo' => _L0ReduceServerToInterestingInfoOnly(),
		'Extra' => @substr($_GET['extra'], 0, 128) . ' + lang:pl'
		);

	L0LockAppendToStatFileOrDie($stats, $dl);	
}

$afloat = $here . '/Afloat-pl.dmg';

header('Content-Type: application/octet-stream');
header('Content-Disposition: attachment;filename=Afloat.dmg');
readfile($afloat);

?>