<?php
// Obtener datos de ejemplo de las tablas relacionadas
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== ESTRUCTURA DE TABLA cuentas ===\n\n";

    // Verificar estructura de cuentas
    $sql = "
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'comun' AND table_name = 'cuentas'
        ORDER BY ordinal_position
        LIMIT 20
    ";

    $stmt = $pdo->query($sql);
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($columns as $col) {
        $type = $col['data_type'];
        if ($col['character_maximum_length']) {
            $type .= "({$col['character_maximum_length']})";
        }
        echo "{$col['column_name']}: {$type}\n";
    }

    echo "\n=== EJEMPLO DE DATOS EN cuentas ===\n\n";

    // Obtener 3 registros de ejemplo
    $sql = "SELECT * FROM comun.cuentas LIMIT 3";
    $stmt = $pdo->query($sql);
    $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($samples as $idx => $sample) {
        echo "Registro " . ($idx + 1) . ":\n";
        foreach ($sample as $key => $value) {
            echo "  $key: $value\n";
        }
        echo "\n";
    }

    echo "=== ESTRUCTURA DE TABLA pagos ===\n\n";

    // Verificar estructura de pagos
    $sql = "
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'comun' AND table_name = 'pagos'
        ORDER BY ordinal_position
        LIMIT 20
    ";

    $stmt = $pdo->query($sql);
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($columns as $col) {
        $type = $col['data_type'];
        if ($col['character_maximum_length']) {
            $type .= "({$col['character_maximum_length']})";
        }
        echo "{$col['column_name']}: {$type}\n";
    }

    echo "\n=== EJEMPLO DE DATOS EN pagos ===\n\n";

    $sql = "SELECT * FROM comun.pagos LIMIT 3";
    $stmt = $pdo->query($sql);
    $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($samples as $idx => $sample) {
        echo "Registro " . ($idx + 1) . ":\n";
        foreach ($sample as $key => $value) {
            echo "  $key: $value\n";
        }
        echo "\n";
    }

    // Verificar si existe tabla k_pagos (que apareció en la búsqueda anterior)
    echo "=== ESTRUCTURA DE TABLA k_pagos ===\n\n";

    $sql = "
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'comun' AND table_name = 'k_pagos'
        ORDER BY ordinal_position
    ";

    $stmt = $pdo->query($sql);
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($columns as $col) {
        $type = $col['data_type'];
        if ($col['character_maximum_length']) {
            $type .= "({$col['character_maximum_length']})";
        }
        echo "{$col['column_name']}: {$type}\n";
    }

    echo "\n=== CONTEO DE REGISTROS ===\n\n";

    $sql = "SELECT COUNT(*) as total FROM comun.k_pagos";
    $stmt = $pdo->query($sql);
    $count = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "k_pagos: {$count['total']} registros\n";

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
