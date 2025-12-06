<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
echo "Verificando tipos de ta_11_mercados:\n\n";
$cols = $pdo->query("SELECT column_name, udt_name, character_maximum_length FROM information_schema.columns WHERE table_schema = 'publico' AND table_name = 'ta_11_mercados' AND column_name IN ('num_mercado_nvo', 'descripcion', 'oficina') ORDER BY ordinal_position")->fetchAll(PDO::FETCH_ASSOC);
foreach ($cols as $c) {
    echo "  {$c['column_name']}: {$c['udt_name']}";
    if ($c['character_maximum_length']) echo "({$c['character_maximum_length']})";
    echo "\n";
}
?>
