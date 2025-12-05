<?php
/**
 * Script para buscar tablas relacionadas con prepago
 */

try {
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias",
        "refact",
        "FF)-BQk2"
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== BUSCANDO TABLAS RELACIONADAS CON PREPAGO ===\n\n";

    // Buscar tablas que contengan "prepago" en el nombre
    echo "1. Tablas que contienen 'prepago' o 'prepag' en el nombre:\n";
    $stmt = $pdo->query("
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE tablename ILIKE '%prepag%'
        OR tablename ILIKE '%pre_pag%'
        ORDER BY schemaname, tablename
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($tables) {
        foreach ($tables as $table) {
            echo "   - {$table['schemaname']}.{$table['tablename']}\n";
        }
    } else {
        echo "   No se encontraron tablas\n";
    }

    echo "\n2. Explorando tablas encontradas:\n";

    foreach ($tables as $table) {
        $schema = $table['schemaname'];
        $tablename = $table['tablename'];

        try {
            // Obtener estructura
            $stmt = $pdo->query("
                SELECT column_name, data_type
                FROM information_schema.columns
                WHERE table_schema = '$schema' AND table_name = '$tablename'
                ORDER BY ordinal_position
            ");
            $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

            echo "\n   ✓ {$schema}.{$tablename}\n";
            echo "   Columnas:\n";
            foreach ($columns as $col) {
                echo "     - {$col['column_name']} ({$col['data_type']})\n";
            }

            // Contar registros
            $stmt = $pdo->query("SELECT COUNT(*) as total FROM {$schema}.{$tablename}");
            $count = $stmt->fetch(PDO::FETCH_ASSOC);
            echo "   Total de registros: {$count['total']}\n";

            // Obtener datos de ejemplo
            if ($count['total'] > 0) {
                $stmt = $pdo->query("SELECT * FROM {$schema}.{$tablename} LIMIT 5");
                $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

                echo "\n   Datos de ejemplo:\n";
                foreach ($rows as $i => $row) {
                    echo "   Registro " . ($i + 1) . ":\n";
                    foreach ($row as $key => $value) {
                        $val = $value ?? 'NULL';
                        if (strlen($val) > 80) $val = substr($val, 0, 80) . '...';
                        echo "     $key: $val\n";
                    }
                    echo "\n";
                }
            }
        } catch (Exception $e) {
            echo "   Error al explorar tabla: {$e->getMessage()}\n";
        }
    }

    // Buscar tablas relacionadas con pagos adelantados o anticipados
    echo "\n3. Buscando tablas con 'anticip' o 'adelant':\n";
    $stmt = $pdo->query("
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE tablename ILIKE '%anticip%'
        OR tablename ILIKE '%adelant%'
        OR tablename ILIKE '%pago%'
        ORDER BY schemaname, tablename
        LIMIT 20
    ");
    $tables2 = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables2 as $table) {
        echo "   - {$table['schemaname']}.{$table['tablename']}\n";
    }

} catch (PDOException $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
