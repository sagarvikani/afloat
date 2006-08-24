<?php

require_once 'Lock.php';
	
function L0LockAppendToStatFileOrDie($statFile, $append) {
	register_shutdown_function('L0Unlock', "$statFile.lock");
	L0LockOrDie("$statFile.lock", "Locking for log file $statFile");
	if (!L0AppendToStatFile($statFile, $append))
		trigger_error("Cannot write to $statFile (stat file)!", E_USER_ERROR);
	L0Unlock("$statFile.lock");
}

function L0AppendToStatFile($statFile, $append) {	
	if (!is_file($statFile)) {
		$fh = fopen($statFile, 'wb');
		if (!$fh) {
			trigger_error("Cannot open new file $statFile", E_USER_NOTICE);
			return false;
		}
		
		fwrite($fh, '<'.'?php exit; ?'.'>');
		fwrite($fh, pack('A10', '1'));
		fwrite($fh, pack('A10', strlen($s = serialize($append))));
		fwrite($fh, $s);
		fclose($fh);
		return true;
	}
	
	$fh = fopen($statFile, 'r+b');
	if (!$fh) {
		trigger_error("Cannot open existing file $statFile", E_USER_NOTICE);
		return false;
	}
	
	fseek($fh, 0, SEEK_END);
	fwrite($fh, pack('A10', strlen($s = serialize($append))));
	fwrite($fh, $s);
	fseek($fh, 14, SEEK_SET);
	$conteggio = (integer) fread($fh, 10);
	$conteggio++;
	fseek($fh, 14, SEEK_SET);
	fwrite($fh, pack('A10', (string) $conteggio));
	fclose($fh);
	
	return true;
}

?>