<?php
// Script para buscar tablas relacionadas con descuentos de recargos

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Buscar tablas con patrones relacionados a descuentos de recargos
    echo "=== BUSCANDO TABLAS RELACIONADAS CON DESCUENTOS DE RECARGOS ===\n\n";

    $patterns = [
        'desc%recarg%',
        'recargo%',
        'actualiz%',
        'desc%torc%',
        '%torec%'
    ];

    foreach ($patterns as $pattern) {
        echo "Patrón: $pattern\n";
        $stmt = $pdo->prepare("
            SELECT table_schema, table_name,
                   (SELECT COUNT(*) FROM information_schema.columns
                    WHERE table_schema = t.table_schema
                    AND table_name = t.table_name) as num_columns
            FROM information_schema.tables t
            WHERE table_schema IN ('public', 'publico')
            AND table_type = 'BASE TABLE'
            AND table_name LIKE ?
            ORDER BY table_name
        ");
        $stmt->execute([$pattern]);
        $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($tables) > 0) {
            foreach ($tables as $t) {
                echo "  ✓ {$t['table_schema']}.{$t['table_name']} ({$t['num_columns']} columnas)\n";
            }
        }
    }

    // 2. Buscar tablas que tengan los campos clave
    echo "\n\n=== BUSCANDO TABLAS CON CAMPOS RELACIONADOS ===\n";

    $keyFields = ['cvecuenta', 'axoini', 'bimini', 'axofin', 'bimfin', 'porcentaje'];

    echo "Buscando tablas que contengan los campos: " . implode(', ', $keyFields) . "\n\n";

    $stmt = $pdo->query("
        SELECT
            c.table_schema,
            c.table_name,
            COUNT(DISTINCT c.column_name) as matching_columns,
            array_agg(DISTINCT c.column_name ORDER BY c.column_name) as matched_fields
        FROM information_schema.columns c
        WHERE c.table_schema IN ('public', 'publico')
        AND LOWER(c.column_name) IN ('cvecuenta', 'axoini', 'bimini', 'axofin', 'bimfin', 'porcentaje', 'vigencia', 'fecalta')
        GROUP BY c.table_schema, c.table_name
        HAVING COUNT(DISTINCT c.column_name) >= 3
        ORDER BY matching_columns DESC, c.table_name
        LIMIT 20
    ");
    $candidates = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Tablas candidatas encontradas:\n";
    foreach ($candidates as $c) {
        echo "  • {$c['table_schema']}.{$c['table_name']}: {$c['matching_columns']} campos coinciden\n";
        echo "    Campos: {$c['matched_fields']}\n";
    }

    // 3. Explorar las tablas más prometedoras
    echo "\n\n=== EXPLORANDO TABLAS CANDIDATAS ===\n";

    foreach ($candidates as $i => $c) {
        if ($i >= 5) break; // Solo las primeras 5

        $schema = $c['table_schema'];
        $table = $c['table_name'];

        echo "\n--- {$schema}.{$table} ---\n";

        // Estructura
        $stmt = $pdo->query("
            SELECT column_name, data_type, character_maximum_length
            FROM information_schema.columns
            WHERE table_schema = '$schema'
            AND table_name = '$table'
            ORDER BY ordinal_position
        ");
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "Estructura (" . count($columns) . " columnas):\n";
        foreach ($columns as $col) {
            $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
            echo "  - {$col['column_name']}: {$col['data_type']}{$length}\n";
        }

        // Contar registros
        try {
            $stmt = $pdo->query("SELECT COUNT(*) as total FROM {$schema}.{$table}");
            $total = $stmt->fetch(PDO::FETCH_ASSOC);
            echo "Total registros: " . number_format($total['total']) . "\n";

            // Muestra de datos
            if ($total['total'] > 0) {
                $stmt = $pdo->query("SELECT * FROM {$schema}.{$table} LIMIT 3");
                $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

                echo "\nMuestra de datos:\n";
                foreach ($rows as $j => $row) {
                    echo "  Registro " . ($j + 1) . ":\n";
                    foreach ($row as $key => $val) {
                        $val = is_null($val) ? 'NULL' : (is_string($val) ? substr(trim($val), 0, 40) : $val);
                        echo "    $key: $val\n";
                    }
                    echo "\n";
                }
            }
        } catch (Exception $e) {
            echo "  Error al contar: " . $e->getMessage() . "\n";
        }
    }

    echo "\n✅ Búsqueda completada!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
