<?php
// Test para verificar si el SP devuelve duplicados

try {
    $db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== TEST DE DUPLICADOS EN SP ===\n\n";

    // 1. Contar registros reales en la tabla
    $stmt = $db->query('SELECT COUNT(*) as total FROM comun.c_actividades');
    $total = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
    echo "📊 Total registros en tabla comun.c_actividades: $total\n\n";

    // 2. Ejecutar el SP y traer primeros 50
    $stmt = $db->query('SELECT * FROM comun.catalogo_actividades_list() LIMIT 50');
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "📡 SP devuelve (primeros 50): " . count($results) . " registros\n\n";

    // 3. Mostrar primeros 10 registros
    echo "🔍 Primeros 10 registros:\n";
    echo str_repeat("-", 80) . "\n";
    foreach (array_slice($results, 0, 10) as $i => $row) {
        $num = $i + 1;
        echo sprintf("%2d. %3d.%3d.%3d - %s\n",
            $num,
            $row['generico'],
            $row['uso'],
            $row['actividad'],
            substr($row['concepto'], 0, 50)
        );
    }
    echo str_repeat("-", 80) . "\n\n";

    // 4. Verificar duplicados en los primeros 50
    $keys = [];
    $duplicados = [];
    foreach ($results as $row) {
        $key = "{$row['generico']}-{$row['uso']}-{$row['actividad']}";
        if (in_array($key, $keys)) {
            $duplicados[] = [
                'key' => $key,
                'concepto' => $row['concepto']
            ];
        }
        $keys[] = $key;
    }

    if (count($duplicados) === 0) {
        echo "✅ NO hay duplicados en los primeros 50 registros del SP\n";
        echo "✅ El problema NO está en la base de datos\n";
        echo "✅ El problema está en el frontend (Vue)\n";
    } else {
        echo "❌ Se encontraron " . count($duplicados) . " duplicados:\n";
        foreach ($duplicados as $dup) {
            echo "   - {$dup['key']}: {$dup['concepto']}\n";
        }
        echo "\n❌ El problema ESTÁ en la base de datos\n";
    }

    // 5. Verificar si el SP tiene DISTINCT
    echo "\n📋 Revisando definición del SP...\n";
    $stmt = $db->query("
        SELECT pg_get_functiondef('comun.catalogo_actividades_list'::regprocedure)
    ");
    $definition = $stmt->fetch(PDO::FETCH_ASSOC);

    if (strpos($definition['pg_get_functiondef'], 'DISTINCT') !== false) {
        echo "✅ El SP usa DISTINCT\n";
    } else {
        echo "⚠️  El SP NO usa DISTINCT\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
