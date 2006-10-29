<?php

function BlogWalk($func, $LANG) {
	if (is_file($f = _PPLocalizedName(dirname(__FILE__).'/Blog.txt', $LANG))) {
		readfile($f);
		return;
	}

	$d = _PPLocalizedName(dirname(__FILE__).'/Blog', $LANG);
	if (is_dir($d)) {
		$subdirs = array();
		$dh = opendir($d);
		while (($file = readdir($dh)) !== false) {
			if ($file != '.' && $file != '..' && is_dir("$d/$file"))
				$subdirs[] = $file;
		}
		closedir($dh);
		
		rsort($subdirs);

		$i = sizeof($subdirs);
		foreach ($subdirs as $subdir) {
			$header = trim(file_get_contents("$d/$subdir/Header"));
			$body = file_get_contents("$d/$subdir/Body");
			$func($i, $header, $body);
			$i--;
		}
	} else echo "NO!";
}

function BlogXHTML($i, $header, $body) {
	global $LANG;
	echo "<div class='blogPost'><h3>" .htmlspecialchars($header) ."</h3>\n$body";
?>
	<p><a href="javascript:HaloScan('infinite_Afloat_<?= $i ?>_<?= $LANG ?>');" target="_self"><script type="text/javascript">postCount('infinite_Afloat_<?= $i ?>_<?= $LANG ?>');</script></a> | <a href="javascript:HaloScanTB('infinite_Afloat_<?= $i ?>_<?= $LANG ?>');" target="_self"><script type="text/javascript">postCountTB('infinite_Afloat_<?= $i ?>_<?= $LANG ?>'); </script></a></p>
	</div>
<?php
}

function BlogRSS($i, $header, $body) {
	echo "<title><![CDATA[$header]]></title><description><![CDATA[$body]]</description>";
}

?>