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

    $output = shell_exec('tail /var/log/tetras-back/main.log');
?>
<h1> Logs </h1>
<pre><code>
<?php
// TODO: revert output
echo "$output";
?>
</code></pre>
