<?php
// Script para buscar tablas relacionadas con requerimientos y sus estadísticas

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Ver las principales tablas de requerimientos
    echo "=== PRINCIPALES TABLAS DE REQUERIMIENTOS ===\n\n";

    $tablas_req = [
        ['publico', 'reqmultas'],
        ['public', 'reqbflicencias'],
        ['public', 'reqanuncios'],
        ['publico', 'h_reqpredial'],
        ['public', 'reqbfpredial'],
        ['public', 'reqdiftransmision']
    ];

    foreach ($tablas_req as $t) {
        $schema = $t[0];
        $table = $t[1];

        echo "--- {$schema}.{$table} ---\n";

        try {
            // Contar registros
            $stmt = $pdo->query("SELECT COUNT(*) as total FROM {$schema}.{$table}");
            $total = $stmt->fetch(PDO::FETCH_ASSOC);
            echo "Total registros: " . number_format($total['total']) . "\n";

            // Ver campos clave
            $stmt = $pdo->query("
                SELECT column_name
                FROM information_schema.columns
                WHERE table_schema = '$schema'
                AND table_name = '$table'
                AND (
                    column_name ILIKE '%ejecut%'
                    OR column_name ILIKE '%recaud%'
                    OR column_name ILIKE '%vigencia%'
                    OR column_name ILIKE '%estatus%'
                    OR column_name ILIKE '%total%'
                    OR column_name ILIKE '%folio%'
                    OR column_name ILIKE '%cvepago%'
                )
                ORDER BY column_name
            ");
            $campos = $stmt->fetchAll(PDO::FETCH_COLUMN);

            if (count($campos) > 0) {
                echo "Campos clave: " . implode(', ', $campos) . "\n";
            }

            // Muestra de vigencia/estatus
            if (in_array('vigencia', $campos)) {
                $stmt = $pdo->query("
                    SELECT vigencia, COUNT(*) as cantidad
                    FROM {$schema}.{$table}
                    WHERE vigencia IS NOT NULL
                    GROUP BY vigencia
                    ORDER BY cantidad DESC
                    LIMIT 5
                ");
                $vigencias = $stmt->fetchAll(PDO::FETCH_ASSOC);
                if (count($vigencias) > 0) {
                    echo "Valores de vigencia:\n";
                    foreach ($vigencias as $v) {
                        echo "  - {$v['vigencia']}: " . number_format($v['cantidad']) . "\n";
                    }
                }
            }

            echo "\n";
        } catch (Exception $e) {
            echo "Error: " . $e->getMessage() . "\n\n";
        }
    }

    // 2. Ver estructura detallada de reqmultas (la más grande)
    echo "\n=== ESTRUCTURA DETALLADA DE publico.reqmultas ===\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'publico'
        AND table_name = 'reqmultas'
        ORDER BY ordinal_position
    ");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($columns as $col) {
        $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
        echo "  - {$col['column_name']}: {$col['data_type']}{$length}\n";
    }

    // Muestra de datos
    echo "\nMuestra de datos (3 registros):\n";
    $stmt = $pdo->query("
        SELECT cvereq, folioreq, axoreq, cveejecut, recaud, vigencia, total, multas, cvepago
        FROM publico.reqmultas
        LIMIT 3
    ");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($rows as $i => $row) {
        echo "\n  Registro " . ($i + 1) . ":\n";
        foreach ($row as $key => $val) {
            $val = is_null($val) ? 'NULL' : $val;
            echo "    $key: $val\n";
        }
    }

    // 3. Ver estructura de reqbflicencias
    echo "\n\n=== ESTRUCTURA DE public.reqbflicencias ===\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'reqbflicencias'
        AND (
            column_name ILIKE '%ejecut%'
            OR column_name ILIKE '%recaud%'
            OR column_name ILIKE '%vigencia%'
            OR column_name ILIKE '%total%'
            OR column_name ILIKE '%folio%'
        )
        ORDER BY ordinal_position
    ");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($columns as $col) {
        echo "  - {$col['column_name']}: {$col['data_type']}\n";
    }

    echo "\n✅ Búsqueda completada!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
