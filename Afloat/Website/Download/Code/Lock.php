<?php

function L0Lock($lockFile) {
	$i = 0;
	while (($fh = @fopen($lockFile, 'x')) === false) {
		sleep(1);
		$i++;
		if ($i == 30) {
			return false;
		}
	}
	
	return true;
}

function L0LockOrDie($lockFile, $errorMsg = '') {
	if (L0Lock($lockFile))
		return true;
		
	error_log("Cannot open $file with L0Lock. Stale lock? [$errorMsg]");
	trigger_error("Cannot open $file with L0Lock. Stale lock? [$errorMsg]", E_USER_ERROR);
	exit;
}

function L0Unlock($lockFile) {
	@unlink($lockFile);
}

?>