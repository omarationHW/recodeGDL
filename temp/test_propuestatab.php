<?php
// Probar SP recaudadora_propuestatab con diferentes filtros
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== PROBANDO SP recaudadora_propuestatab ===\n\n";

    // Prueba 1: Sin filtro (obtener primeros registros)
    echo "--- PRUEBA 1: Sin filtro (todos los registros) ---\n\n";

    $sql = "SELECT * FROM public.recaudadora_propuestatab('') LIMIT 5";
    $stmt = $pdo->query($sql);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (!empty($results)) {
        echo "Registros encontrados: " . count($results) . "\n\n";
        foreach ($results as $idx => $row) {
            echo "Registro " . ($idx + 1) . ":\n";
            foreach ($row as $key => $value) {
                echo "  $key: $value\n";
            }
            echo "\n";
        }

        // Guardar ejemplos para el usuario
        $ejemplos = [];
        if (isset($results[0])) {
            $ejemplos[] = [
                'descripcion' => 'Buscar por cuenta específica',
                'valor' => $results[0]['cvecuenta'],
                'tipo' => 'Número de cuenta'
            ];
        }
        if (isset($results[1]) && $results[1]['folio']) {
            $ejemplos[] = [
                'descripcion' => 'Buscar por folio',
                'valor' => $results[1]['folio'],
                'tipo' => 'Número de folio'
            ];
        }
        if (isset($results[2]) && $results[2]['cajero']) {
            $ejemplos[] = [
                'descripcion' => 'Buscar por cajero',
                'valor' => trim($results[2]['cajero']),
                'tipo' => 'Nombre de cajero'
            ];
        }
    } else {
        echo "No se encontraron registros\n\n";
    }

    // Prueba 2: Filtrar por cuenta
    if (!empty($ejemplos) && isset($ejemplos[0])) {
        echo "--- PRUEBA 2: Filtrar por cuenta ({$ejemplos[0]['valor']}) ---\n\n";

        $sql = "SELECT * FROM public.recaudadora_propuestatab('" . $ejemplos[0]['valor'] . "')";
        $stmt = $pdo->query($sql);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "Registros encontrados: " . count($results) . "\n\n";
        if (!empty($results)) {
            echo "Primer registro:\n";
            foreach ($results[0] as $key => $value) {
                echo "  $key: $value\n";
            }
            echo "\n";
        }
    }

    // Prueba 3: Filtrar por cajero
    if (!empty($ejemplos) && isset($ejemplos[2])) {
        echo "--- PRUEBA 3: Filtrar por cajero ({$ejemplos[2]['valor']}) ---\n\n";

        $sql = "SELECT * FROM public.recaudadora_propuestatab('" . $ejemplos[2]['valor'] . "')";
        $stmt = $pdo->query($sql);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "Registros encontrados: " . count($results) . "\n\n";
    }

    // Mostrar resumen de ejemplos para el usuario
    echo "\n=== EJEMPLOS PARA PROBAR EL FORMULARIO ===\n\n";
    foreach ($ejemplos as $idx => $ejemplo) {
        echo "EJEMPLO " . ($idx + 1) . ":\n";
        echo "  Tipo: {$ejemplo['tipo']}\n";
        echo "  Valor a buscar: {$ejemplo['valor']}\n";
        echo "  Descripción: {$ejemplo['descripcion']}\n";
        echo "\n";
    }

    // Obtener estadísticas
    echo "=== ESTADÍSTICAS ===\n\n";

    $sql = "
        SELECT
            COUNT(*) as total_pagos,
            SUM(importe) as total_importe,
            MIN(fecha) as fecha_min,
            MAX(fecha) as fecha_max
        FROM comun.pagos
        WHERE cvecanc IS NULL
    ";

    $stmt = $pdo->query($sql);
    $stats = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "Total de pagos activos: " . number_format($stats['total_pagos']) . "\n";
    echo "Total importes: $" . number_format($stats['total_importe'], 2) . "\n";
    echo "Fecha más antigua: {$stats['fecha_min']}\n";
    echo "Fecha más reciente: {$stats['fecha_max']}\n";

} catch (PDOException $e) {
    echo "Error de BD: " . $e->getMessage() . "\n";
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
