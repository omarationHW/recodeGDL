<?php
// Explorar tablas relacionadas con escrituras y requerimientos

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'postgres';
$password = 'sistemas';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== Explorando tabla reqdiftransmision ===\n\n";

    // Ver estructura
    $stmt = $pdo->query("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl' AND table_name = 'reqdiftransmision'
        ORDER BY ordinal_position
    ");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Columnas:\n";
    foreach ($columns as $col) {
        $type = $col['data_type'];
        if ($col['character_maximum_length']) {
            $type .= "({$col['character_maximum_length']})";
        }
        echo "  - {$col['column_name']}: $type\n";
    }

    // Ver muestra de datos
    echo "\n=== Muestra de datos (primeros 3 registros) ===\n";
    $stmt = $pdo->query("SELECT * FROM catastro_gdl.reqdiftransmision LIMIT 3");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($rows as $i => $row) {
        echo "\nRegistro " . ($i + 1) . ":\n";
        echo json_encode($row, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";
    }

    // Buscar otras tablas relacionadas con requisiciones o escrituras
    echo "\n=== Buscando tablas relacionadas ===\n";

    $patterns = ['%req%', '%escrit%', '%trans%', '%dif%'];

    foreach ($patterns as $pattern) {
        $stmt = $pdo->prepare("
            SELECT table_schema, table_name
            FROM information_schema.tables
            WHERE table_name ILIKE :pattern
            AND table_schema IN ('catastro_gdl', 'comun', 'db_ingresos')
            ORDER BY table_name
            LIMIT 10
        ");
        $stmt->execute(['pattern' => $pattern]);
        $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (!empty($tables)) {
            echo "\nTablas que coinciden con '$pattern':\n";
            foreach ($tables as $table) {
                echo "  - {$table['table_schema']}.{$table['table_name']}\n";
            }
        }
    }

    // Intentar encontrar cuentas específicas para ejemplos
    echo "\n=== Cuentas con requerimientos (para ejemplos) ===\n";
    $stmt = $pdo->query("
        SELECT cvecuenta, COUNT(*) as total
        FROM catastro_gdl.reqdiftransmision
        GROUP BY cvecuenta
        ORDER BY total DESC
        LIMIT 5
    ");
    $accounts = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($accounts as $account) {
        echo "  Cuenta {$account['cvecuenta']}: {$account['total']} requerimientos\n";
    }

} catch (PDOException $e) {
    echo "Error de conexión. Intentando alternativa...\n";
    echo $e->getMessage() . "\n";
}
