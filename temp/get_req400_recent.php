<?php
/**
 * Script para obtener ejemplos con años recientes reales
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== BÚSQUEDA DE REQUERIMIENTOS CON AÑOS 2020+ ===\n\n";

    // Buscar años en formato 4 dígitos (2020-2025)
    echo "1. Buscando registros con años 2020-2025...\n";
    $recentYears = $pdo->query("
        SELECT DISTINCT TRIM(ejereq) as ejercicio, COUNT(*) as total
        FROM catastro_gdl.req_400
        WHERE ejereq IS NOT NULL
          AND LENGTH(TRIM(ejereq)) >= 4
          AND (
              TRIM(ejereq) LIKE '%2020%'
              OR TRIM(ejereq) LIKE '%2021%'
              OR TRIM(ejereq) LIKE '%2022%'
              OR TRIM(ejereq) LIKE '%2023%'
              OR TRIM(ejereq) LIKE '%2024%'
              OR TRIM(ejereq) LIKE '%2025%'
          )
        GROUP BY TRIM(ejereq)
        ORDER BY ejercicio DESC
    ")->fetchAll(PDO::FETCH_ASSOC);

    if (count($recentYears) > 0) {
        echo "Años encontrados:\n";
        foreach ($recentYears as $y) {
            echo "   - {$y['ejercicio']}: {$y['total']} registros\n";
        }
        echo "\n";

        // Obtener ejemplos
        echo "2. EJEMPLOS PARA PROBAR:\n";
        echo str_repeat("=", 80) . "\n\n";

        $count = 0;
        foreach ($recentYears as $yearData) {
            if ($count >= 3) break;

            $year = $yearData['ejercicio'];

            $example = $pdo->query("
                SELECT *
                FROM catastro_gdl.req_400
                WHERE TRIM(ejereq) = '$year'
                  AND ctarfc IS NOT NULL
                  AND TRIM(ctarfc) != ''
                LIMIT 1
            ")->fetch(PDO::FETCH_ASSOC);

            if ($example) {
                echo "EJEMPLO " . ($count + 1) . ":\n";
                echo "----------------------------------------\n";
                echo "Cuenta: " . trim($example['ctarfc']) . "\n";
                echo "Año: " . trim($example['ejereq']) . "\n";
                echo "Folio: " . trim($example['folreq']) . "\n";
                echo "\nDatos completos:\n";
                foreach ($example as $key => $value) {
                    if ($value && trim($value) != '') {
                        echo "  $key: " . trim($value) . "\n";
                    }
                }
                echo "\n\n";
                $count++;
            }
        }
    } else {
        echo "No se encontraron registros con años 2020-2025.\n";
        echo "Los años en la tabla parecen estar en formato antiguo AS-400.\n\n";

        echo "El formato AS-400 usa años de 2 o 3 dígitos:\n";
        echo "  - 214 = 2014\n";
        echo "  - 213 = 2013\n";
        echo "  - 212 = 2012\n";
        echo "  etc.\n\n";

        echo "USANDO LOS AÑOS MÁS RECIENTES DISPONIBLES:\n";
        echo str_repeat("=", 80) . "\n\n";

        // Obtener los 3 años más altos
        $topYears = $pdo->query("
            SELECT DISTINCT TRIM(ejereq) as ejercicio
            FROM catastro_gdl.req_400
            WHERE ejereq IS NOT NULL AND TRIM(ejereq) != ''
            ORDER BY ejercicio DESC
            LIMIT 3
        ")->fetchAll(PDO::FETCH_ASSOC);

        $count = 1;
        foreach ($topYears as $yearData) {
            $year = $yearData['ejercicio'];

            $example = $pdo->query("
                SELECT *
                FROM catastro_gdl.req_400
                WHERE TRIM(ejereq) = '$year'
                  AND ctarfc IS NOT NULL
                  AND TRIM(ctarfc) != ''
                LIMIT 1
            ")->fetch(PDO::FETCH_ASSOC);

            if ($example) {
                echo "EJEMPLO $count:\n";
                echo "----------------------------------------\n";
                echo "Cuenta: " . trim($example['ctarfc']) . "\n";
                echo "Año: " . trim($example['ejereq']) . " (interpretado como 20" . trim($example['ejereq']) . ")\n";
                echo "Folio: " . trim($example['folreq']) . "\n\n";
                $count++;
            }
        }
    }

    echo "\n" . str_repeat("=", 80) . "\n";
    echo "INSTRUCCIONES PARA PROBAR EN ConsReq400.vue:\n";
    echo str_repeat("=", 80) . "\n\n";

    $topYears = $pdo->query("
        SELECT DISTINCT TRIM(ejereq) as ejercicio
        FROM catastro_gdl.req_400
        WHERE ejereq IS NOT NULL AND TRIM(ejereq) != ''
        ORDER BY ejercicio DESC
        LIMIT 3
    ")->fetchAll(PDO::FETCH_ASSOC);

    $count = 1;
    foreach ($topYears as $yearData) {
        $year = $yearData['ejercicio'];

        $example = $pdo->query("
            SELECT TRIM(ctarfc) as cuenta, TRIM(ejereq) as ejercicio
            FROM catastro_gdl.req_400
            WHERE TRIM(ejereq) = '$year'
              AND ctarfc IS NOT NULL
              AND TRIM(ctarfc) != ''
            LIMIT 1
        ")->fetch(PDO::FETCH_ASSOC);

        if ($example) {
            // Convertir el año a formato interpretable
            $displayYear = trim($example['ejercicio']);
            if (strlen($displayYear) <= 3) {
                $displayYear = "20" . $displayYear;
            }

            echo "Ejemplo $count:\n";
            echo "  Campo 'Cuenta': " . $example['cuenta'] . "\n";
            echo "  Campo 'Año': " . $displayYear . " (o usa el valor original: " . trim($example['ejercicio']) . ")\n\n";
            $count++;
        }
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
