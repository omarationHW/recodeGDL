<?php
// Script para buscar tablas relacionadas con folios de multas

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Buscar tablas con patrones relacionados a multas
    echo "=== BUSCANDO TABLAS RELACIONADAS CON MULTAS ===\n\n";

    $patterns = [
        'multa%',
        '%multa%',
        'folio%',
        '%folio%',
        'acta%',
        '%acta%',
        'infraccion%',
        '%infraccion%'
    ];

    $found_tables = [];
    foreach ($patterns as $pattern) {
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

        foreach ($tables as $t) {
            $key = "{$t['table_schema']}.{$t['table_name']}";
            if (!isset($found_tables[$key])) {
                $found_tables[$key] = $t;
            }
        }
    }

    echo "Tablas encontradas:\n";
    foreach ($found_tables as $t) {
        echo "  ✓ {$t['table_schema']}.{$t['table_name']} ({$t['num_columns']} columnas)\n";
    }

    // 2. Buscar tablas con campos clave
    echo "\n\n=== TABLAS CON CAMPOS DE MULTAS Y ACTAS ===\n";

    $stmt = $pdo->query("
        SELECT DISTINCT
            t.table_schema,
            t.table_name,
            COUNT(DISTINCT c.column_name) as matching_columns,
            array_agg(DISTINCT c.column_name ORDER BY c.column_name) as matched_fields
        FROM information_schema.tables t
        JOIN information_schema.columns c ON t.table_schema = c.table_schema
            AND t.table_name = c.table_name
        WHERE t.table_schema IN ('public', 'publico')
        AND t.table_type = 'BASE TABLE'
        AND (
            c.column_name ILIKE '%acta%'
            OR c.column_name ILIKE '%folio%'
            OR c.column_name ILIKE '%multa%'
        )
        GROUP BY t.table_schema, t.table_name
        HAVING COUNT(DISTINCT c.column_name) >= 2
        ORDER BY matching_columns DESC, t.table_name
        LIMIT 20
    ");
    $candidates = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($candidates as $c) {
        echo "\n{$c['table_schema']}.{$c['table_name']}: {$c['matching_columns']} campos\n";
        echo "  Campos: {$c['matched_fields']}\n";

        // Ver cuántos registros
        try {
            $stmt2 = $pdo->query("SELECT COUNT(*) as total FROM {$c['table_schema']}.{$c['table_name']}");
            $count = $stmt2->fetch(PDO::FETCH_ASSOC);
            echo "  Total: " . number_format($count['total']) . " registros\n";
        } catch (Exception $e) {
            echo "  Error: " . $e->getMessage() . "\n";
        }
    }

    // 3. Buscar la tabla más prometedora y ver su estructura
    echo "\n\n=== EXPLORANDO TABLAS CANDIDATAS ===\n";

    // Buscar específicamente tablas de multas
    $tablas_multas = ['public.multas', 'publico.multas', 'public.multampal', 'publico.multampal'];

    foreach ($tablas_multas as $tabla_check) {
        list($schema, $table) = explode('.', $tabla_check);

        echo "\n--- Verificando {$tabla_check} ---\n";
        try {
            // Ver estructura
            $stmt = $pdo->query("
                SELECT column_name, data_type, character_maximum_length
                FROM information_schema.columns
                WHERE table_schema = '$schema'
                AND table_name = '$table'
                ORDER BY ordinal_position
            ");
            $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

            if (count($columns) > 0) {
                echo "Estructura (" . count($columns) . " columnas):\n";
                foreach ($columns as $col) {
                    $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
                    echo "  - {$col['column_name']}: {$col['data_type']}{$length}\n";
                }

                // Contar registros
                $stmt = $pdo->query("SELECT COUNT(*) as total FROM {$schema}.{$table}");
                $total = $stmt->fetch(PDO::FETCH_ASSOC);
                echo "Total registros: " . number_format($total['total']) . "\n";

                // Muestra
                if ($total['total'] > 0) {
                    $stmt = $pdo->query("SELECT * FROM {$schema}.{$table} LIMIT 2");
                    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

                    echo "\nMuestra de datos:\n";
                    foreach ($rows as $i => $row) {
                        echo "  Registro " . ($i + 1) . ":\n";
                        $count = 0;
                        foreach ($row as $key => $val) {
                            if ($count >= 15) break;
                            $val = is_null($val) ? 'NULL' : (is_string($val) ? substr(trim($val), 0, 40) : $val);
                            echo "    $key: $val\n";
                            $count++;
                        }
                        echo "\n";
                    }
                }
            }
        } catch (Exception $e) {
            echo "  No existe\n";
        }
    }

    echo "\n✅ Búsqueda completada!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
