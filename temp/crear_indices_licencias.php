<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "CREAR ÍNDICES PARA OPTIMIZAR LICENCIAS\n";
echo "========================================\n\n";

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$database", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa\n\n";

    $indices = [
        [
            'nombre' => 'idx_licencias_vigente',
            'sql' => 'CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_licencias_vigente ON comun.licencias(vigente)'
        ],
        [
            'nombre' => 'idx_licencias_zona',
            'sql' => 'CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_licencias_zona ON comun.licencias(zona)'
        ],
        [
            'nombre' => 'idx_licencias_propietario',
            'sql' => 'CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_licencias_propietario ON comun.licencias(propietario)'
        ],
        [
            'nombre' => 'idx_licencias_licencia',
            'sql' => 'CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_licencias_licencia ON comun.licencias(licencia DESC)'
        ]
    ];

    echo "Creando índices (CONCURRENTLY - sin bloquear la tabla)...\n\n";

    foreach ($indices as $idx) {
        echo "Creando {$idx['nombre']}...\n";

        try {
            $start = microtime(true);
            $pdo->exec($idx['sql']);
            $duration = round((microtime(true) - $start), 2);

            echo "  ✓ Creado exitosamente ({$duration}s)\n\n";
        } catch (Exception $e) {
            if (strpos($e->getMessage(), 'already exists') !== false) {
                echo "  ℹ Ya existe\n\n";
            } else {
                echo "  ⚠ Error: " . $e->getMessage() . "\n\n";
            }
        }
    }

    // Verificar índices creados
    echo "========================================\n";
    echo "VERIFICANDO ÍNDICES\n";
    echo "========================================\n\n";

    $stmt = $pdo->query("
        SELECT
            indexname,
            indexdef
        FROM pg_indexes
        WHERE schemaname = 'comun'
        AND tablename = 'licencias'
        ORDER BY indexname
    ");

    $indices_existentes = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Total de índices: " . count($indices_existentes) . "\n\n";

    foreach ($indices_existentes as $idx) {
        echo "✓ " . $idx['indexname'] . "\n";
    }

    echo "\n✅ Proceso completado\n";

} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
