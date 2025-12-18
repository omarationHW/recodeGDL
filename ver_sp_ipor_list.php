<?php
// Ver el stored procedure ipor_sp_list

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== CONTENIDO DEL STORED PROCEDURE ipor_sp_list ===\n\n";

    $stmt = $pdo->query("
        SELECT pg_get_functiondef(p.oid) as definition
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
        AND p.proname = 'ipor_sp_list'
    ");

    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo $result['definition'];
    } else {
        echo "No se encontró el stored procedure ipor_sp_list.\n";
    }

    // Buscar tablas con información de porcentajes
    echo "\n\n=== BUSCANDO TABLAS CON PORCENTAJES ===\n\n";

    $stmt2 = $pdo->query("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE schemaname IN ('public', 'publico')
        AND tablename ILIKE '%por%'
        ORDER BY schemaname, tablename
    ");

    $tablas = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tablas as $tabla) {
        echo "Tabla: {$tabla['schemaname']}.{$tabla['tablename']}\n";

        // Contar registros
        try {
            $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM {$tabla['schemaname']}.{$tabla['tablename']}");
            $count = $count_stmt->fetch(PDO::FETCH_ASSOC);
            echo "  Registros: " . number_format($count['total']) . "\n";
        } catch (Exception $e) {
            echo "  Registros: No se puede contar\n";
        }

        // Ver columnas
        $col_stmt = $pdo->prepare("
            SELECT column_name, data_type
            FROM information_schema.columns
            WHERE table_schema = ? AND table_name = ?
            ORDER BY ordinal_position
        ");
        $col_stmt->execute([$tabla['schemaname'], $tabla['tablename']]);
        $columnas = $col_stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "  Columnas:\n";
        foreach ($columnas as $col) {
            echo "    - {$col['column_name']} ({$col['data_type']})\n";
        }
        echo "\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
