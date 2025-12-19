<?php
// Script para buscar tablas de requerimientos en multas_reglamentos

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Buscar tablas con 'req' en el nombre
    echo "=== TABLAS CON 'REQ' EN EL NOMBRE ===\n\n";

    $stmt = $pdo->query("
        SELECT
            schemaname,
            tablename,
            (SELECT COUNT(*) FROM information_schema.columns
             WHERE table_schema = schemaname
             AND table_name = tablename) as num_columnas
        FROM pg_tables
        WHERE schemaname = 'public'
        AND tablename ILIKE '%req%'
        ORDER BY tablename
    ");

    $tablas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tablas as $tabla) {
        echo "Tabla: " . $tabla['schemaname'] . "." . $tabla['tablename'] . "\n";
        echo "  Columnas: " . $tabla['num_columnas'] . "\n";

        // Contar registros
        try {
            $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM " . $tabla['schemaname'] . "." . $tabla['tablename']);
            $count = $count_stmt->fetch(PDO::FETCH_ASSOC);
            echo "  Registros: " . number_format($count['total']) . "\n";
        } catch (Exception $e) {
            echo "  Registros: Error al contar\n";
        }

        echo "\n";
    }

    // Mostrar columnas de cada tabla encontrada
    echo "\n=== DETALLE DE COLUMNAS ===\n\n";

    foreach ($tablas as $tabla) {
        echo "Tabla: " . $tabla['tablename'] . "\n";
        echo str_repeat("-", 80) . "\n";

        $stmt = $pdo->query("
            SELECT
                column_name,
                data_type,
                character_maximum_length,
                is_nullable
            FROM information_schema.columns
            WHERE table_schema = '" . $tabla['schemaname'] . "'
            AND table_name = '" . $tabla['tablename'] . "'
            ORDER BY ordinal_position
            LIMIT 20
        ");

        $columnas = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($columnas as $col) {
            $tipo = $col['data_type'];
            if ($col['character_maximum_length']) {
                $tipo .= "(" . $col['character_maximum_length'] . ")";
            }
            echo "  - " . $col['column_name'] . ": " . $tipo . " (" . $col['is_nullable'] . ")\n";
        }

        echo "\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
