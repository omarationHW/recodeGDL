<?php
/**
 * Script de despliegue usando Laravel DB para RptMovimientos SPs
 * Evita problemas con extensiones PHP nativas de PostgreSQL
 */

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

use Illuminate\Database\Capsule\Manager as Capsule;

$capsule = new Capsule;

$capsule->addConnection([
    'driver' => 'pgsql',
    'host' => '192.168.6.146',
    'port' => '5432',
    'database' => 'mercados',
    'username' => 'refact',
    'password' => 'FF)-BQk2',
    'charset' => 'utf8',
    'prefix' => '',
    'schema' => 'public',
]);

$capsule->setAsGlobal();
$capsule->bootEloquent();

$db = Capsule::connection()->getPdo();

echo "=================================================================\n";
echo "DESPLIEGUE DE STORED PROCEDURES - RptMovimientos.vue\n";
echo "=================================================================\n\n";

$sps = [
    [
        'nombre' => 'sp_get_recaudadoras',
        'archivo' => __DIR__ . '/../RefactorX/Base/mercados/database/database/RptMovimientos_sp_get_recaudadoras.sql',
        'descripcion' => 'Obtiene catálogo de recaudadoras'
    ],
    [
        'nombre' => 'sp_get_movimientos_locales',
        'archivo' => __DIR__ . '/../RefactorX/Base/mercados/database/database/RptMovimientos_sp_get_movimientos_locales.sql',
        'descripcion' => 'Obtiene reporte de movimientos de locales por período y recaudadora'
    ]
];

$exitosos = 0;
$fallidos = 0;

foreach ($sps as $sp) {
    echo "-------------------------------------------------------------------\n";
    echo "SP: {$sp['nombre']}\n";
    echo "Descripción: {$sp['descripcion']}\n";
    echo "-------------------------------------------------------------------\n";

    if (!file_exists($sp['archivo'])) {
        echo "✗ ERROR: Archivo no encontrado: {$sp['archivo']}\n\n";
        $fallidos++;
        continue;
    }

    $sql = file_get_contents($sp['archivo']);

    // Eliminar función existente
    echo "1. Eliminando función existente...\n";
    try {
        Capsule::statement("DROP FUNCTION IF EXISTS {$sp['nombre']} CASCADE");
        echo "   ✓ Función eliminada\n";
    } catch (Exception $e) {
        echo "   ⚠ Advertencia al eliminar: " . $e->getMessage() . "\n";
    }

    // Crear nueva función
    echo "2. Creando nueva función...\n";
    try {
        Capsule::statement($sql);
        echo "   ✓ Función creada exitosamente\n";
        $exitosos++;
    } catch (Exception $e) {
        echo "   ✗ ERROR al crear: " . $e->getMessage() . "\n";
        $fallidos++;
        continue;
    }

    // Verificar creación
    echo "3. Verificando creación...\n";
    try {
        $result = Capsule::select("
            SELECT routine_name, routine_type
            FROM information_schema.routines
            WHERE routine_name = ?
              AND routine_schema = 'public'
        ", [$sp['nombre']]);

        if (!empty($result)) {
            echo "   ✓ Verificación exitosa: {$result[0]->routine_name} ({$result[0]->routine_type})\n";
        } else {
            echo "   ✗ No se pudo verificar la función\n";
        }
    } catch (Exception $e) {
        echo "   ⚠ Error en verificación: " . $e->getMessage() . "\n";
    }

    echo "\n";
}

echo "=================================================================\n";
echo "RESUMEN DE DESPLIEGUE\n";
echo "=================================================================\n";
echo "✓ Exitosos: {$exitosos}\n";
echo "✗ Fallidos: {$fallidos}\n";
echo "Total: " . count($sps) . "\n";
echo "=================================================================\n\n";

// Test rápido
if ($exitosos > 0) {
    echo "=================================================================\n";
    echo "PRUEBAS DE FUNCIONALIDAD\n";
    echo "=================================================================\n\n";

    // Test sp_get_recaudadoras
    echo "Test 1: sp_get_recaudadoras()\n";
    echo "-------------------------------------------------------------------\n";
    try {
        $results = Capsule::select("SELECT * FROM sp_get_recaudadoras() LIMIT 3");
        echo "Registros encontrados: " . count($results) . "\n";
        if (count($results) > 0) {
            echo "Ejemplo:\n";
            print_r($results[0]);
        }
    } catch (Exception $e) {
        echo "✗ ERROR: " . $e->getMessage() . "\n";
    }
    echo "\n";

    // Test sp_get_movimientos_locales
    echo "Test 2: sp_get_movimientos_locales('2024-01-01', '2024-12-31', 1)\n";
    echo "-------------------------------------------------------------------\n";
    try {
        $results = Capsule::select("SELECT * FROM sp_get_movimientos_locales('2024-01-01', '2024-12-31', 1) LIMIT 3");
        echo "Registros encontrados: " . count($results) . "\n";
        if (count($results) > 0) {
            echo "Ejemplo:\n";
            print_r($results[0]);
        } else {
            echo "⚠ No hay datos en el período de prueba, pero la función ejecutó correctamente\n";
        }
    } catch (Exception $e) {
        echo "✗ ERROR: " . $e->getMessage() . "\n";
    }
    echo "\n";
}

echo "=================================================================\n";
echo "DESPLIEGUE COMPLETADO\n";
echo "=================================================================\n";

exit($fallidos > 0 ? 1 : 0);
