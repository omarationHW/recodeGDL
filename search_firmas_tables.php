<?php
// Script para buscar tablas relacionadas con firmas electrónicas

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Buscar tablas con patrones relacionados a firmas
    echo "=== BUSCANDO TABLAS RELACIONADAS CON FIRMAS ===\n\n";

    $patterns = [
        'firma%',
        '%firma%',
        '%sign%',
        'digital%',
        'certificado%',
        '%cert%',
        'documento%',
        '%documento%',
        '%auth%',
        '%valid%',
        'folio%',
        '%usuario%'
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

    // 2. Buscar todas las tablas y ver cuáles tienen campos relacionados con firma/usuario/fecha
    echo "\n\n=== BUSCANDO TABLAS CON CAMPOS RELACIONADOS ===\n";

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
            c.column_name ILIKE '%firma%'
            OR c.column_name ILIKE '%sign%'
            OR c.column_name ILIKE '%hash%'
            OR c.column_name ILIKE '%certificado%'
            OR c.column_name ILIKE '%digital%'
        )
        GROUP BY t.table_schema, t.table_name
        ORDER BY matching_columns DESC, t.table_name
    ");
    $candidates = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Tablas con campos relacionados con firmas:\n";
    foreach ($candidates as $c) {
        echo "  • {$c['table_schema']}.{$c['table_name']}: {$c['matching_columns']} campos\n";
        echo "    Campos: {$c['matched_fields']}\n\n";
    }

    // 3. Buscar tablas que puedan almacenar registros de documentos/folios
    echo "\n=== TABLAS CON FOLIO Y USUARIO (posibles para firmas) ===\n";

    $stmt = $pdo->query("
        SELECT DISTINCT t.table_schema, t.table_name,
               array_agg(DISTINCT c.column_name ORDER BY c.column_name) as columns
        FROM information_schema.tables t
        JOIN information_schema.columns c ON t.table_schema = c.table_schema
            AND t.table_name = c.table_name
        WHERE t.table_schema IN ('public', 'publico')
        AND t.table_type = 'BASE TABLE'
        AND EXISTS (
            SELECT 1 FROM information_schema.columns c2
            WHERE c2.table_schema = t.table_schema
            AND c2.table_name = t.table_name
            AND c2.column_name ILIKE '%folio%'
        )
        AND EXISTS (
            SELECT 1 FROM information_schema.columns c3
            WHERE c3.table_schema = t.table_schema
            AND c3.table_name = t.table_name
            AND (c3.column_name ILIKE '%usuario%' OR c3.column_name ILIKE '%captur%')
        )
        GROUP BY t.table_schema, t.table_name
        ORDER BY t.table_name
        LIMIT 20
    ");

    $tables_folio = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables_folio as $t) {
        echo "\n{$t['table_schema']}.{$t['table_name']}\n";
        echo "  Columnas: {$t['columns']}\n";

        // Ver cuántos registros tiene
        try {
            $stmt2 = $pdo->query("SELECT COUNT(*) as total FROM {$t['table_schema']}.{$t['table_name']}");
            $count = $stmt2->fetch(PDO::FETCH_ASSOC);
            echo "  Total registros: " . number_format($count['total']) . "\n";
        } catch (Exception $e) {
            echo "  Error al contar: " . $e->getMessage() . "\n";
        }
    }

    echo "\n✅ Búsqueda completada!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
