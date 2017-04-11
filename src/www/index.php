 <!DOCTYPE html>
<html>
<head>
<title>Tetras Back</title>
<script src="https://code.jquery.com/jquery-1.8.2.min.js"></script>
<meta charset="UTF-8">
<meta name="author" content="David Beniamine and Felix Coudurier">
<link rel="stylesheet" href="style.css"/>
</head>
<body>
<div id="box">
<div id="content">
<?php include("header.php") ?>
<div id="discs">
    <?php require './discs.php'; ?>
</div>
<div id="mainlog">
    <?php require './log.php'; ?>
</div>
<script src='./mainlog.js'></script>
<script src='./discs.js'></script>
<?php
    include("footer.php");
?>
</div>
</div>
</body>
</html>
