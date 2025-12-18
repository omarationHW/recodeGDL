<?php
// Buscar tablas con conceptos, porcentajes, o información similar

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== BUSCANDO TABLAS CON CONCEPTOS Y PORCENTAJES ===\n\n";

    // Buscar tablas que contengan "concepto", "porcentaje", "tasa", "recargo"
    $stmt = $pdo->query("
        SELECT DISTINCT
            schemaname,
            tablename
        FROM pg_tables
        WHERE schemaname IN ('public', 'publico')
        AND (
            tablename ILIKE '%concepto%'
            OR tablename ILIKE '%porcentaje%'
            OR tablename ILIKE '%tasa%'
            OR tablename ILIKE '%recargo%'
            OR tablename ILIKE '%iva%'
            OR tablename ILIKE '%impuesto%'
        )
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

            // Mostrar algunos ejemplos de datos
            try {
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
                echo "  Ejemplos: No se pueden mostrar\n";
            }

            echo "\n" . str_repeat("-", 60) . "\n\n";
        }
    } else {
        echo "No se encontraron tablas con esos criterios.\n\n";
    }

    // Buscar en tablas de catálogos generales
    echo "\n=== VERIFICANDO TABLAS DE CATÁLOGOS ===\n\n";

    $stmt2 = $pdo->query("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE schemaname IN ('public', 'publico')
        AND tablename ILIKE 'c_%'
        ORDER BY tablename
        LIMIT 20
    ");

    $catalogos = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    foreach ($catalogos as $cat) {
        try {
            $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM {$cat['schemaname']}.{$cat['tablename']}");
            $count = $count_stmt->fetch(PDO::FETCH_ASSOC);

            if ($count['total'] > 0 && $count['total'] < 1000) {
                echo "{$cat['schemaname']}.{$cat['tablename']} ({$count['total']} registros)\n";
            }
        } catch (Exception $e) {
            // Skip
        }
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
