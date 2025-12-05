<?php
// Buscar tablas relacionadas con escrituras

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'postgres';
$password = 'sistemas';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Buscando tablas relacionadas con 'escrituras'...\n\n";

    // Buscar tablas que contengan 'escrit' en el nombre
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name ILIKE '%escrit%'
        AND table_schema IN ('catastro_gdl', 'comun', 'comunX', 'public', 'db_ingresos')
        ORDER BY table_schema, table_name
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (empty($tables)) {
        echo "No se encontraron tablas con 'escrit' en el nombre.\n";
        echo "Buscando tablas relacionadas con '400'...\n\n";

        // Buscar tablas que contengan '400' en el nombre
        $stmt = $pdo->query("
            SELECT table_schema, table_name
            FROM information_schema.tables
            WHERE table_name ILIKE '%400%'
            AND table_schema IN ('catastro_gdl', 'comun', 'comunX', 'public', 'db_ingresos')
            ORDER BY table_schema, table_name
        ");

        $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    if (!empty($tables)) {
        echo "Tablas encontradas:\n";
        foreach ($tables as $table) {
            echo "  - {$table['table_schema']}.{$table['table_name']}\n";

            // Obtener estructura de la tabla
            $stmt2 = $pdo->prepare("
                SELECT column_name, data_type, character_maximum_length
                FROM information_schema.columns
                WHERE table_schema = :schema AND table_name = :table
                ORDER BY ordinal_position
                LIMIT 10
            ");
            $stmt2->execute([
                'schema' => $table['table_schema'],
                'table' => $table['table_name']
            ]);
            $columns = $stmt2->fetchAll(PDO::FETCH_ASSOC);

            echo "    Columnas: ";
            $colNames = array_map(function($c) { return $c['column_name']; }, $columns);
            echo implode(', ', $colNames) . "\n";

            // Obtener muestra de datos
            $sampleQuery = "SELECT * FROM {$table['table_schema']}.{$table['table_name']} LIMIT 3";
            try {
                $stmt3 = $pdo->query($sampleQuery);
                $sample = $stmt3->fetchAll(PDO::FETCH_ASSOC);
                if (!empty($sample)) {
                    echo "    Registros: " . count($sample) . " (muestra)\n";
                }
            } catch (Exception $e) {
                echo "    (No se pudo obtener muestra)\n";
            }
            echo "\n";
        }
    } else {
        echo "No se encontraron tablas relacionadas.\n";
        echo "\nBuscando en otras tablas de catastro...\n";

        // Listar tablas de catastro_gdl que puedan estar relacionadas
        $stmt = $pdo->query("
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = 'catastro_gdl'
            AND table_name ILIKE '%doc%'
            OR table_name ILIKE '%form%'
            OR table_name ILIKE '%reg%'
            ORDER BY table_name
            LIMIT 20
        ");

        $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
        if (!empty($tables)) {
            echo "Tablas posiblemente relacionadas:\n";
            foreach ($tables as $table) {
                echo "  - catastro_gdl.$table\n";
            }
        }
    }

} catch (PDOException $e) {
    // Si falla la conexión directa, buscar en archivos SQL existentes
    echo "Buscando en archivos SQL existentes...\n";

    $baseDir = 'C:/recodeGDL/RefactorX/Base';
    $files = glob("$baseDir/*/database/generated/*.sql");

    foreach ($files as $file) {
        $content = file_get_contents($file);
        if (stripos($content, 'escrit') !== false || stripos($content, '400') !== false) {
            echo "Archivo: " . basename($file) . "\n";
            // Extraer nombre de tablas mencionadas
            preg_match_all('/FROM\s+(\w+\.\w+)/i', $content, $matches);
            if (!empty($matches[1])) {
                echo "  Tablas: " . implode(', ', array_unique($matches[1])) . "\n";
            }
        }
    }
}
