<?php
/**
 * Investigar tablas relacionadas con bloqueo de domicilios
 * Fecha: 2025-11-06
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conectado a la base de datos\n\n";

    // Buscar tablas con 'bloqueo' en el nombre
    echo "=== TABLAS CON 'BLOQUEO' EN EL NOMBRE ===\n";
    $stmt = $pdo->query("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE tablename ILIKE '%bloqueo%'
        ORDER BY schemaname, tablename
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        foreach ($tables as $table) {
            echo "  {$table['schemaname']}.{$table['tablename']}\n";
        }
    } else {
        echo "  No se encontraron tablas con 'bloqueo'\n";
    }

    // Buscar tablas con 'domicilio' en el nombre
    echo "\n=== TABLAS CON 'DOMICILIO' EN EL NOMBRE ===\n";
    $stmt = $pdo->query("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE tablename ILIKE '%domicilio%'
        ORDER BY schemaname, tablename
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        foreach ($tables as $table) {
            echo "  {$table['schemaname']}.{$table['tablename']}\n";
        }
    } else {
        echo "  No se encontraron tablas con 'domicilio'\n";
    }

    // Buscar tablas con 'h_' en el nombre (historial)
    echo "\n=== TABLAS CON 'H_' EN EL NOMBRE (HISTORIAL) ===\n";
    $stmt = $pdo->query("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE tablename ILIKE 'h_%'
        AND (tablename ILIKE '%bloqueo%' OR tablename ILIKE '%domicilio%')
        ORDER BY schemaname, tablename
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        foreach ($tables as $table) {
            echo "  {$table['schemaname']}.{$table['tablename']}\n";
        }
    } else {
        echo "  No se encontraron tablas de historial\n";
    }

    // Buscar en tabla bloqueorfc o bloqueolicencia
    echo "\n=== OTRAS TABLAS DE BLOQUEO ===\n";
    $stmt = $pdo->query("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE schemaname IN ('public', 'comun')
        AND (
            tablename ILIKE '%bloque%'
            OR tablename ILIKE '%bloq%'
        )
        ORDER BY schemaname, tablename
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        foreach ($tables as $table) {
            echo "  {$table['schemaname']}.{$table['tablename']}\n";
        }
    } else {
        echo "  No se encontraron tablas\n";
    }

    echo "\n✓ Búsqueda completada\n";

} catch (Exception $e) {
    echo "✗ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
