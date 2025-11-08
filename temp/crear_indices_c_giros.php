<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "CREACIÓN DE ÍNDICES: comun.c_giros\n";
echo "========================================\n\n";

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$database", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa\n\n";

    $indices = [
        [
            'nombre' => 'idx_c_giros_tipo',
            'sql' => 'CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_c_giros_tipo ON comun.c_giros(tipo)',
            'descripcion' => 'Filtro por tipo (L/A)'
        ],
        [
            'nombre' => 'idx_c_giros_vigente',
            'sql' => 'CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_c_giros_vigente ON comun.c_giros(vigente)',
            'descripcion' => 'Filtro por vigencia (V/C)'
        ],
        [
            'nombre' => 'idx_c_giros_clasificacion',
            'sql' => 'CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_c_giros_clasificacion ON comun.c_giros(clasificacion)',
            'descripcion' => 'Filtro por clasificación (A/B/C/D)'
        ],
        [
            'nombre' => 'idx_c_giros_descripcion_gin',
            'sql' => 'CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_c_giros_descripcion_gin ON comun.c_giros USING gin(to_tsvector(\'spanish\', descripcion))',
            'descripcion' => 'Búsqueda full-text en descripción'
        ],
        [
            'nombre' => 'idx_c_giros_tipo_vigente',
            'sql' => 'CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_c_giros_tipo_vigente ON comun.c_giros(tipo, vigente)',
            'descripcion' => 'Combinación tipo + vigente (consulta más frecuente)'
        ]
    ];

    $created = 0;
    $skipped = 0;
    $failed = 0;

    foreach ($indices as $indice) {
        echo "Creando índice: {$indice['nombre']}\n";
        echo "Descripción: {$indice['descripcion']}\n";

        $start = microtime(true);

        try {
            $pdo->exec($indice['sql']);
            $duration = round((microtime(true) - $start), 2);
            echo "✅ Creado exitosamente en {$duration}s\n\n";
            $created++;
        } catch (PDOException $e) {
            if (strpos($e->getMessage(), 'already exists') !== false) {
                echo "⏭️ Ya existe, omitiendo...\n\n";
                $skipped++;
            } else {
                echo "❌ Error: " . $e->getMessage() . "\n\n";
                $failed++;
            }
        }
    }

    echo "========================================\n";
    echo "RESUMEN\n";
    echo "========================================\n\n";
    echo "Índices creados: $created\n";
    echo "Índices omitidos (ya existían): $skipped\n";
    echo "Índices fallidos: $failed\n\n";

    // Verificar índices creados
    echo "========================================\n";
    echo "VERIFICACIÓN DE ÍNDICES\n";
    echo "========================================\n\n";

    $stmt = $pdo->query("
        SELECT
            indexname,
            pg_size_pretty(pg_relation_size(indexname::text)) as size
        FROM pg_indexes
        WHERE schemaname = 'comun'
        AND tablename = 'c_giros'
        ORDER BY indexname
    ");

    $indices = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Total de índices en comun.c_giros: " . count($indices) . "\n\n";

    foreach ($indices as $idx) {
        echo "  • {$idx['indexname']} ({$idx['size']})\n";
    }
    echo "\n";

    echo "✅ Proceso completado\n";

} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
