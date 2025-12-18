<?php
// Script para verificar la estructura de la tabla aut_desctosotorgados

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Ver estructura de la tabla
    echo "=== ESTRUCTURA DE public.aut_desctosotorgados ===\n";
    $stmt = $pdo->query("
        SELECT column_name, data_type, character_maximum_length, is_nullable
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'aut_desctosotorgados'
        ORDER BY ordinal_position
    ");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($columns as $col) {
        $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
        $nullable = $col['is_nullable'] == 'YES' ? 'NULL' : 'NOT NULL';
        echo "  - {$col['column_name']}: {$col['data_type']}{$length} {$nullable}\n";
    }

    // Ver algunos datos de ejemplo
    echo "\n=== DATOS DE EJEMPLO (primeros 5 registros) ===\n";
    $stmt = $pdo->query("SELECT * FROM public.aut_desctosotorgados LIMIT 5");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($rows) > 0) {
        foreach ($rows as $i => $row) {
            echo "\nRegistro " . ($i + 1) . ":\n";
            foreach ($row as $key => $value) {
                echo "  $key: $value\n";
            }
        }
    } else {
        echo "  (No hay datos en la tabla)\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
