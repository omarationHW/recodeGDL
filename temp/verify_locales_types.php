<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "Tipos de columnas de ta_11_locales:\n\n";
$cols = $pdo->query("
    SELECT column_name, udt_name, character_maximum_length
    FROM information_schema.columns
    WHERE table_schema = 'publico'
      AND table_name = 'ta_11_locales'
      AND column_name IN ('oficina', 'num_mercado', 'categoria', 'seccion', 'local', 'letra_local', 'bloque', 'nombre')
    ORDER BY ordinal_position
")->fetchAll(PDO::FETCH_ASSOC);

foreach ($cols as $c) {
    echo "{$c['column_name']}: {$c['udt_name']}";
    if ($c['character_maximum_length']) echo "({$c['character_maximum_length']})";
    echo "\n";
}

echo "\n\nTipos de columnas de ta_11_ade_loc_canc:\n\n";
$cols2 = $pdo->query("
    SELECT column_name, udt_name, character_maximum_length
    FROM information_schema.columns
    WHERE table_schema = 'publico'
      AND table_name = 'ta_11_ade_loc_canc'
    ORDER BY ordinal_position
")->fetchAll(PDO::FETCH_ASSOC);

foreach ($cols2 as $c) {
    echo "{$c['column_name']}: {$c['udt_name']}";
    if ($c['character_maximum_length']) echo "({$c['character_maximum_length']})";
    echo "\n";
}
