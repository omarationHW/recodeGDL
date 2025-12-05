<?php
// Explorar multas canceladas
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== EXPLORANDO comun.multas - COLUMNAS RELACIONADAS CON CUENTA Y CANCELACIÓN ===\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'comun'
        AND table_name = 'multas'
        AND (
            column_name LIKE '%cuenta%'
            OR column_name LIKE '%cancel%'
            OR column_name LIKE '%clave%'
            OR column_name LIKE '%folio%'
            OR column_name LIKE '%acta%'
        )
        ORDER BY ordinal_position
    ");

    echo "Columnas relevantes:\n";
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo sprintf("  %-30s %s\n", $row['column_name'], $row['data_type']);
    }

    echo "\n=== CONTEO DE MULTAS CANCELADAS ===\n";
    $stmt = $pdo->query("
        SELECT COUNT(*) as total
        FROM comun.multas
        WHERE fecha_cancelacion IS NOT NULL
    ");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "Multas con fecha_cancelacion: " . number_format($result['total']) . "\n";

    echo "\n=== PRIMEROS 5 REGISTROS CON CANCELACIÓN ===\n\n";
    $stmt = $pdo->query("
        SELECT folio, fecha_acta, fecha_cancelacion, multa, total, id_dependencia
        FROM comun.multas
        WHERE fecha_cancelacion IS NOT NULL
        ORDER BY fecha_cancelacion DESC
        LIMIT 5
    ");

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "Folio: {$row['folio']}\n";
        echo "  Fecha acta: {$row['fecha_acta']}\n";
        echo "  Fecha cancelación: {$row['fecha_cancelacion']}\n";
        echo "  Multa: \${$row['multa']}\n";
        echo "  Total: \${$row['total']}\n";
        echo "  Dependencia: {$row['id_dependencia']}\n";
        echo "\n";
    }

    // Buscar diferentes folios para usar como ejemplos
    echo "\n=== OBTENIENDO FOLIOS DE EJEMPLO (MULTAS CANCELADAS) ===\n\n";
    $stmt = $pdo->query("
        SELECT folio, fecha_acta, fecha_cancelacion, multa, total
        FROM comun.multas
        WHERE fecha_cancelacion IS NOT NULL
        AND folio IS NOT NULL
        ORDER BY fecha_cancelacion DESC
        LIMIT 10
    ");

    $ejemplos = [];
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $ejemplos[] = $row['folio'];
        echo sprintf("  Folio: %-15s | Cancelado: %s | Total: $%.2f\n",
            $row['folio'],
            $row['fecha_cancelacion'],
            $row['total']
        );
    }

    // Verificar detalles de 3 ejemplos específicos
    echo "\n=== DETALLES DE 3 EJEMPLOS PARA PRUEBAS ===\n\n";
    foreach (array_slice($ejemplos, 0, 3) as $idx => $folio) {
        echo "EJEMPLO " . ($idx + 1) . ": Folio '$folio'\n";

        $stmt = $pdo->prepare("
            SELECT *
            FROM comun.multas
            WHERE folio = ?
            AND fecha_cancelacion IS NOT NULL
        ");
        $stmt->execute([$folio]);
        $multa = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($multa) {
            foreach ($multa as $key => $value) {
                if ($value !== null && $value !== '') {
                    echo "  $key: $value\n";
                }
            }
        }
        echo "\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?>
