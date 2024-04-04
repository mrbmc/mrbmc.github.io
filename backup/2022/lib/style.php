<?php

require "lessc.inc.php";

$less = new lessc;
echo $less->compileFile("input.less","stye.css");

?>
