<?php
// Buscar tablas relacionadas con proyecto - versión simple
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== BUSCANDO TABLAS CON 'PROYEC' ===\n\n";

    $sql = "
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE tablename ILIKE '%proyec%'
        AND schemaname NOT IN ('pg_catalog', 'information_schema')
        ORDER BY schemaname, tablename
    ";

    $stmt = $pdo->query($sql);
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (!empty($tables)) {
        foreach ($tables as $table) {
            echo "{$table['schemaname']}.{$table['tablename']}\n";

            try {
                $countSql = "SELECT COUNT(*) as total FROM {$table['schemaname']}.{$table['tablename']}";
                $countStmt = $pdo->query($countSql);
                $count = $countStmt->fetch(PDO::FETCH_ASSOC);
                echo "  Registros: {$count['total']}\n\n";
            } catch (Exception $e) {
                echo "  Error: {$e->getMessage()}\n\n";
            }
        }
    } else {
        echo "No se encontraron tablas con 'proyec'\n\n";
    }

    // Buscar con "pres" (presupuesto/proyecto)
    echo "=== BUSCANDO TABLAS CON 'PRES' ===\n\n";

    $sql = "
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE tablename ILIKE '%pres%'
        AND schemaname IN ('comun', 'public', 'db_ingresos')
        ORDER BY schemaname, tablename
        LIMIT 15
    ";

    $stmt = $pdo->query($sql);
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        echo "{$table['schemaname']}.{$table['tablename']}\n";

        try {
            $countSql = "SELECT COUNT(*) as total FROM {$table['schemaname']}.{$table['tablename']}";
            $countStmt = $pdo->query($countSql);
            $count = $countStmt->fetch(PDO::FETCH_ASSOC);
            echo "  Registros: {$count['total']}\n\n";
        } catch (Exception $e) {
            echo "  Error al contar\n\n";
        }
    }

    // Buscar SPs
    echo "=== STORED PROCEDURES RELACIONADOS ===\n\n";

    $spSql = "
        SELECT
            n.nspname as schema,
            p.proname as procedure_name
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE (p.proname ILIKE '%proyec%' OR p.proname ILIKE '%pres%')
        AND n.nspname = 'public'
        ORDER BY p.proname
        LIMIT 10
    ";

    $spStmt = $pdo->query($spSql);
    $sps = $spStmt->fetchAll(PDO::FETCH_ASSOC);

    if (!empty($sps)) {
        foreach ($sps as $sp) {
            echo "{$sp['schema']}.{$sp['procedure_name']}\n";
        }
    } else {
        echo "No se encontraron SPs\n";
    }

    // Si no se encontró nada, buscar en la tabla de pagos datos ejemplo
    echo "\n\n=== OBTENIENDO DATOS DE EJEMPLO ===\n\n";

    $sql = "
        SELECT
            cvepago,
            cvecuenta,
            recaud,
            fecha,
            importe,
            cajero
        FROM comun.pagos
        WHERE fecha >= CURRENT_DATE - INTERVAL '1 year'
        ORDER BY fecha DESC
        LIMIT 5
    ";

    $stmt = $pdo->query($sql);
    $examples = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($examples as $idx => $ex) {
        echo "Ejemplo " . ($idx + 1) . ":\n";
        echo "  ID Pago: {$ex['cvepago']}\n";
        echo "  Cuenta: {$ex['cvecuenta']}\n";
        echo "  Recaud: {$ex['recaud']}\n";
        echo "  Fecha: {$ex['fecha']}\n";
        echo "  Importe: {$ex['importe']}\n";
        echo "  Cajero: {$ex['cajero']}\n\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
