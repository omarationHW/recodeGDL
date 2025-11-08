<?php
$db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "=== TABLA public.tramites_visitas ===\n\n";

// Estructura
echo "📋 Estructura:\n";
$stmt = $db->query("
    SELECT column_name, data_type, character_maximum_length, is_nullable, column_default
    FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'tramites_visitas'
    ORDER BY ordinal_position
");
while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    $type = $row['data_type'];
    if ($row['character_maximum_length']) $type .= "({$row['character_maximum_length']})";
    $null = $row['is_nullable'] === 'NO' ? 'NOT NULL' : 'NULL';
    $default = $row['column_default'] ? " DEFAULT {$row['column_default']}" : '';
    echo "  {$row['column_name']}: $type $null$default\n";
}

// Contar
$stmt = $db->query("SELECT COUNT(*) as total FROM public.tramites_visitas");
$count = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
echo "\nTotal registros: $count\n";

// Ver tabla comun.tramites con muestra
echo "\n=== TABLA comun.tramites (muestra) ===\n";
$stmt = $db->query("
    SELECT id_tramite, folio, tipo_tramite, propietario, ubicacion, estatus
    FROM comun.tramites
    LIMIT 5
");
while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    $prop = trim($row['propietario']);
    $ubic = trim($row['ubicacion']);
    echo "\n  Trámite: {$row['id_tramite']} | Folio: {$row['folio']} | Tipo: {$row['tipo_tramite']}\n";
    echo "  Propietario: $prop\n";
    echo "  Ubicación: $ubic | Estatus: {$row['estatus']}\n";
}
