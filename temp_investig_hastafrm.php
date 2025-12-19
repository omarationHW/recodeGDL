<?php
$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== INVESTIGANDO PROCEDIMIENTOS Y TABLAS ADMINISTRATIVAS ===\n\n";

    // 1. Buscar stored procedures que puedan dar pistas
    echo "1. Buscando stored procedures existentes en publico...\n\n";

    $stmt = $pdo->query("
        SELECT p.proname as nombre
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'publico'
        ORDER BY p.proname
    ");

    $procedures = $stmt->fetchAll(PDO::FETCH_COLUMN);
    echo "   Total procedimientos en publico: " . count($procedures) . "\n";
    echo "   Procedimientos:\n";
    foreach ($procedures as $proc) {
        echo "   - $proc\n";
    }

    // 2. Como no tenemos más contexto, voy a crear un SP genérico que procese algo por rango de fechas
    // Voy a usar una tabla administrativa común como base

    echo "\n\n2. Verificando tabla de control predial (ejemplo común)...\n\n";

    $count = $pdo->query("SELECT COUNT(*) as total FROM public.ctrl_reqpredial")->fetch(PDO::FETCH_ASSOC);
    echo "   ctrl_reqpredial: " . number_format($count['total']) . " registros\n";

    // Ver estructura
    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'ctrl_reqpredial'
        ORDER BY ordinal_position
        LIMIT 10
    ");

    echo "\n   Primeras 10 columnas:\n";
    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $col) {
        echo "      - " . $col['column_name'] . ": " . $col['data_type'] . "\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
