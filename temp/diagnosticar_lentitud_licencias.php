<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "DIAGNÓSTICO DE LENTITUD - LICENCIAS VIGENTES\n";
echo "========================================\n\n";

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$database", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa\n\n";

    // 1. Verificar tamaño de la tabla
    echo "========================================\n";
    echo "1. TAMAÑO DE LA TABLA LICENCIAS\n";
    echo "========================================\n";

    $stmt = $pdo->query("
        SELECT
            COUNT(*) as total_registros,
            pg_size_pretty(pg_total_relation_size('comun.licencias')) as tamano_tabla
        FROM comun.licencias
    ");
    $size = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "Total registros: " . number_format($size['total_registros']) . "\n";
    echo "Tamaño tabla: " . $size['tamano_tabla'] . "\n\n";

    // 2. Verificar índices existentes
    echo "========================================\n";
    echo "2. ÍNDICES EXISTENTES EN comun.licencias\n";
    echo "========================================\n";

    $stmt = $pdo->query("
        SELECT
            indexname,
            indexdef
        FROM pg_indexes
        WHERE schemaname = 'comun'
        AND tablename = 'licencias'
        ORDER BY indexname
    ");

    $indices = $stmt->fetchAll(PDO::FETCH_ASSOC);
    if (count($indices) > 0) {
        foreach ($indices as $idx) {
            echo "✓ " . $idx['indexname'] . "\n";
            echo "  " . $idx['indexdef'] . "\n\n";
        }
    } else {
        echo "⚠ NO HAY ÍNDICES en la tabla licencias\n\n";
    }

    // 3. Verificar estadísticas de la tabla
    echo "========================================\n";
    echo "3. ESTADÍSTICAS DE LA TABLA\n";
    echo "========================================\n";

    $stmt = $pdo->query("
        SELECT
            schemaname,
            relname as tablename,
            last_vacuum,
            last_autovacuum,
            last_analyze,
            last_autoanalyze,
            n_tup_ins as inserts,
            n_tup_upd as updates,
            n_tup_del as deletes
        FROM pg_stat_user_tables
        WHERE schemaname = 'comun'
        AND relname = 'licencias'
    ");

    $stats = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($stats) {
        echo "Último VACUUM: " . ($stats['last_vacuum'] ?: 'Nunca') . "\n";
        echo "Último ANALYZE: " . ($stats['last_analyze'] ?: 'Nunca') . "\n";
        echo "Inserts: " . number_format($stats['inserts']) . "\n";
        echo "Updates: " . number_format($stats['updates']) . "\n";
        echo "Deletes: " . number_format($stats['deletes']) . "\n\n";
    }

    // 4. Probar consulta simple sin filtros
    echo "========================================\n";
    echo "4. PRUEBA: Consulta simple (1 registro)\n";
    echo "========================================\n";

    $start = microtime(true);
    $stmt = $pdo->query("
        SELECT COUNT(*) as total
        FROM comun.licencias l
        WHERE l.licencia > 0
    ");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    $duration = round((microtime(true) - $start) * 1000, 2);

    echo "Total licencias: " . number_format($result['total']) . "\n";
    echo "Tiempo: {$duration}ms\n\n";

    // 5. Probar consulta con JOIN
    echo "========================================\n";
    echo "5. PRUEBA: Consulta con JOIN (10 registros)\n";
    echo "========================================\n";

    $start = microtime(true);
    $stmt = $pdo->query("
        SELECT l.licencia, l.propietario, g.descripcion as giro
        FROM comun.licencias l
        LEFT JOIN comun.c_giros g ON g.id_giro = l.id_giro
        WHERE l.licencia > 0
        ORDER BY l.licencia DESC
        LIMIT 10
    ");
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $duration = round((microtime(true) - $start) * 1000, 2);

    echo "Registros obtenidos: " . count($results) . "\n";
    echo "Tiempo: {$duration}ms\n\n";

    // 6. Probar SP actual
    echo "========================================\n";
    echo "6. PRUEBA: SP actual (10 registros, sin filtros)\n";
    echo "========================================\n";

    $start = microtime(true);
    $stmt = $pdo->prepare("
        SELECT * FROM public.licenciasvigentesfrm_sp_licencias_vigentes(
            1, 10, NULL, NULL, NULL, NULL, NULL, NULL
        )
    ");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $duration = round((microtime(true) - $start) * 1000, 2);

    echo "Registros obtenidos: " . count($results) . "\n";
    if (count($results) > 0) {
        echo "Total en BD: " . number_format($results[0]['total_records']) . "\n";
    }
    echo "Tiempo: {$duration}ms\n\n";

    // 7. Probar SP con filtro de estado
    echo "========================================\n";
    echo "7. PRUEBA: SP con filtro estado=VIGENTE\n";
    echo "========================================\n";

    $start = microtime(true);
    $stmt = $pdo->prepare("
        SELECT * FROM public.licenciasvigentesfrm_sp_licencias_vigentes(
            1, 10, NULL, NULL, 'VIGENTE', NULL, NULL, NULL
        )
    ");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $duration = round((microtime(true) - $start) * 1000, 2);

    echo "Registros obtenidos: " . count($results) . "\n";
    if (count($results) > 0) {
        echo "Total en BD: " . number_format($results[0]['total_records']) . "\n";
    }
    echo "Tiempo: {$duration}ms\n\n";

    // 8. Probar SP con filtro de fechas (últimos 6 meses)
    echo "========================================\n";
    echo "8. PRUEBA: SP con filtro de fechas (últimos 6 meses)\n";
    echo "========================================\n";

    $fechaDesde = date('Y-m-d', strtotime('-6 months'));
    $fechaHasta = date('Y-m-d');

    $start = microtime(true);
    $stmt = $pdo->prepare("
        SELECT * FROM public.licenciasvigentesfrm_sp_licencias_vigentes(
            1, 10, NULL, NULL, NULL, ?, ?, NULL
        )
    ");
    $stmt->execute([$fechaDesde, $fechaHasta]);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $duration = round((microtime(true) - $start) * 1000, 2);

    echo "Fecha desde: $fechaDesde\n";
    echo "Fecha hasta: $fechaHasta\n";
    echo "Registros obtenidos: " . count($results) . "\n";
    if (count($results) > 0) {
        echo "Total en BD: " . number_format($results[0]['total_records']) . "\n";
    }
    echo "Tiempo: {$duration}ms\n\n";

    // 9. Obtener EXPLAIN ANALYZE del SP
    echo "========================================\n";
    echo "9. EXPLAIN ANALYZE del SP\n";
    echo "========================================\n";

    $stmt = $pdo->query("
        EXPLAIN ANALYZE
        SELECT * FROM public.licenciasvigentesfrm_sp_licencias_vigentes(
            1, 10, NULL, NULL, NULL, NULL, NULL, NULL
        )
    ");

    echo "Plan de ejecución:\n";
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "  " . $row['QUERY PLAN'] . "\n";
    }
    echo "\n";

    // 10. Recomendaciones
    echo "========================================\n";
    echo "10. RECOMENDACIONES\n";
    echo "========================================\n\n";

    $needsVacuum = !$stats['last_analyze'] ||
                   (strtotime($stats['last_analyze']) < strtotime('-7 days'));

    if ($needsVacuum) {
        echo "⚠ RECOMENDACIÓN: Ejecutar VACUUM ANALYZE en la tabla\n";
        echo "  Comando: VACUUM ANALYZE comun.licencias;\n\n";
    }

    if (count($indices) < 5) {
        echo "⚠ RECOMENDACIÓN: Faltan índices en la tabla\n";
        echo "  Índices recomendados:\n";
        echo "  - idx_licencias_vigente (vigente)\n";
        echo "  - idx_licencias_id_giro (id_giro)\n";
        echo "  - idx_licencias_zona (zona)\n";
        echo "  - idx_licencias_fecha_otorgamiento (fecha_otorgamiento)\n";
        echo "  - idx_licencias_propietario (propietario)\n\n";
    }

    echo "✅ Diagnóstico completado\n";

} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
