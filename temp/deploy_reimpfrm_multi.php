<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
$sql = file_get_contents(__DIR__ . '/recaudadora_reimpfrm_multi.sql');
$pdo->exec($sql);
echo "✅ SP actualizado con soporte para múltiples resultados\n";
?>
