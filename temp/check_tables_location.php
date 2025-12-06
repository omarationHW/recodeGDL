<?php
/**
 * Verificar dónde están las tablas usadas en rpt_adeudos_anteriores
 */

echo "═══════════════════════════════════════════════════════════════\n";
echo " VERIFICACIÓN DE UBICACIÓN DE TABLAS\n";
echo "═══════════════════════════════════════════════════════════════\n\n";

$tablas = [
    'ta_11_adeudo_local',
    'ta_11_locales',
    'ta_12_recaudadoras',
    'ta_11_mercados'
];

$databases = [
    'mercados' => [
        'host' => '192.168.6.146',
        'port' => '5432',
        'user' => 'refact',
        'pass' => 'FF)-BQk2'
    ],
    'padron_licencias' => [
        'host' => '192.168.6.146',
        'port' => '5432',
        'user' => 'refact',
        'pass' => 'FF)-BQk2'
    ]
];

foreach ($databases as $dbname => $config) {
    echo "───────────────────────────────────────────────────────────────\n";
    echo "BASE DE DATOS: $dbname\n";
    echo "───────────────────────────────────────────────────────────────\n";

    try {
        $pdo = new PDO(
            "pgsql:host={$config['host']};port={$config['port']};dbname={$dbname}",
            $config['user'],
            $config['pass']
        );
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

        echo "✓ Conexión exitosa\n\n";

        foreach ($tablas as $tabla) {
            // Buscar la tabla en todos los schemas
            $stmt = $pdo->query("
                SELECT
                    schemaname,
                    tablename,
                    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
                FROM pg_tables
                WHERE tablename = '$tabla'
                ORDER BY schemaname
            ");

            $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

            if (count($results) > 0) {
                echo "📋 Tabla: $tabla\n";
                foreach ($results as $row) {
                    echo "   ✅ {$row['schemaname']}.{$row['tablename']} (Tamaño: {$row['size']})\n";
                }
                echo "\n";
            } else {
                echo "❌ Tabla: $tabla - NO ENCONTRADA\n\n";
            }
        }

    } catch (PDOException $e) {
        echo "❌ Error de conexión a $dbname: " . $e->getMessage() . "\n\n";
    }
}

echo "═══════════════════════════════════════════════════════════════\n";
echo " CONCLUSIÓN\n";
echo "═══════════════════════════════════════════════════════════════\n";
echo "Las tablas están en los schemas mostrados arriba.\n";
echo "Usa el formato: schema.tabla (ejemplo: comun.ta_11_locales)\n";
echo "NO uses: database.schema.tabla\n";
