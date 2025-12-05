<?php
// Crear índices para optimizar búsquedas en comun.pagos
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== CREANDO ÍNDICES EN comun.pagos ===\n\n";

    $indexes = [
        "CREATE INDEX IF NOT EXISTS idx_pagos_cvecuenta ON comun.pagos(cvecuenta)",
        "CREATE INDEX IF NOT EXISTS idx_pagos_folio ON comun.pagos(folio)",
        "CREATE INDEX IF NOT EXISTS idx_pagos_fecha ON comun.pagos(fecha DESC)",
        "CREATE INDEX IF NOT EXISTS idx_pagos_cajero ON comun.pagos(cajero)",
        "CREATE INDEX IF NOT EXISTS idx_pagos_cvepago ON comun.pagos(cvepago)"
    ];

    foreach ($indexes as $idx => $sql) {
        echo "Creando índice " . ($idx + 1) . "...\n";
        $start = microtime(true);

        try {
            $pdo->exec($sql);
            $end = microtime(true);
            $tiempo = round(($end - $start), 2);
            echo "✓ Índice creado en {$tiempo}s\n\n";
        } catch (PDOException $e) {
            echo "✗ Error: {$e->getMessage()}\n\n";
        }
    }

    echo "=== VERIFICANDO ÍNDICES CREADOS ===\n\n";

    $sql = "
        SELECT
            indexname,
            indexdef
        FROM pg_indexes
        WHERE tablename = 'pagos'
        AND schemaname = 'comun'
        AND indexname LIKE 'idx_pagos%'
        ORDER BY indexname
    ";

    $stmt = $pdo->query($sql);
    $indexes = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (!empty($indexes)) {
        foreach ($indexes as $index) {
            echo "✓ {$index['indexname']}\n";
        }
    } else {
        echo "No se encontraron índices\n";
    }

} catch (PDOException $e) {
    echo "Error de BD: " . $e->getMessage() . "\n";
}
