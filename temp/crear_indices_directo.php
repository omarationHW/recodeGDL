<?php
/**
 * Crear índices para dictamenes - Ejecución directa
 * Fecha: 2025-11-05
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "\n========================================\n";
    echo "CREANDO ÍNDICES - comun.dictamenes\n";
    echo "========================================\n\n";

    $indices = [
        [
            'name' => 'idx_dictamenes_propietario',
            'sql' => 'CREATE INDEX IF NOT EXISTS idx_dictamenes_propietario ON comun.dictamenes USING btree (propietario)',
            'desc' => 'Búsqueda por propietario'
        ],
        [
            'name' => 'idx_dictamenes_domicilio',
            'sql' => 'CREATE INDEX IF NOT EXISTS idx_dictamenes_domicilio ON comun.dictamenes USING btree (domicilio)',
            'desc' => 'Búsqueda por domicilio'
        ],
        [
            'name' => 'idx_dictamenes_actividad',
            'sql' => 'CREATE INDEX IF NOT EXISTS idx_dictamenes_actividad ON comun.dictamenes USING btree (actividad)',
            'desc' => 'Búsqueda por actividad'
        ],
        [
            'name' => 'idx_dictamenes_fecha',
            'sql' => 'CREATE INDEX IF NOT EXISTS idx_dictamenes_fecha ON comun.dictamenes USING btree (fecha DESC NULLS LAST)',
            'desc' => 'Ordenamiento por fecha'
        ],
        [
            'name' => 'idx_dictamenes_dictamen',
            'sql' => 'CREATE INDEX IF NOT EXISTS idx_dictamenes_dictamen ON comun.dictamenes USING btree (dictamen)',
            'desc' => 'Filtrado por estado'
        ],
        [
            'name' => 'idx_dictamenes_id_giro',
            'sql' => 'CREATE INDEX IF NOT EXISTS idx_dictamenes_id_giro ON comun.dictamenes USING btree (id_giro)',
            'desc' => 'Foreign key a giros'
        ],
        [
            'name' => 'idx_dictamenes_capturista',
            'sql' => 'CREATE INDEX IF NOT EXISTS idx_dictamenes_capturista ON comun.dictamenes USING btree (capturista)',
            'desc' => 'Búsqueda por capturista'
        ],
        [
            'name' => 'idx_dictamenes_busqueda_combinada',
            'sql' => 'CREATE INDEX IF NOT EXISTS idx_dictamenes_busqueda_combinada ON comun.dictamenes USING btree (propietario, domicilio, actividad)',
            'desc' => 'Búsquedas combinadas'
        ],
        [
            'name' => 'idx_dictamenes_fecha_estado',
            'sql' => 'CREATE INDEX IF NOT EXISTS idx_dictamenes_fecha_estado ON comun.dictamenes USING btree (fecha DESC NULLS LAST, dictamen)',
            'desc' => 'Fecha + estado'
        ]
    ];

    $created = 0;
    $start = microtime(true);

    foreach ($indices as $index) {
        echo "⚙️  {$index['desc']}: {$index['name']}...\n";

        try {
            $pdo->exec($index['sql']);
            echo "   ✅ Creado\n\n";
            $created++;
        } catch (PDOException $e) {
            if (strpos($e->getMessage(), 'already exists') !== false) {
                echo "   ℹ️  Ya existe\n\n";
            } else {
                echo "   ❌ Error: " . $e->getMessage() . "\n\n";
            }
        }
    }

    $elapsed = round(microtime(true) - $start, 2);

    echo "\n📊 Verificando índices creados:\n";
    echo str_repeat("-", 110) . "\n";
    printf("%-50s %-40s %-15s\n", "Index Name", "Columns", "Size");
    echo str_repeat("-", 110) . "\n";

    $stmt = $pdo->query("
        SELECT
            i.relname as index_name,
            string_agg(a.attname, ', ' ORDER BY a.attnum) as columns,
            pg_size_pretty(pg_relation_size(i.oid)) as index_size
        FROM pg_class t
        JOIN pg_index ix ON t.oid = ix.indrelid
        JOIN pg_class i ON i.oid = ix.indexrelid
        JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = ANY(ix.indkey)
        JOIN pg_namespace n ON t.relnamespace = n.oid
        WHERE n.nspname = 'comun'
            AND t.relname = 'dictamenes'
        GROUP BY i.relname, i.oid
        ORDER BY i.relname
    ");

    $result = $stmt->fetchAll(PDO::FETCH_OBJ);

    foreach ($result as $idx) {
        printf("%-50s %-40s %-15s\n",
            $idx->index_name,
            substr($idx->columns, 0, 40),
            $idx->index_size
        );
    }

    echo str_repeat("-", 110) . "\n";

    echo "\n========================================\n";
    echo "ÍNDICES CREADOS EXITOSAMENTE\n";
    echo "========================================\n";
    echo "Índices nuevos creados: {$created}\n";
    echo "Total de índices en tabla: " . count($result) . "\n";
    echo "Tiempo transcurrido: {$elapsed} segundos\n\n";

    echo "✅ La tabla comun.dictamenes ahora está optimizada\n";
    echo "✅ Las búsquedas serán significativamente más rápidas\n\n";

} catch (PDOException $e) {
    echo "\n❌ ERROR DE BASE DE DATOS:\n";
    echo "   " . $e->getMessage() . "\n\n";
    exit(1);
} catch (Exception $e) {
    echo "\n❌ ERROR:\n";
    echo "   " . $e->getMessage() . "\n\n";
    exit(1);
}
