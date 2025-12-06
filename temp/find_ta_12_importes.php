<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2');
$stmt = $pdo->query("SELECT table_schema FROM information_schema.tables WHERE table_name = 'ta_12_importes'");
$result = $stmt->fetchAll(PDO::FETCH_COLUMN);
echo (count($result) > 0) ? 'ta_12_importes en: ' . implode(', ', $result) : 'ta_12_importes NO encontrada';
echo "\n";
