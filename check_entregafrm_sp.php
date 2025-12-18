<?php
// Script para revisar el stored procedure actual de entregafrm

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Ver el stored procedure actual
    echo "=== STORED PROCEDURE ACTUAL: recaudadora_entregafrm ===\n\n";

    $stmt = $pdo->query("
        SELECT pg_get_functiondef(oid) as definition
        FROM pg_proc
        WHERE proname = 'recaudadora_entregafrm'
        AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'publico')
    ");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo $result['definition'];
        echo "\n\n";
    } else {
        echo "No se encontró el stored procedure.\n\n";
    }

    // Buscar tablas que tengan folio y información de entrega
    echo "\n=== TABLAS CON FOLIO Y CAMPOS DE ENTREGA ===\n\n";

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
            AND (c3.column_name ILIKE '%entreg%' OR c3.column_name ILIKE '%recib%' OR c3.column_name ILIKE '%fecprac%')
        )
        GROUP BY t.table_schema, t.table_name
        ORDER BY t.table_name
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $t) {
        echo "{$t['table_schema']}.{$t['table_name']}\n";
        echo "  Columnas: {$t['columns']}\n\n";
    }

    echo "\n✅ Revisión completada!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
