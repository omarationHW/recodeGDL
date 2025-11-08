<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "CREAR ÍNDICES PARA LICENCIAS VIGENTES\n";
echo "========================================\n\n";

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$database", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa\n\n";

    // Verificar índices existentes
    echo "Verificando índices existentes en comun.licencias...\n";
    $stmt = $pdo->query("
        SELECT indexname, indexdef
        FROM pg_indexes
        WHERE schemaname = 'comun'
        AND tablename = 'licencias'
        ORDER BY indexname
    ");

    $indices = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Índices encontrados: " . count($indices) . "\n\n";

    foreach ($indices as $idx) {
        echo "  - " . $idx['indexname'] . "\n";
    }

    echo "\n" . str_repeat("-", 60) . "\n\n";

    // Crear índices necesarios si no existen
    $indices_crear = [
        [
            'nombre' => 'idx_licencias_vigente',
            'sql' => 'CREATE INDEX IF NOT EXISTS idx_licencias_vigente ON comun.licencias(vigente)'
        ],
        [
            'nombre' => 'idx_licencias_id_giro',
            'sql' => 'CREATE INDEX IF NOT EXISTS idx_licencias_id_giro ON comun.licencias(id_giro)'
        ],
        [
            'nombre' => 'idx_licencias_zona',
            'sql' => 'CREATE INDEX IF NOT EXISTS idx_licencias_zona ON comun.licencias(zona)'
        ],
        [
            'nombre' => 'idx_licencias_fecha_otorgamiento',
            'sql' => 'CREATE INDEX IF NOT EXISTS idx_licencias_fecha_otorgamiento ON comun.licencias(fecha_otorgamiento)'
        ],
        [
            'nombre' => 'idx_licencias_propietario',
            'sql' => 'CREATE INDEX IF NOT EXISTS idx_licencias_propietario ON comun.licencias(propietario)'
        ]
    ];

    echo "Creando índices necesarios...\n\n";

    foreach ($indices_crear as $idx) {
        echo "  Creando " . $idx['nombre'] . "... ";
        try {
            $start = microtime(true);
            $pdo->exec($idx['sql']);
            $duration = round((microtime(true) - $start) * 1000, 2);
            echo "✓ ({$duration}ms)\n";
        } catch (Exception $e) {
            echo "⚠ Ya existe o error: " . $e->getMessage() . "\n";
        }
    }

    echo "\n✅ Proceso completado\n";

} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
