<?php
// Explorar tablas públicas para el SP
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== EXPLORANDO TABLAS PARA PUBLICOS_UPD ===\n\n";

    // Buscar tablas de catálogos que podrían actualizarse
    echo "--- Tablas de catálogos en public ---\n";
    $sql = "
        SELECT tablename,
               (SELECT COUNT(*) FROM information_schema.columns
                WHERE table_schema = 'public' AND table_name = t.tablename) as col_count
        FROM pg_tables t
        WHERE schemaname = 'public'
        AND (tablename LIKE 'c_%' OR tablename LIKE '%_cat' OR tablename LIKE '%_catalog')
        ORDER BY tablename
        LIMIT 20
    ";

    $stmt = $pdo->query($sql);
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        echo "public.{$table['tablename']} ({$table['col_count']} columnas)\n";
    }

    // Ver estructura de c_conceptos (probablemente la tabla principal)
    echo "\n--- ESTRUCTURA DE public.c_conceptos ---\n";
    $sqlStruct = "
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'c_conceptos'
        ORDER BY ordinal_position
    ";

    $stmtStruct = $pdo->query($sqlStruct);
    $cols = $stmtStruct->fetchAll(PDO::FETCH_ASSOC);

    foreach ($cols as $col) {
        $type = $col['data_type'];
        if ($col['character_maximum_length']) {
            $type .= "({$col['character_maximum_length']})";
        }
        echo "  {$col['column_name']}: {$type}\n";
    }

    // Obtener ejemplos
    echo "\n--- EJEMPLOS DE DATOS (c_conceptos) ---\n";
    $sqlEx = "SELECT * FROM public.c_conceptos LIMIT 5";
    $stmtEx = $pdo->query($sqlEx);
    $examples = $stmtEx->fetchAll(PDO::FETCH_ASSOC);

    foreach ($examples as $idx => $ex) {
        echo "\nRegistro " . ($idx + 1) . ":\n";
        foreach ($ex as $key => $value) {
            if ($value !== null && trim($value) !== '') {
                $displayValue = strlen($value) > 50 ? substr($value, 0, 50) . '...' : $value;
                echo "  $key: $displayValue\n";
            }
        }
    }

    // Buscar otras tablas actualizables
    echo "\n\n--- OTRAS TABLAS POTENCIALES ---\n";
    $sql2 = "
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        AND tablename IN ('anuncio_400', 'bloqueo', 'c_actividades_lic', 'c_calles', 'c_poblaciones', 'c_programas')
        ORDER BY tablename
    ";

    $stmt2 = $pdo->query($sql2);
    $tables2 = $stmt2->fetchAll(PDO::FETCH_COLUMN);

    foreach ($tables2 as $t) {
        $countSql = "SELECT COUNT(*) as total FROM public.$t";
        $countStmt = $pdo->query($countSql);
        $count = $countStmt->fetch(PDO::FETCH_ASSOC);
        echo "public.$t - {$count['total']} registros\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
