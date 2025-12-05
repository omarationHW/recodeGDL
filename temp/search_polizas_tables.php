<?php
/**
 * Script para buscar tablas relacionadas con pólizas y cuentas de aplicación
 */

try {
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias",
        "refact",
        "FF)-BQk2"
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== BUSCANDO TABLAS DE PÓLIZAS Y CUENTAS DE APLICACIÓN ===\n\n";

    // Buscar tablas de pólizas
    echo "1. Tablas que contienen 'poliza' en el nombre:\n";
    $stmt = $pdo->query("
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE tablename ILIKE '%poliza%'
        ORDER BY schemaname, tablename
        LIMIT 20
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        echo "   - {$table['schemaname']}.{$table['tablename']}\n";
    }

    echo "\n2. Explorando tabla ta_polizas en comun:\n";

    $schemas_to_check = ['comun', 'comunX', 'db_ingresos', 'catastro_gdl'];

    foreach ($schemas_to_check as $schema) {
        try {
            $stmt = $pdo->prepare("
                SELECT column_name, data_type
                FROM information_schema.columns
                WHERE table_schema = ? AND table_name = 'ta_polizas'
                ORDER BY ordinal_position
            ");
            $stmt->execute([$schema]);
            $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

            if ($columns) {
                echo "\n   ✓ Encontrada: {$schema}.ta_polizas\n";
                echo "   Columnas:\n";
                foreach ($columns as $col) {
                    echo "     - {$col['column_name']} ({$col['data_type']})\n";
                }

                // Contar registros
                $stmt = $pdo->query("SELECT COUNT(*) as total FROM {$schema}.ta_polizas");
                $count = $stmt->fetch(PDO::FETCH_ASSOC);
                echo "\n   Total de registros: {$count['total']}\n";

                // Obtener datos de ejemplo
                $stmt = $pdo->query("SELECT * FROM {$schema}.ta_polizas LIMIT 3");
                $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

                if ($rows) {
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

                // Si hay fecha, buscar registros recientes
                if (in_array('fecha', array_column($columns, 'column_name')) ||
                    in_array('fecpol', array_column($columns, 'column_name'))) {

                    $date_col = in_array('fecha', array_column($columns, 'column_name')) ? 'fecha' : 'fecpol';

                    echo "\n   Buscando registros recientes:\n";
                    $stmt = $pdo->query("
                        SELECT * FROM {$schema}.ta_polizas
                        WHERE {$date_col} >= CURRENT_DATE - INTERVAL '30 days'
                        ORDER BY {$date_col} DESC
                        LIMIT 5
                    ");
                    $recent = $stmt->fetchAll(PDO::FETCH_ASSOC);

                    echo "   Registros de los últimos 30 días: " . count($recent) . "\n";
                    if ($recent) {
                        foreach ($recent as $i => $row) {
                            echo "     Registro " . ($i + 1) . ": {$date_col}={$row[$date_col]}\n";
                        }
                    }
                }

                break;
            }
        } catch (Exception $e) {
            // Continuar con el siguiente schema
        }
    }

    echo "\n3. Buscando tablas con 'ctaapl' o 'cuenta_aplicacion':\n";
    $stmt = $pdo->query("
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE tablename ILIKE '%ctaapl%'
        OR tablename ILIKE '%cuenta%aplicacion%'
        OR tablename ILIKE '%ctaapli%'
        ORDER BY schemaname, tablename
        LIMIT 10
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        echo "   - {$table['schemaname']}.{$table['tablename']}\n";
    }

} catch (PDOException $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
