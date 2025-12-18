<?php
// Buscar tablas relacionadas con cheques en la BD multas_reglamentos

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== BUSCANDO TABLAS CON 'CHEQUE' O 'CHQ' ===\n\n";

    $stmt = $pdo->query("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE schemaname IN ('public', 'publico')
        AND (tablename ILIKE '%cheque%' OR tablename ILIKE '%chq%')
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

            // Ejemplos de datos
            try {
                $sample_stmt = $pdo->query("SELECT * FROM {$tabla['schemaname']}.{$tabla['tablename']} LIMIT 3");
                $samples = $sample_stmt->fetchAll(PDO::FETCH_ASSOC);

                if (count($samples) > 0) {
                    echo "  Ejemplos:\n";
                    foreach ($samples as $sample) {
                        $values = array_values($sample);
                        echo "    - " . implode(", ", array_slice($values, 0, 6)) . "\n";
                    }
                }
            } catch (Exception $e) {
                echo "  Ejemplos: Error\n";
            }

            echo "\n" . str_repeat("-", 60) . "\n\n";
        }
    } else {
        echo "No se encontraron tablas con 'cheque' o 'chq'.\n\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
