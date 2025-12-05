<?php
// Explorar tabla ta_12_cuentas
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== ESTRUCTURA DE db_ingresos.ta_12_cuentas ===\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'db_ingresos'
        AND table_name = 'ta_12_cuentas'
        ORDER BY ordinal_position
    ");

    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($columns as $col) {
        echo sprintf("  %-30s %-20s %s\n",
            $col['column_name'],
            $col['data_type'],
            $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : ""
        );
    }

    echo "\n=== CONTEO DE REGISTROS ===\n";
    $stmt = $pdo->query("SELECT COUNT(*) FROM db_ingresos.ta_12_cuentas");
    $count = $stmt->fetchColumn();
    echo "Total de registros: " . number_format($count) . "\n";

    echo "\n=== PRIMEROS 3 REGISTROS COMPLETOS ===\n\n";
    $stmt = $pdo->query("
        SELECT *
        FROM db_ingresos.ta_12_cuentas
        LIMIT 3
    ");

    $first_records = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($first_records as $idx => $record) {
        echo "Registro " . ($idx + 1) . ":\n";
        foreach ($record as $key => $value) {
            if ($value !== null && $value !== '') {
                echo "  $key: $value\n";
            }
        }
        echo "\n";
    }

    // Buscar cuentas que tengan algún indicador de cancelación
    echo "\n=== BUSCANDO CUENTAS CON ESTADO CANCELADO ===\n\n";

    // Probar diferentes columnas que puedan indicar cancelación
    $possible_cancel_columns = ['cancelado', 'estado', 'estatus', 'activo', 'vigente', 'can'];

    foreach ($columns as $col) {
        foreach ($possible_cancel_columns as $search) {
            if (stripos($col['column_name'], $search) !== false) {
                echo "Columna encontrada: {$col['column_name']}\n";

                // Ver valores distintos de esa columna
                $stmt = $pdo->query("
                    SELECT DISTINCT {$col['column_name']}, COUNT(*) as count
                    FROM db_ingresos.ta_12_cuentas
                    WHERE {$col['column_name']} IS NOT NULL
                    GROUP BY {$col['column_name']}
                    LIMIT 10
                ");

                while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                    echo "  " . $row[$col['column_name']] . " -> " . $row['count'] . " registros\n";
                }
                echo "\n";
            }
        }
    }

    // Buscar diferentes valores de clave para usar como ejemplos
    echo "\n=== OBTENIENDO CLAVES DE EJEMPLO ===\n\n";
    $stmt = $pdo->query("
        SELECT clave, nombre_contribuyente, ramo
        FROM db_ingresos.ta_12_cuentas
        WHERE clave IS NOT NULL
        LIMIT 10
    ");

    $ejemplos = [];
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $ejemplos[] = $row['clave'];
        echo sprintf("  Clave: %-15s | Contrib: %-30s | Ramo: %s\n",
            $row['clave'],
            substr($row['nombre_contribuyente'] ?? 'N/A', 0, 30),
            $row['ramo'] ?? 'N/A'
        );
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?>
