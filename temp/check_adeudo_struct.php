<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
echo "Estructura de ta_11_adeudo_local:\n\n";
$cols = $pdo->query("SELECT column_name, udt_name FROM information_schema.columns WHERE table_schema = 'publico' AND table_name = 'ta_11_adeudo_local' ORDER BY ordinal_position")->fetchAll(PDO::FETCH_ASSOC);
foreach ($cols as $c) { echo "  {$c['column_name']}: {$c['udt_name']}\n"; }
$count = $pdo->query("SELECT COUNT(*) as total FROM publico.ta_11_adeudo_local")->fetch(PDO::FETCH_ASSOC);
echo "\nTotal: {$count['total']}\n";
?>
