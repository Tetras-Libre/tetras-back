<?php
    /*
     * Copyright (C) 2017  Tetras Libre <contact@tetras-libre.fr>
     * Author: Beniamine, David <David.Beniamine@tetras-libre.fr>
     *         Coudurier, Felix <web@demo-tic.org>
     *
     * This program is free software: you can redistribute it and/or modify
     * it under the terms of the GNU General Public License as published by
     * the Free Software Foundation, either version 3 of the License, or
     * (at your option) any later version.
     *
     * This program is distributed in the hope that it will be useful,
     * but WITHOUT ANY WARRANTY; without even the implied warranty of
     * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
     * GNU General Public License for more details.
     *
     * You should have received a copy of the GNU General Public License
     * along with this program.  If not, see <http://www.gnu.org/licenses/>.
     */

    $output = shell_exec('cat ./tl-client');
    // decode json
    $conf = json_decode($output, true); //, assoc=true);
    //var_dump($conf);
    echo "<h1> Disques </h1>";
    echo "<h2> Disques Connectes </h2>";
    echo "<div id='connected'>";
    echo "<table>";
    echo "<tr><th>Device</th><th>Identifiant unique</th><th>Actions</th></tr>";
    foreach ($conf['CONNECTED'] as $uuid => $dev){
        echo "<tr><td>$dev</td><td>$uuid</td><td>TODO: save</td></tr>";
    }
    echo "</table>";
    //One line by connected entry
    //add save button + text field that triggers tetras-back \-\-save uuid=name
    echo "</div>";
    echo "<h2> Disques Connus </h2>";
    echo "<div id='known'>";
    echo "<table>";
    echo "<tr><th>Nom</th><th>Identifiant unique</th><th>Derniere connexion</th><th>Derniere sauvegarde/<th><th>Actions</th></tr>";
    foreach ($conf['KNOWN'] as $uuid => $value){
        $name=$value['name'];
        echo "<tr><td>$name</td><td>$uuid</td>";
        echo "";
        echo "";
        echo "<td>TODO: save</td></tr>";
    }
    echo "</table>";
    //One line by known entry
    //add forget button that triggers tetras-back \-\-forget uuid
    //add backup button that is grey if not connected and triggers tetras-back \-\-plug device
    echo "</div>";
?>
