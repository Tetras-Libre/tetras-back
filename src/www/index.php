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
<script>
$(function() {
    var myInterval = setInterval(function(){
        $.get('log.php', function(data) {
            $('#mainlog').html(data);
        });
    }, 5000);
});
</script>
<script>
$(function() {
    var myInterval0 = setInterval(function(){
        $.get('discs.php', function(data) {
            $('#discs').html(data);
        });
    }, 15000);
});
</script>
<?php
    include("footer.php");
?>
</div>
</div>
</body>
</html>
