<?php require_once dirname(__FILE__) . '/blog.php'; ?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta name="generator" content="HTML Tidy for Mac OS X (vers 1st December 2004), see www.w3.org" />
	<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
	<title>∞ • Afloat</title>
	
	<link rel="stylesheet" href="style.css" type="text/css" />
	<script type="text/javascript" src="http://www.haloscan.com/load/l0ne"> </script>
</head>

<body>
	<div id="content">
		<div id="preheader">
			<p><?= $this->L('a work of ∞.') ?>
				<?php foreach ($this->Locales() as $l) { ?>
					<a href="?lang=<?= $l ?>"><img src="<?= $this->L("Images/$l.gif") ?>" alt="<?= $this->L("($l)") ?>" width="16" height="11" /></a>
				<?php } ?> |
				<a href="mailto:millenomi+afloat@gmail.com"><?= $this->L('contact me') ?></a> |
				<a href="aim:GoIm?screenname=evthethinker"><?= $this->L('AIM') ?></a>
			<!-- Start of StatCounter Code -->
			<script type="text/javascript">
			var sc_project=1718121; 
			var sc_invisible=1; 
			var sc_partition=16; 
			var sc_security="87736b7e"; 
			</script>

			<script type="text/javascript" src="http://www.statcounter.com/counter/counter_xhtml.js"></script><noscript><div class="statcounter"><a class="statcounter" href="http://www.statcounter.com/"><img class="statcounter" src="http://c17.statcounter.com/counter.php?sc_project=1718121&amp;java=0&amp;security=87736b7e&amp;invisible=1" alt="(StatCounter)" /></a></div></noscript>
			<!-- End of StatCounter Code -->
			</p>
		</div>
		
		<div id="header"><h1><img src="<?= $this->PathTo('Images/header.gif') ?>" alt="<?= $this->L('Afloat. Light as air.') ?>" width="780" height="115" /></h1>
		</div>
		
		<div id="screenshotBar">
			<img src="<?= $this->PathTo('Images/screenshot.gif') ?>" alt="" width="496" height="299" />
			<div id="catcheye">
				<p>
					<?= $this->L('Catcheye'); ?>
				</p>
			</div>
	  </div>
		
		<div id="downloadAndBlogBar">
			<div id="download">
				<a href="<?= $this->PathTo('Download'); ?>/"><img src="<?= $this->PathTo('Images/download.gif') ?>" alt="<?= $this->L('Download Afloat 1.0 (pre-release 3) now.') ?>" width="347" height="204" /></a>
				<ul>
					<?= $this->L('Prerequisites') ?>
				</ul>
		  </div>
			
			<div id="blogBar">
				<div id="blogBarHeader">
					<a name="devBlog"></a>
					<h2><?= $this->L('development blog.') ?></h2>
					<div id="flags">
						<a href="?lang=it#devBlog"><img src="Images/it.gif" alt="(italiano)" width="16" height="11" /></a>
						<a href="?lang=en#devBlog"><img src="Images/us.gif" alt="(english)" width="16" height="11" /></a>					</div>
					<div class="clearer"></div>					
				</div>
				
				<div id="blogContent">
					<?php BlogWalk('BlogXHTML', $this->Locale()); ?>
				</div>
			</div>
			
			
		</div>
	</div>
</body>
</html>
