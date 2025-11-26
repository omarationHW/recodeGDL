<?php
/**
 * Verificar SP recaudadora_ligapagotra y buscar tablas de trámites
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "🔍 Verificando SP recaudadora_ligapagotra...\n\n";

    // Verificar si el SP existe
    $stmt = $pdo->prepare("
        SELECT
            p.proname,
            pg_catalog.pg_get_function_arguments(p.oid) as args
        FROM pg_catalog.pg_proc p
        LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
        WHERE p.proname = 'recaudadora_ligapagotra'
        AND n.nspname = 'public'
    ");

    $stmt->execute();
    $sp = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($sp) {
        echo "✅ SP encontrado: {$sp['proname']}\n";
        echo "   Argumentos: {$sp['args']}\n\n";
    } else {
        echo "❌ SP no encontrado\n\n";
    }

    // Buscar tablas que contengan "tramite" en su nombre
    echo "🔍 Buscando tablas relacionadas con trámites...\n\n";

    $stmt = $pdo->query("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE schemaname IN ('public', 'catastro_gdl', 'comun', 'db_ingresos')
        AND (
            tablename LIKE '%tramite%'
            OR tablename LIKE '%tram_%'
            OR tablename LIKE '%licencia%'
        )
        ORDER BY schemaname, tablename
    ");

    $tablas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tablas) > 0) {
        echo "Tablas encontradas:\n";
        foreach ($tablas as $tabla) {
            echo "  - {$tabla['schemaname']}.{$tabla['tablename']}\n";
        }
        echo "\n";
    } else {
        echo "No se encontraron tablas relacionadas con trámites\n\n";
    }

    // Buscar en reqdiftransmision si hay algún campo relacionado con trámite
    echo "🔍 Explorando tabla reqdiftransmision...\n\n";

    $stmt = $pdo->query("
        SELECT * FROM catastro_gdl.reqdiftransmision LIMIT 1
    ");

    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($row) {
        echo "Columnas disponibles:\n";
        foreach (array_keys($row) as $col) {
            echo "  - $col\n";
        }
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
