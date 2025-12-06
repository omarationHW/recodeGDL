<?php
/**
 * Script para probar los SPs de Giros
 */

$host = "192.168.6.146";
$port = "5432";
$dbname = "mercados";
$user = "refact";
$password = "FF)-BQk2";

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    echo "\n=== PROBANDO SPs DE GIROS ===\n\n";

    // 1. Probar sp_giros_list
    echo "1. Probando sp_giros_list()...\n";
    echo str_repeat("-", 80) . "\n";

    $stmt = $pdo->query("SELECT * FROM sp_giros_list()");
    $giros = $stmt->fetchAll();

    if (count($giros) > 0) {
        echo "✅ SP funciona. Retornó " . count($giros) . " giros:\n\n";
        echo sprintf("%-10s %-40s %15s\n", "ID Giro", "Descripción", "Cant. Locales");
        echo str_repeat("-", 80) . "\n";

        foreach ($giros as $g) {
            echo sprintf(
                "%-10s %-40s %15s\n",
                $g['id_giro'],
                $g['descripcion'],
                number_format($g['cantidad_locales'])
            );
        }

        // Estadísticas
        $totalLocales = array_sum(array_column($giros, 'cantidad_locales'));
        $promedio = count($giros) > 0 ? round($totalLocales / count($giros)) : 0;

        echo "\n";
        echo "ESTADÍSTICAS:\n";
        echo "  - Total Giros: " . count($giros) . "\n";
        echo "  - Total Locales: " . number_format($totalLocales) . "\n";
        echo "  - Promedio: " . number_format($promedio) . " locales/giro\n";

        // Guardar primer giro para pruebas
        $primerGiro = $giros[0]['id_giro'];

        echo "\n";
    } else {
        echo "⚠️  No se encontraron giros\n";
        exit(1);
    }

    // 2. Probar sp_giros_get
    if (isset($primerGiro)) {
        echo "\n2. Probando sp_giros_get({$primerGiro})...\n";
        echo str_repeat("-", 80) . "\n";

        $stmt = $pdo->prepare("SELECT * FROM sp_giros_get(?)");
        $stmt->execute([$primerGiro]);
        $giro = $stmt->fetch();

        if ($giro) {
            echo "✅ SP funciona. Retornó:\n";
            echo "  - ID: {$giro['id_giro']}\n";
            echo "  - Descripción: {$giro['descripcion']}\n";
            echo "  - Cantidad Locales: " . number_format($giro['cantidad_locales']) . "\n";
            echo "\n";
        } else {
            echo "⚠️  No se encontró el giro\n\n";
        }
    }

    // 3. Probar sp_giros_locales
    if (isset($primerGiro)) {
        echo "\n3. Probando sp_giros_locales({$primerGiro})...\n";
        echo str_repeat("-", 80) . "\n";

        $stmt = $pdo->prepare("SELECT * FROM sp_giros_locales(?) LIMIT 10");
        $stmt->execute([$primerGiro]);
        $locales = $stmt->fetchAll();

        if (count($locales) > 0) {
            echo "✅ SP funciona. Retornó " . count($locales) . " locales:\n\n";
            echo sprintf("%-10s %-8s %-10s %-8s %-10s %-30s\n",
                "ID Local", "Oficina", "Mercado", "Cat.", "Local", "Nombre");
            echo str_repeat("-", 80) . "\n";

            foreach ($locales as $loc) {
                echo sprintf(
                    "%-10s %-8s %-10s %-8s %-10s %-30s\n",
                    $loc['id_local'],
                    $loc['oficina'],
                    $loc['num_mercado'],
                    $loc['categoria'],
                    $loc['local'],
                    substr($loc['nombre'] ?? 'N/A', 0, 30)
                );
            }
            echo "\n";
        } else {
            echo "⚠️  No se encontraron locales para este giro\n\n";
        }
    }

    echo str_repeat("=", 80) . "\n";
    echo "✅ PRUEBAS COMPLETADAS\n\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
