<?php
/**
 * Script para probar SP recaudadora_consulta_sdos_favor
 * y ver la estructura exacta de respuesta
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✅ Conectado a la base de datos: $dbname\n\n";

    // Parámetros de prueba del usuario
    $cuenta = '21432';
    $ejercicio = 2025;
    $folio = 5;

    echo "🧪 PROBANDO SP con parámetros del usuario:\n";
    echo "==========================================\n";
    echo "  - Cuenta: $cuenta\n";
    echo "  - Ejercicio: $ejercicio\n";
    echo "  - Folio: $folio\n\n";

    // Ejecutar SP
    $stmt = $pdo->prepare("
        SELECT * FROM recaudadora_consulta_sdos_favor(
            :cuenta,
            :ejercicio,
            :folio
        )
    ");

    $stmt->execute([
        'cuenta' => $cuenta,
        'ejercicio' => $ejercicio,
        'folio' => $folio
    ]);

    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "📊 RESULTADOS:\n";
    echo "==============\n";
    echo "Total de registros: " . count($results) . "\n\n";

    if (count($results) > 0) {
        foreach ($results as $i => $row) {
            echo "Registro " . ($i + 1) . ":\n";
            foreach ($row as $key => $value) {
                echo "  - $key: $value\n";
            }
            echo "\n";
        }

        // Mostrar en formato JSON (como lo ve el frontend)
        echo "\n📋 FORMATO JSON (como lo ve el frontend):\n";
        echo "=========================================\n";
        echo json_encode($results, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        echo "\n\n";

    } else {
        echo "❌ No se encontraron resultados\n\n";

        // Buscar si existen registros similares
        echo "🔍 Buscando registros con parámetros similares...\n";
        echo "==================================================\n";

        // Buscar por cuenta
        echo "\nBuscar solo por cuenta ($cuenta):\n";
        $stmt2 = $pdo->prepare("
            SELECT * FROM recaudadora_consulta_sdos_favor(:cuenta, NULL, NULL)
        ");
        $stmt2->execute(['cuenta' => $cuenta]);
        $results2 = $stmt2->fetchAll(PDO::FETCH_ASSOC);
        echo "  - Encontrados: " . count($results2) . " registros\n";

        if (count($results2) > 0) {
            echo "  Primer registro:\n";
            foreach ($results2[0] as $key => $value) {
                echo "    - $key: $value\n";
            }
        }

        // Buscar por folio
        echo "\nBuscar solo por folio ($folio):\n";
        $stmt3 = $pdo->prepare("
            SELECT * FROM recaudadora_consulta_sdos_favor(NULL, NULL, :folio)
        ");
        $stmt3->execute(['folio' => $folio]);
        $results3 = $stmt3->fetchAll(PDO::FETCH_ASSOC);
        echo "  - Encontrados: " . count($results3) . " registros\n";

        if (count($results3) > 0) {
            echo "  Primer registro:\n";
            foreach ($results3[0] as $key => $value) {
                echo "    - $key: $value\n";
            }
        }

        // Buscar cualquier registro (sin filtros)
        echo "\nBuscar sin filtros (primeros 5):\n";
        $stmt4 = $pdo->query("
            SELECT * FROM recaudadora_consulta_sdos_favor(NULL, NULL, NULL)
            LIMIT 5
        ");
        $results4 = $stmt4->fetchAll(PDO::FETCH_ASSOC);
        echo "  - Encontrados: " . count($results4) . " registros\n";

        if (count($results4) > 0) {
            echo "  Primer registro:\n";
            foreach ($results4[0] as $key => $value) {
                echo "    - $key: $value\n";
            }
        }
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "\n🔍 Stack trace:\n" . $e->getTraceAsString() . "\n";
    exit(1);
}
