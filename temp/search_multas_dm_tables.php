<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    echo "=== BUSCANDO TABLAS DE MULTAS ===\n\n";

    // Buscar tablas que contengan 'multa' en su nombre
    $sql = "
        SELECT
            schemaname,
            tablename,
            (SELECT COUNT(*) FROM information_schema.columns
             WHERE table_schema = schemaname AND table_name = tablename) as num_columns
        FROM pg_tables
        WHERE tablename LIKE '%multa%'
        ORDER BY schemaname, tablename
    ";

    $stmt = $pdo->query($sql);
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Tablas encontradas: " . count($tables) . "\n\n";

    foreach ($tables as $table) {
        echo "Schema: {$table['schemaname']}, Tabla: {$table['tablename']}, Columnas: {$table['num_columns']}\n";
    }

    // Buscar en tablas específicas comunes
    echo "\n=== EXPLORANDO TABLAS PRINCIPALES ===\n\n";

    $tablesToCheck = [
        'comun.multas',
        'comun.ta08',
        'db_ingresos.multas',
        'public.multas',
        'comunX.multas',
        'multas_reglamentos.multas',
        'comun.multascontrib',
        'comun.multasctb'
    ];

    foreach ($tablesToCheck as $fullTable) {
        list($schema, $table) = explode('.', $fullTable);

        $checkSql = "
            SELECT COUNT(*) as total
            FROM information_schema.tables
            WHERE table_schema = :schema AND table_name = :table
        ";

        $stmt = $pdo->prepare($checkSql);
        $stmt->execute(['schema' => $schema, 'table' => $table]);
        $exists = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($exists['total'] > 0) {
            echo "\n✓ Tabla $fullTable existe\n";

            // Obtener columnas
            $colSql = "
                SELECT column_name, data_type
                FROM information_schema.columns
                WHERE table_schema = :schema AND table_name = :table
                ORDER BY ordinal_position
                LIMIT 20
            ";

            $stmt = $pdo->prepare($colSql);
            $stmt->execute(['schema' => $schema, 'table' => $table]);
            $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

            echo "  Columnas principales:\n";
            foreach ($columns as $col) {
                echo "    - {$col['column_name']} ({$col['data_type']})\n";
            }

            // Obtener muestra de datos
            $dataSql = "SELECT * FROM $fullTable LIMIT 3";
            try {
                $stmt = $pdo->query($dataSql);
                $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

                echo "  Total registros: ";
                $countSql = "SELECT COUNT(*) as total FROM $fullTable";
                $stmt = $pdo->query($countSql);
                $count = $stmt->fetch(PDO::FETCH_ASSOC);
                echo $count['total'] . "\n";

                if (!empty($rows)) {
                    echo "  Muestra de datos:\n";
                    foreach ($rows as $row) {
                        echo "    " . json_encode($row, JSON_UNESCAPED_UNICODE) . "\n";
                    }
                }
            } catch (Exception $e) {
                echo "  Error al obtener datos: " . $e->getMessage() . "\n";
            }
        }
    }

} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    echo "Trace: " . $e->getTraceAsString() . "\n";
}
