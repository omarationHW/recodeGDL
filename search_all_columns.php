<?php
// Script para buscar cualquier campo relacionado con vehículos

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Buscar CUALQUIER campo que pueda estar relacionado
    echo "=== BUSCANDO CAMPOS VEHICULARES ===\n";

    $keywords = ['plac', 'vehic', 'auto', 'marca', 'model', 'serie', 'motor', 'carro'];

    foreach ($keywords as $keyword) {
        echo "\n--- Campos con '$keyword' ---\n";
        $stmt = $pdo->query("
            SELECT DISTINCT table_schema, table_name, column_name
            FROM information_schema.columns
            WHERE column_name ILIKE '%$keyword%'
            AND table_schema IN ('public', 'publico')
            ORDER BY table_name
            LIMIT 10
        ");
        $campos = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($campos) > 0) {
            foreach ($campos as $c) {
                echo "  {$c['table_schema']}.{$c['table_name']}.{$c['column_name']}\n";
            }
        } else {
            echo "  (No encontrado)\n";
        }
    }

    // Buscar todas las tablas y ver si alguna podría ser de tránsito
    echo "\n\n=== TODAS LAS TABLAS EN public/publico ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_schema IN ('public', 'publico')
        AND table_type = 'BASE TABLE'
        ORDER BY table_name
        LIMIT 100
    ");
    $todasTablas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Total de tablas: " . count($todasTablas) . "\n";
    echo "Primeras 50 tablas:\n";
    foreach (array_slice($todasTablas, 0, 50) as $t) {
        echo "  {$t['table_schema']}.{$t['table_name']}\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
