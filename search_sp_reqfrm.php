<?php
// Script para buscar el stored procedure relacionado con ReqFrm.vue

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Buscar stored procedures con nombres relacionados
    echo "=== BUSCANDO STORED PROCEDURES RELACIONADOS CON REQFRM ===\n\n";

    $patterns = [
        '%reqfrm%',
        '%req_frm%',
        '%requerimiento%',
        '%guardar_req%',
        '%save_req%'
    ];

    foreach ($patterns as $pattern) {
        $stmt = $pdo->prepare("
            SELECT
                n.nspname as schema,
                p.proname as function_name,
                pg_get_function_identity_arguments(p.oid) as arguments
            FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE n.nspname IN ('public', 'publico')
            AND p.proname ILIKE ?
            ORDER BY p.proname
        ");
        $stmt->execute([$pattern]);
        $procs = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($procs as $proc) {
            echo "✓ {$proc['schema']}.{$proc['function_name']}({$proc['arguments']})\n";
        }
    }

    // 2. Ver definición de los stored procedures encontrados
    echo "\n\n=== DEFINICIONES DE STORED PROCEDURES ===\n";

    $stmt = $pdo->query("
        SELECT
            n.nspname as schema,
            p.proname as function_name,
            pg_get_functiondef(p.oid) as definition
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname IN ('public', 'publico')
        AND (
            p.proname ILIKE '%reqfrm%' OR
            p.proname ILIKE '%req_frm%' OR
            p.proname ILIKE '%requerimiento%'
        )
        ORDER BY p.proname
    ");
    $procs = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($procs as $proc) {
        echo "\n\n--- {$proc['schema']}.{$proc['function_name']} ---\n";
        echo $proc['definition'];
        echo "\n";
    }

    // 3. Buscar tablas de requerimientos existentes
    echo "\n\n=== TABLAS DE REQUERIMIENTOS EXISTENTES ===\n\n";

    $stmt = $pdo->query("
        SELECT
            schemaname,
            tablename,
            (SELECT COUNT(*) FROM (SELECT 1 FROM pg_tables WHERE schemaname = t.schemaname AND tablename = t.tablename LIMIT 1) x) as exists
        FROM pg_tables t
        WHERE schemaname IN ('public', 'publico')
        AND tablename ILIKE '%req%'
        ORDER BY tablename
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        echo "  • {$table['schemaname']}.{$table['tablename']}\n";

        // Contar registros
        try {
            $stmt2 = $pdo->query("SELECT COUNT(*) as total FROM {$table['schemaname']}.{$table['tablename']}");
            $count = $stmt2->fetch(PDO::FETCH_ASSOC);
            echo "    Total: " . number_format($count['total']) . " registros\n";
        } catch (Exception $e) {
            echo "    Error: " . $e->getMessage() . "\n";
        }
    }

    echo "\n✅ Búsqueda completada!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
