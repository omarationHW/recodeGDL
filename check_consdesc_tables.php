<?php
// Script para buscar tablas relacionadas con descuentos y verificar el SP

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Ver el contenido del stored procedure existente
    echo "=== CONTENIDO DEL STORED PROCEDURE recaudadora_consdesc ===\n";
    $stmt = $pdo->query("
        SELECT pg_get_functiondef(p.oid) as definition
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = 'recaudadora_consdesc'
        AND n.nspname = 'publico'
    ");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo $result['definition'];
        echo "\n";
    } else {
        echo "  (No se encontró el stored procedure)\n";
    }

    // Buscar tablas relacionadas con descuentos
    echo "\n\n=== TABLAS RELACIONADAS CON DESCUENTOS ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (table_name ILIKE '%descuento%' OR table_name ILIKE '%descto%')
        AND table_type = 'BASE TABLE'
        AND table_schema IN ('public', 'publico')
        ORDER BY table_schema, table_name
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        foreach ($tables as $table) {
            echo "  - {$table['table_schema']}.{$table['table_name']}\n";
        }
    } else {
        echo "  (No se encontraron tablas relacionadas)\n";
    }

    // Ver la tabla aut_desctosotorgados que usamos antes
    echo "\n\n=== VERIFICANDO TABLA public.aut_desctosotorgados ===\n";
    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'aut_desctosotorgados'
        ORDER BY ordinal_position
    ");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($columns) > 0) {
        echo "Campos disponibles:\n";
        foreach ($columns as $col) {
            echo "  - {$col['column_name']}: {$col['data_type']}\n";
        }

        // Ver datos de ejemplo
        echo "\nDatos de ejemplo (3 registros):\n";
        $stmt = $pdo->query("SELECT * FROM public.aut_desctosotorgados LIMIT 3");
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($rows as $i => $row) {
            echo "\nRegistro " . ($i + 1) . ":\n";
            echo "  folio_descto: {$row['folio_descto']}\n";
            echo "  id_multa: {$row['id_multa']}\n";
            echo "  tipo_descto: {$row['tipo_descto']}\n";
            echo "  por_aut: {$row['por_aut']}\n";
            echo "  monto_aut: {$row['monto_aut']}\n";
            echo "  fecha_act: {$row['fecha_act']}\n";
            echo "  vigencia: {$row['vigencia']}\n";
        }
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
