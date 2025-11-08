<?php
/**
 * Script para ejecutar los stored procedures de Giros con Adeudo
 * en la base de datos PostgreSQL
 */

// Configuración de conexión
$host = '192.168.6.146';
$port = '5432';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "======================================\n";
echo "EJECUCIÓN DE SP: Giros con Adeudo\n";
echo "======================================\n\n";

try {
    // Conectar a PostgreSQL
    $dsn = "pgsql:host=$host;port=$port;dbname=$database";
    $pdo = new PDO($dsn, $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    echo "✓ Conexión exitosa a PostgreSQL\n";
    echo "  Base de datos: $database\n\n";

    // Leer el archivo SQL
    $sqlFile = 'C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\Base\padron_licencias\database\sp_giros_con_adeudo.sql';

    if (!file_exists($sqlFile)) {
        throw new Exception("No se encontró el archivo SQL: $sqlFile");
    }

    $sql = file_get_contents($sqlFile);
    echo "✓ Archivo SQL leído correctamente\n";
    echo "  Tamaño: " . strlen($sql) . " bytes\n\n";

    // Ejecutar el SQL
    echo "Ejecutando stored procedures...\n";
    $pdo->exec($sql);

    echo "✓ Stored procedures creados exitosamente\n\n";

    // Verificar que se crearon los SP
    echo "Verificando stored procedures creados:\n";

    $stmt = $pdo->query("
        SELECT
            routine_name,
            routine_type
        FROM information_schema.routines
        WHERE routine_schema = 'public'
          AND routine_name LIKE '%giros%adeudo%'
        ORDER BY routine_name
    ");

    $procedures = $stmt->fetchAll();

    if (count($procedures) > 0) {
        foreach ($procedures as $proc) {
            echo "  ✓ {$proc['routine_name']} ({$proc['routine_type']})\n";
        }
        echo "\n";
    } else {
        echo "  ⚠ No se encontraron los stored procedures\n\n";
    }

    // PRUEBA 1: sp_giros_dcon_adeudo con primeros 5 registros
    echo "======================================\n";
    echo "PRUEBA 1: sp_giros_dcon_adeudo\n";
    echo "======================================\n\n";

    $stmt = $pdo->query("
        SELECT * FROM public.sp_giros_dcon_adeudo(
            NULL,    -- p_year
            NULL,    -- p_giro
            NULL,    -- p_min_debt
            1,       -- p_page
            5        -- p_limit
        )
    ");

    $results = $stmt->fetchAll();

    if (count($results) > 0) {
        echo "✓ Función ejecutada correctamente\n";
        echo "  Total de registros: " . number_format($results[0]['total_records']) . "\n\n";

        foreach ($results as $idx => $row) {
            echo ($idx+1) . ". " . substr($row['giro'], 0, 60) . "...\n";
            echo "   Total Licencias: " . number_format($row['total_licencias']) . "\n";
            echo "   Con Adeudo: " . number_format($row['licencias_con_adeudo']) . "\n";
            echo "   Porcentaje: " . number_format($row['porcentaje_adeudo'], 2) . "%\n";
            echo "   Monto Total: $" . number_format($row['monto_total_adeudo'], 2) . "\n";
            echo "   Promedio: $" . number_format($row['promedio_adeudo'], 2) . "\n\n";
        }
    } else {
        echo "⚠ No se encontraron resultados\n\n";
    }

    // PRUEBA 2: sp_report_giros_dcon_adeudo (primeros 3)
    echo "======================================\n";
    echo "PRUEBA 2: sp_report_giros_dcon_adeudo\n";
    echo "======================================\n\n";

    $stmt = $pdo->query("
        SELECT * FROM public.sp_report_giros_dcon_adeudo(
            NULL,    -- p_year
            NULL,    -- p_giro
            NULL     -- p_min_debt
        )
        LIMIT 3
    ");

    $results = $stmt->fetchAll();

    if (count($results) > 0) {
        echo "✓ Función de reporte ejecutada correctamente\n\n";

        foreach ($results as $idx => $row) {
            echo ($idx+1) . ". " . substr($row['giro'], 0, 60) . "...\n";
            echo "   Con Adeudo: " . number_format($row['licencias_con_adeudo']) . "\n";
            echo "   Monto: $" . number_format($row['monto_total_adeudo'], 2) . "\n\n";
        }
    } else {
        echo "⚠ No se encontraron resultados\n\n";
    }

    // PRUEBA 3: Filtro por búsqueda de giro
    echo "======================================\n";
    echo "PRUEBA 3: Filtros (búsqueda 'COMERCIO')\n";
    echo "======================================\n\n";

    $stmt = $pdo->query("
        SELECT * FROM public.sp_giros_dcon_adeudo(
            NULL,          -- p_year
            'COMERCIO',    -- p_giro
            NULL,          -- p_min_debt
            1,             -- p_page
            3              -- p_limit
        )
    ");

    $results = $stmt->fetchAll();

    if (count($results) > 0) {
        echo "✓ Filtros funcionando correctamente\n";
        echo "  Resultados filtrados: " . number_format($results[0]['total_records']) . "\n\n";

        foreach ($results as $idx => $row) {
            echo ($idx+1) . ". " . substr($row['giro'], 0, 60) . "...\n";
            echo "   Monto: $" . number_format($row['monto_total_adeudo'], 2) . "\n\n";
        }
    }

    echo "======================================\n";
    echo "✅ TODAS LAS PRUEBAS COMPLETADAS\n";
    echo "======================================\n";

} catch (PDOException $e) {
    echo "\n✗ Error de base de datos:\n";
    echo "  " . $e->getMessage() . "\n";
    exit(1);
} catch (Exception $e) {
    echo "\n✗ Error:\n";
    echo "  " . $e->getMessage() . "\n";
    exit(1);
}
