<?php
/**
 * Script de despliegue de SPs para RptPadronEnergia
 * Fecha: 2025-12-04
 * Base: mercados
 * Total SPs: 3
 */

$host = 'localhost';
$port = '5432';
$dbname = 'mercados';
$user = 'postgres';
$password = 'postgres';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "Conectado a la base de datos mercados\n\n";

    $sqlFiles = [
        'RptPadronEnergia_sp_get_recaudadoras.sql',
        'RptPadronEnergia_sp_get_mercados_by_recaudadora.sql',
        'RptPadronEnergia_rpt_padron_energia_FINAL.sql'
    ];

    $basePath = __DIR__ . '/../RefactorX/Base/mercados/database/database/';

    foreach ($sqlFiles as $file) {
        $filePath = $basePath . $file;
        if (!file_exists($filePath)) {
            echo "ERROR: No se encuentra el archivo $file\n";
            continue;
        }

        echo "Desplegando: $file\n";
        $sql = file_get_contents($filePath);

        try {
            $pdo->exec($sql);
            echo "  ✓ Desplegado exitosamente\n";
        } catch (PDOException $e) {
            echo "  ✗ Error: " . $e->getMessage() . "\n";
        }
        echo "\n";
    }

    echo "\n=== VERIFICACIÓN DE SPs ===\n\n";

    // Verificar que los SPs existen
    $checkSPs = [
        'sp_get_recaudadoras' => 0,
        'sp_get_mercados_by_recaudadora' => 1,
        'rpt_padron_energia' => 2
    ];

    foreach ($checkSPs as $spName => $paramCount) {
        $stmt = $pdo->query("
            SELECT routine_name, routine_schema
            FROM information_schema.routines
            WHERE routine_name = '$spName'
              AND routine_type = 'FUNCTION'
        ");
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($result) {
            echo "✓ SP encontrado: {$result['routine_schema']}.{$result['routine_name']}\n";
        } else {
            echo "✗ SP no encontrado: $spName\n";
        }
    }

    echo "\n=== PRUEBAS FUNCIONALES ===\n\n";

    // Probar sp_get_recaudadoras
    echo "1. Probando sp_get_recaudadoras()...\n";
    try {
        $stmt = $pdo->query("SELECT * FROM sp_get_recaudadoras() LIMIT 5");
        $recaudadoras = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "   ✓ Retornó " . count($recaudadoras) . " recaudadoras\n";
        if (count($recaudadoras) > 0) {
            echo "   Ejemplo: {$recaudadoras[0]['id_rec']} - {$recaudadoras[0]['recaudadora']}\n";
        }
    } catch (PDOException $e) {
        echo "   ✗ Error: " . $e->getMessage() . "\n";
    }

    echo "\n2. Probando sp_get_mercados_by_recaudadora(1)...\n";
    try {
        $stmt = $pdo->query("SELECT * FROM sp_get_mercados_by_recaudadora(1) LIMIT 5");
        $mercados = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "   ✓ Retornó " . count($mercados) . " mercados\n";
        if (count($mercados) > 0) {
            echo "   Ejemplo: {$mercados[0]['num_mercado_nvo']} - {$mercados[0]['descripcion']}\n";
        }
    } catch (PDOException $e) {
        echo "   ✗ Error: " . $e->getMessage() . "\n";
    }

    echo "\n3. Probando rpt_padron_energia(1, mercado)...\n";
    try {
        // Obtener el primer mercado con energía
        $stmt = $pdo->query("SELECT * FROM sp_get_mercados_by_recaudadora(1) LIMIT 1");
        $mercado = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($mercado) {
            $numMercado = $mercado['num_mercado_nvo'];
            $stmt = $pdo->prepare("SELECT * FROM rpt_padron_energia(1, :mercado) LIMIT 5");
            $stmt->execute(['mercado' => $numMercado]);
            $padron = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo "   ✓ Retornó " . count($padron) . " registros para mercado $numMercado\n";
            if (count($padron) > 0) {
                echo "   Ejemplo: Local {$padron[0]['id_local']} - {$padron[0]['nombre']} - KW: {$padron[0]['cantidad']}\n";
            }
        } else {
            echo "   ⚠ No hay mercados con energía para probar\n";
        }
    } catch (PDOException $e) {
        echo "   ✗ Error: " . $e->getMessage() . "\n";
    }

    echo "\n=== DESPLIEGUE COMPLETADO ===\n";

} catch (PDOException $e) {
    echo "Error de conexión: " . $e->getMessage() . "\n";
    exit(1);
}
