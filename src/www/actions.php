 <!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="author" content="David Beniamine and Felix Coudurier">
<link rel="stylesheet" href="style.css"/>
<title>Tetras Back</title>
<div id="box">
<div id="content">
<?php include("header.php") ?>
<p>
<?php
    extract($_POST);
    //echo "actions '$action', uuid '$uuid', name '$name', dev '$dev'<br/>";
    $cmd = "/usr/local/sbin/tetras-back";
    switch($action){
        case "save" :
            echo "Enregistrement du disque $uuid avec le nom $name";
            $args = "--save ".escapeshellarg($uuid)."=".escapeshellarg($name);
            break;
        case "trigger" :
            if ( !strcmp($dev,"")){
                echo "Impossible de lancer une sauvegarde sur le disque $name car il n'est pas connecte";
            }else{
                echo "Declanchement de sauvegarde sur le disque  $name ";
                $args = "--plug ".escapeshellarg($dev);
            }
            break;
        case "forget":
            echo "Desenregistrement du disque $name";
            $args = "--forget ".escapeshellarg($uuid);
            break;
    }
    if (strcmp($args, "")){
        //echo "<p>execution de '$cmd $args'</p>";
        shell_exec("$cmd $args");
    }
?>
</p>
<p>
<a href="index.php">Retour a l'accueil</a>
</p>
<?php
    include("footer.php");
?>
</div>
</div>
