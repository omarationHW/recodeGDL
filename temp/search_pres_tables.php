<?php
/**
 * Script para buscar tablas relacionadas con pres (presupuesto, prestaciones, etc.)
 */

try {
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias",
        "refact",
        "FF)-BQk2"
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== BUSCANDO TABLAS RELACIONADAS CON PRES ===\n\n";

    // Buscar tablas que contengan "pres" en el nombre
    echo "1. Tablas que contienen 'pres' en el nombre:\n";
    $stmt = $pdo->query("
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE tablename ILIKE '%pres%'
        ORDER BY schemaname, tablename
        LIMIT 50
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($tables) {
        foreach ($tables as $table) {
            echo "   - {$table['schemaname']}.{$table['tablename']}\n";
        }
    } else {
        echo "   No se encontraron tablas\n";
    }

    // Buscar las más probables relacionadas con presupuesto
    echo "\n2. Explorando tablas específicas:\n";

    $specific_tables = [
        ['schema' => 'catastro_gdl', 'table' => 'presupuesto'],
        ['schema' => 'comun', 'table' => 'presupuesto'],
        ['schema' => 'db_ingresos', 'table' => 'presupuesto'],
        ['schema' => 'catastro_gdl', 'table' => 'prespred'],
        ['schema' => 'comun', 'table' => 'prespred']
    ];

    foreach ($specific_tables as $t) {
        $schema = $t['schema'];
        $tablename = $t['table'];

        try {
            // Verificar si existe
            $stmt = $pdo->prepare("
                SELECT column_name, data_type
                FROM information_schema.columns
                WHERE table_schema = ? AND table_name = ?
                ORDER BY ordinal_position
            ");
            $stmt->execute([$schema, $tablename]);
            $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

            if ($columns) {
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
                break; // Solo mostrar el primero que se encuentre
            }
        } catch (Exception $e) {
            // Continuar con la siguiente tabla
        }
    }

} catch (PDOException $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
