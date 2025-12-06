<?php
$pdoOrigen = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
$pdoDestino = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2');

echo "Estructura de padron_licencias.comun.ta_12_recaudadoras:\n";
echo "═══════════════════════════════════════════════════════════════\n";
$stmt = $pdoOrigen->query("
    SELECT column_name, data_type, character_maximum_length
    FROM information_schema.columns
    WHERE table_schema = 'comun' AND table_name = 'ta_12_recaudadoras'
    ORDER BY ordinal_position
");
while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    $length = $row['character_maximum_length'] ? "({$row['character_maximum_length']})" : "";
    echo "  {$row['column_name']}: {$row['data_type']}$length\n";
}

echo "\n\nEstructura de mercados.public.ta_12_recaudadoras:\n";
echo "═══════════════════════════════════════════════════════════════\n";
$stmt = $pdoDestino->query("
    SELECT column_name, data_type, character_maximum_length
    FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'ta_12_recaudadoras'
    ORDER BY ordinal_position
");
while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    $length = $row['character_maximum_length'] ? "({$row['character_maximum_length']})" : "";
    echo "  {$row['column_name']}: {$row['data_type']}$length\n";
}
