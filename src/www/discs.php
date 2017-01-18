<!--
 - Copyright (C) 2017  Tetras Libre <contact@tetras-libre.fr>
 - Author: Beniamine, David <David.Beniamine@tetras-libre.fr>
 -         Coudurier, Felix <web@demo-tic.org>
 -
 - This program is free software: you can redistribute it and/or modify
 - it under the terms of the GNU General Public License as published by
 - the Free Software Foundation, either version 3 of the License, or
 - (at your option) any later version.
 -
 - This program is distributed in the hope that it will be useful,
 - but WITHOUT ANY WARRANTY; without even the implied warranty of
 - MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 - GNU General Public License for more details.
 -
 - You should have received a copy of the GNU General Public License
 - along with this program.  If not, see <http://www.gnu.org/licenses/>.
 -->

<?php
    $output = shell_exec('cat ./tl-client');
    // decode json
    $conf = json_decode($output, true);
    $format = 'd-m-Y H:i:s';
    //var_dump($conf);
?>
<h1> Disques </h1>
<h2> Disques Connectes </h2>
<div id='connected'>
<table>
<tr><th>Device</th><th>Identifiant unique</th><th>Enregistrer</th></tr>

<?php
    //One line by connected entry
    //add save button + text field that triggers tetras-back \-\-save uuid=name
    foreach ($conf['CONNECTED'] as $uuid => $dev) :
?>
<tr><td><?php echo $dev ?></td><td><?php echo $uuid ?></td>
<td>
<form action="actions.php" method="post">
<input type="hidden" name="uuid" value="<?php echo $uuid ?>">
<input type="hidden" name="action" value="save">
<input type="text"   name="name" placeholder="nom">
<input type="submit" value="Enregistrer">
</form>
</td>
</tr>
<?php endforeach ?>
</table>
</div>
<h2> Disques Connus </h2>
<div id='known'>
<table>
<tr><th>Nom</th><th>Identifiant unique</th><th>Derniere connexion</th><th>Derniere sauvegarde</th><th>Delencher la sauvegarde</th><th>Oublier le disque</th></tr>
<?php
foreach ($conf['KNOWN'] as $uuid => $value) :
    $name=$value['name'];
    if( $value['last_seen'] != 'Never' ){
        $epoch = $value['last_seen'];
        $dt= new DateTime("@$epoch");
        $last_seen = $dt->format($format);
    }else{
        $last_seen = 'Jamais';
    }
    $last_backup_state = $value['last_backup'];
    $pos = strrpos($last_backup_state, ' ');
    if($pos != 0){
        $pos++;
    }
    $last_backup_epoch = substr($last_backup_state, $pos);
    if( $last_backup_epoch != 'Never' ){
        $dt= new DateTime("@$last_backup_epoch");
        $last_backup_time = "le : ".$dt->format($format);
    }else{
        $last_backup_time = 'Jamais';
    }
    $last_backup_state = str_replace($last_backup_epoch,
         $last_backup_time, $last_backup_state);
    if (array_key_exists($uuid, $conf['CONNECTED'])){
        $dev = $conf['CONNECTED'][$uuid];
    }else{
        $dev = "";
    }
?>
<tr>
    <td><?php echo $name ?></td>
    <td><?php echo $uuid ?></td>
    <td><?php echo $last_seen ?></td>
    <td><?php echo $last_backup_state ?></td>
    <td>
        <form action="actions.php" method="post">
            <input type="hidden" name="name" value="<?php echo $name ?>">
            <input type="hidden" name="dev" value="<?php echo $dev ?>">
            <input type="hidden" name="uuid" value="<?php echo $uuid ?>">
            <input type="hidden" name="action" value="trigger">
            <input type="submit" value="Sauvegarder">
        </form>
    </td>
    <td>
        <form action="actions.php" method="post">
            <input type="hidden" name="name" value="<?php echo $name ?>">
            <input type="hidden" name="uuid" value="<?php echo $uuid ?>">
            <input type="hidden" name="dev" value="<?php echo $dev ?>">
            <input type="hidden" name="action" value="forget">
            <input type="submit" value="Oublier">
        </form>
    </td>
</tr>
<?php endforeach ?>
</table>
</div>
