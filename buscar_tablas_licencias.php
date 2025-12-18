<?php
// Buscar tablas relacionadas con licencias en la BD multas_reglamentos

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== BUSCANDO TABLAS CON 'LICENCIA' ===\n\n";

    $stmt = $pdo->query("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE schemaname IN ('public', 'publico')
        AND tablename ILIKE '%licenc%'
        ORDER BY schemaname, tablename
    ");

    $tablas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tablas) > 0) {
        foreach ($tablas as $tabla) {
            echo "Tabla: {$tabla['schemaname']}.{$tabla['tablename']}\n";

            // Contar registros
            try {
                $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM {$tabla['schemaname']}.{$tabla['tablename']}");
                $count = $count_stmt->fetch(PDO::FETCH_ASSOC);
                echo "  Registros: " . number_format($count['total']) . "\n";
            } catch (Exception $e) {
                echo "  Registros: Error\n";
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

            // Ejemplos de datos si tiene columna RFC o similar
            try {
                $has_rfc = false;
                foreach ($columnas as $col) {
                    if (stripos($col['column_name'], 'rfc') !== false) {
                        $has_rfc = true;
                        break;
                    }
                }

                $sample_stmt = $pdo->query("SELECT * FROM {$tabla['schemaname']}.{$tabla['tablename']} LIMIT 3");
                $samples = $sample_stmt->fetchAll(PDO::FETCH_ASSOC);

                if (count($samples) > 0) {
                    echo "  Ejemplos:\n";
                    foreach ($samples as $sample) {
                        $values = array_values($sample);
                        echo "    - " . implode(", ", array_slice($values, 0, 5)) . "\n";
                    }
                }
            } catch (Exception $e) {
                echo "  Ejemplos: Error\n";
            }

            echo "\n" . str_repeat("-", 60) . "\n\n";
        }
    } else {
        echo "No se encontraron tablas con 'licencia'.\n\n";
    }

    // Buscar el stored procedure actual
    echo "\n=== STORED PROCEDURE ACTUAL ===\n\n";

    $sp_stmt = $pdo->query("
        SELECT pg_get_functiondef(p.oid) as definition
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'publico'
        AND p.proname = 'recaudadora_licenciamicrogeneradorecologia'
    ");

    $sp_result = $sp_stmt->fetch(PDO::FETCH_ASSOC);

    if ($sp_result) {
        echo $sp_result['definition'];
    } else {
        echo "No se encontró el stored procedure.\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
