<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== DESPLEGANDO STORED PROCEDURE REQ_PROMOCION (CORREGIDO) ===\n\n";

try {
    // Drop existing function
    echo "1. Eliminando función anterior...\n";
    DB::statement("DROP FUNCTION IF EXISTS recaudadora_req_promocion(VARCHAR, INTEGER) CASCADE");
    echo "   ✓ Función eliminada\n\n";

    // Create corrected function with proper type casting
    echo "2. Creando función corregida...\n";

    $sql = "
    CREATE OR REPLACE FUNCTION recaudadora_req_promocion(
        p_clave_cuenta VARCHAR DEFAULT NULL,
        p_ejercicio INTEGER DEFAULT NULL
    )
    RETURNS TABLE (
        cvedescuento INTEGER,
        descripcion TEXT,
        importe NUMERIC
    ) AS \$\$
    BEGIN
        RETURN QUERY
        SELECT
            r.cvedescuento::INTEGER,
            TRIM(r.descripcion)::TEXT,
            r.importe::NUMERIC
        FROM catastro_gdl.descuentos2008 r
        WHERE 1=1
           AND (p_clave_cuenta IS NULL OR CAST(r.cvedescuento AS TEXT) ILIKE '%' || p_clave_cuenta || '%')
        ORDER BY r.cvedescuento DESC
        LIMIT 100;
    END;
    \$\$ LANGUAGE plpgsql;
    ";

    DB::statement($sql);
    echo "   ✓ Stored procedure creado exitosamente\n\n";

    // Test the SP
    echo "3. Probando stored procedure...\n";

    $testResult = DB::select("SELECT * FROM recaudadora_req_promocion(NULL, NULL) LIMIT 5");
    echo "   ✓ SP funciona correctamente\n";
    echo "   Retornó " . count($testResult) . " registros\n\n";

    if (count($testResult) > 0) {
        echo "   Primeros 5 registros:\n";
        foreach ($testResult as $row) {
            echo "   - ID: {$row->cvedescuento}, Descripción: {$row->descripcion}, Importe: $" . number_format($row->importe, 2) . "\n";
        }
    }

    echo "\n4. Obteniendo ejemplos específicos para pruebas...\n\n";

    // Get all records to provide good examples
    $allRecords = DB::select("SELECT * FROM recaudadora_req_promocion(NULL, NULL)");
    echo "   Total de registros disponibles: " . count($allRecords) . "\n\n";

    // Example 1: Specific ID
    $example1 = DB::select("SELECT * FROM recaudadora_req_promocion('175', NULL)");
    echo "   EJEMPLO 1: Buscar por ID 175\n";
    echo "   Parámetros: cuenta = '175', ejercicio = NULL\n";
    echo "   Registros esperados: " . count($example1) . "\n";
    if (count($example1) > 0) {
        $r = $example1[0];
        echo "   Resultado: ID {$r->cvedescuento} - {$r->descripcion} - $" . number_format($r->importe, 2) . "\n";
    }
    echo "\n";

    // Example 2: Another specific ID
    $example2 = DB::select("SELECT * FROM recaudadora_req_promocion('98', NULL)");
    echo "   EJEMPLO 2: Buscar por ID 98\n";
    echo "   Parámetros: cuenta = '98', ejercicio = NULL\n";
    echo "   Registros esperados: " . count($example2) . "\n";
    if (count($example2) > 0) {
        $r = $example2[0];
        echo "   Resultado: ID {$r->cvedescuento} - {$r->descripcion} - $" . number_format($r->importe, 2) . "\n";
    }
    echo "\n";

    // Example 3: All records
    $example3 = DB::select("SELECT * FROM recaudadora_req_promocion(NULL, NULL)");
    echo "   EJEMPLO 3: Buscar todos (sin filtros)\n";
    echo "   Parámetros: cuenta = '', ejercicio = NULL\n";
    echo "   Registros esperados: " . count($example3) . " (total de registros)\n";
    echo "   Páginas esperadas: " . ceil(count($example3) / 10) . " páginas (10 registros por página)\n";
    echo "   Primeros 3 registros:\n";
    foreach (array_slice($example3, 0, 3) as $r) {
        echo "      - ID {$r->cvedescuento}: {$r->descripcion} - $" . number_format($r->importe, 2) . "\n";
    }

    echo "\n✅ DESPLIEGUE COMPLETADO EXITOSAMENTE\n";
    echo "\nTabla utilizada: catastro_gdl.descuentos2008\n";
    echo "Columnas: cvedescuento (INTEGER), descripcion (TEXT), importe (NUMERIC)\n";
    echo "Total de registros: " . count($allRecords) . "\n";

} catch (Exception $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
    echo $e->getTraceAsString() . "\n";
}
