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

?>

<html>
 <head>
  <title>Tetras Back</title>
  <script src="http://code.jquery.com/jquery-1.8.2.min.js"></script>
 </head>
 <body>
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
    }, 1000);
});
</script>
<script>
$(function() {
    var myInterval0 = setInterval(function(){
        $.get('discs.php', function(data) {
            $('#discs').html(data);
        });
    }, 1000);
});
</script>
</body>
</html>
