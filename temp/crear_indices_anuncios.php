<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "CREAR ÍNDICES PARA TABLA ANUNCIOS\n";
echo "========================================\n\n";

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$database", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa\n\n";

    $indices = [
        [
            'nombre' => 'idx_anuncios_vigente',
            'sql' => 'CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_anuncios_vigente ON comun.anuncios(vigente)'
        ],
        [
            'nombre' => 'idx_anuncios_zona',
            'sql' => 'CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_anuncios_zona ON comun.anuncios(zona)'
        ],
        [
            'nombre' => 'idx_anuncios_fecha_otorgamiento',
            'sql' => 'CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_anuncios_fecha_otorgamiento ON comun.anuncios(fecha_otorgamiento DESC)'
        ],
        [
            'nombre' => 'idx_anuncios_id_licencia',
            'sql' => 'CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_anuncios_id_licencia ON comun.anuncios(id_licencia)'
        ],
        [
            'nombre' => 'idx_anuncios_anuncio',
            'sql' => 'CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_anuncios_anuncio ON comun.anuncios(anuncio DESC)'
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
    echo "VERIFICANDO ÍNDICES CREADOS\n";
    echo "========================================\n\n";

    $stmt = $pdo->query("
        SELECT
            indexname,
            indexdef
        FROM pg_indexes
        WHERE schemaname = 'comun'
        AND tablename = 'anuncios'
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
