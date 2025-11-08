<?php
/**
 * Investigación específica de tablas de liga
 * Fecha: 2025-11-06
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conectado a servidor real\n\n";

    // Tablas candidatas
    $tablasCandidatas = [
        'public.liga_req',
        'public.giro_req',
        'public.c_girosreq'
    ];

    foreach ($tablasCandidatas as $tabla) {
        echo str_repeat("=", 70) . "\n";
        echo "TABLA: $tabla\n";
        echo str_repeat("=", 70) . "\n";

        // Ver estructura
        list($schema, $tablename) = explode('.', $tabla);

        $checkStructure = "
        SELECT
            column_name,
            data_type,
            character_maximum_length,
            is_nullable
        FROM information_schema.columns
        WHERE table_schema = '$schema'
        AND table_name = '$tablename'
        ORDER BY ordinal_position
        ";

        try {
            $stmt = $pdo->query($checkStructure);
            $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

            if (count($columns) > 0) {
                echo "\nESTRUCTURA:\n";
                foreach ($columns as $col) {
                    $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
                    $nullable = $col['is_nullable'] === 'YES' ? 'NULL' : 'NOT NULL';
                    echo "  - {$col['column_name']}: {$col['data_type']}$length [$nullable]\n";
                }

                // Ver primeros 5 registros
                echo "\nDATA SAMPLE (5 registros):\n";
                $dataSample = $pdo->query("SELECT * FROM $tabla LIMIT 5");
                $rows = $dataSample->fetchAll(PDO::FETCH_ASSOC);

                if (count($rows) > 0) {
                    foreach ($rows as $row) {
                        echo "  " . json_encode($row, JSON_UNESCAPED_UNICODE) . "\n";
                    }

                    // Contar registros totales
                    $countStmt = $pdo->query("SELECT COUNT(*) as total FROM $tabla");
                    $count = $countStmt->fetch(PDO::FETCH_ASSOC);
                    echo "\nTOTAL REGISTROS: {$count['total']}\n";
                } else {
                    echo "  ⚠ Tabla vacía\n";
                }
            } else {
                echo "  ⚠ Tabla no encontrada\n";
            }
        } catch (Exception $e) {
            echo "  ✗ Error: " . $e->getMessage() . "\n";
        }

        echo "\n\n";
    }

    // Ver estructura de c_giros
    echo str_repeat("=", 70) . "\n";
    echo "TABLA: comun.c_giros (GIROS PRINCIPALES)\n";
    echo str_repeat("=", 70) . "\n";

    $checkGiros = "
    SELECT
        column_name,
        data_type,
        character_maximum_length
    FROM information_schema.columns
    WHERE table_schema = 'comun'
    AND table_name = 'c_giros'
    ORDER BY ordinal_position
    ";

    $stmt = $pdo->query($checkGiros);
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "\nESTRUCTURA:\n";
    foreach ($columns as $col) {
        $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
        echo "  - {$col['column_name']}: {$col['data_type']}$length\n";
    }

    echo "\nDATA SAMPLE (5 giros):\n";
    $dataSample = $pdo->query("SELECT id_giro, descripcion FROM comun.c_giros ORDER BY id_giro LIMIT 5");
    $giros = $dataSample->fetchAll(PDO::FETCH_ASSOC);
    foreach ($giros as $giro) {
        echo "  ID: {$giro['id_giro']} - " . trim($giro['descripcion']) . "\n";
    }

    echo "\n✓ Investigación completada\n";

} catch (Exception $e) {
    echo "✗ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
