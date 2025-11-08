<?php
$db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
$db->exec("SET search_path TO public, comun");

$tables_to_check = [
    'informix_migration.tramites_requisitos',
    'public.giro_req',
    'public.liga_req',
    'comun.requisitos_doc'
];

foreach ($tables_to_check as $table) {
    echo "\n=== $table ===\n";

    try {
        // Estructura
        list($schema, $tablename) = explode('.', $table);
        $stmt = $db->query("
            SELECT column_name, data_type, character_maximum_length
            FROM information_schema.columns
            WHERE table_schema = '$schema' AND table_name = '$tablename'
            ORDER BY ordinal_position
        ");
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "Columnas:\n";
        foreach ($columns as $col) {
            $type = $col['data_type'];
            if ($col['character_maximum_length']) $type .= "({$col['character_maximum_length']})";
            echo "  {$col['column_name']}: $type\n";
        }

        // Contar
        $stmt = $db->query("SELECT COUNT(*) as total FROM $table");
        $count = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
        echo "Registros: $count\n";

        // Primeros 3
        if ($count > 0) {
            echo "Muestra:\n";
            $stmt = $db->query("SELECT * FROM $table LIMIT 3");
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            print_r($rows);
        }
    } catch (Exception $e) {
        echo "Error: " . $e->getMessage() . "\n";
    }
}
