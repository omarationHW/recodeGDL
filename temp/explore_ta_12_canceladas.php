<?php
// Explorar tabla ta_12_canceladas
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== ESTRUCTURA DE db_ingresos.ta_12_canceladas ===\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'db_ingresos'
        AND table_name = 'ta_12_canceladas'
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
    $stmt = $pdo->query("SELECT COUNT(*) FROM db_ingresos.ta_12_canceladas");
    $count = $stmt->fetchColumn();
    echo "Total de registros: " . number_format($count) . "\n";

    echo "\n=== PRIMEROS 5 REGISTROS ===\n\n";
    $stmt = $pdo->query("
        SELECT *
        FROM db_ingresos.ta_12_canceladas
        LIMIT 5
    ");

    $first_records = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($first_records as $idx => $record) {
        echo "Registro " . ($idx + 1) . ":\n";
        foreach ($record as $key => $value) {
            echo "  $key: " . ($value ?? 'NULL') . "\n";
        }
        echo "\n";
    }

    // Buscar diferentes valores de cuenta para usar como ejemplos
    echo "\n=== BUSCANDO CUENTAS DISTINTAS PARA EJEMPLOS ===\n\n";
    $stmt = $pdo->query("
        SELECT DISTINCT clave_cuenta
        FROM db_ingresos.ta_12_canceladas
        WHERE clave_cuenta IS NOT NULL
        LIMIT 10
    ");

    $ejemplos = [];
    while ($row = $stmt->fetch(PDO::FETCH_COLUMN)) {
        $ejemplos[] = $row;
        echo "  - $row\n";
    }

    // Para cada ejemplo, mostrar cuántos registros tiene
    echo "\n=== CONTEO POR CUENTA (para validar ejemplos) ===\n\n";
    foreach (array_slice($ejemplos, 0, 3) as $cuenta) {
        $stmt = $pdo->prepare("
            SELECT COUNT(*)
            FROM db_ingresos.ta_12_canceladas
            WHERE clave_cuenta = ?
        ");
        $stmt->execute([$cuenta]);
        $count = $stmt->fetchColumn();
        echo "  Cuenta '$cuenta': $count registros\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?>
