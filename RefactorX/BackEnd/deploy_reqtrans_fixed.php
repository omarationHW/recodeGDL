<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== CORRIGIENDO STORED PROCEDURE REQTRANS_LIST ===\n\n";

try {
    echo "1. Eliminando función anterior...\n";
    DB::statement("DROP FUNCTION IF EXISTS recaudadora_reqtrans_list(VARCHAR, INTEGER) CASCADE");
    echo "   ✓ Función eliminada\n\n";

    echo "2. Creando función corregida...\n";

    // cvecuenta es INTEGER, necesita CAST a TEXT antes de TRIM
    $sql = "
    CREATE OR REPLACE FUNCTION recaudadora_reqtrans_list(
        p_clave_cuenta VARCHAR DEFAULT NULL,
        p_ejercicio INTEGER DEFAULT NULL
    )
    RETURNS TABLE (
        clave_cuenta TEXT,
        folio INTEGER,
        ejercicio INTEGER,
        estatus TEXT
    ) AS \$\$
    BEGIN
        RETURN QUERY
        SELECT
            COALESCE(r.cvecuenta::TEXT, '')::TEXT as clave_cuenta,
            COALESCE(r.foliotransm, 0)::INTEGER as folio,
            COALESCE(r.axoreq, 0)::INTEGER as ejercicio,
            CASE
                WHEN r.vigencia = '1' OR r.vigencia = 'A' THEN 'Activo'
                WHEN r.vigencia = '0' OR r.vigencia = 'I' THEN 'Inactivo'
                ELSE 'Pendiente'
            END::TEXT as estatus
        FROM catastro_gdl.reqdiftransmision r
        WHERE 1=1
           AND (p_clave_cuenta IS NULL OR p_clave_cuenta = '' OR r.cvecuenta::TEXT ILIKE '%' || p_clave_cuenta || '%')
           AND (p_ejercicio IS NULL OR p_ejercicio = 0 OR r.axoreq = p_ejercicio)
        ORDER BY r.axoreq DESC, r.foliotransm DESC
        LIMIT 100;
    END;
    \$\$ LANGUAGE plpgsql;
    ";

    DB::statement($sql);
    echo "   ✓ Stored procedure creado exitosamente\n\n";

    echo "3. Probando stored procedure...\n";

    $testResult = DB::select("SELECT * FROM recaudadora_reqtrans_list(NULL, NULL) LIMIT 5");
    echo "   ✓ SP funciona correctamente\n";
    echo "   Retornó " . count($testResult) . " registros\n\n";

    if (count($testResult) > 0) {
        echo "   Primeros registros:\n";
        foreach ($testResult as $row) {
            echo "   - Cuenta: {$row->clave_cuenta}, Folio: {$row->folio}, Año: {$row->ejercicio}, Estatus: {$row->estatus}\n";
        }
    }

    echo "\n4. Obteniendo ejemplos específicos para pruebas...\n\n";

    // Obtener todos los registros
    $allRecords = DB::select("SELECT * FROM recaudadora_reqtrans_list(NULL, NULL)");
    echo "   Total de registros disponibles: " . count($allRecords) . "\n\n";

    // Ejemplo 1: Por cuenta específica
    if (count($allRecords) > 0 && $allRecords[0]->clave_cuenta != '') {
        $cuentaEjemplo = $allRecords[0]->clave_cuenta;
        $example1 = DB::select("SELECT * FROM recaudadora_reqtrans_list(?, NULL)", [$cuentaEjemplo]);
        echo "   EJEMPLO 1: Buscar por cuenta específica\n";
        echo "   Parámetros: cuenta = '{$cuentaEjemplo}', ejercicio = NULL\n";
        echo "   Registros esperados: " . count($example1) . "\n";
        if (count($example1) > 0) {
            $r = $example1[0];
            echo "   Resultado: Cuenta {$r->clave_cuenta} - Folio {$r->folio} - Año {$r->ejercicio} - {$r->estatus}\n";
        }
        echo "\n";
    }

    // Ejemplo 2: Por año específico
    if (count($allRecords) > 0) {
        $yearEjemplo = $allRecords[0]->ejercicio;
        $example2 = DB::select("SELECT * FROM recaudadora_reqtrans_list(NULL, ?)", [$yearEjemplo]);
        echo "   EJEMPLO 2: Buscar por año específico\n";
        echo "   Parámetros: cuenta = '', ejercicio = {$yearEjemplo}\n";
        echo "   Registros esperados: " . count($example2) . "\n";
        if (count($example2) > 0) {
            echo "   Primeros registros:\n";
            foreach (array_slice($example2, 0, 3) as $r) {
                echo "      - Cuenta {$r->clave_cuenta} - Folio {$r->folio} - Año {$r->ejercicio} - {$r->estatus}\n";
            }
        }
        echo "\n";
    }

    // Ejemplo 3: Todos los registros
    echo "   EJEMPLO 3: Buscar todos (sin filtros)\n";
    echo "   Parámetros: cuenta = '', ejercicio = NULL\n";
    echo "   Registros esperados: " . count($allRecords) . " (total de registros)\n";
    echo "   Páginas esperadas: " . ceil(count($allRecords) / 10) . " páginas (10 registros por página)\n";
    echo "   Primeros 5 registros:\n";
    foreach (array_slice($allRecords, 0, 5) as $r) {
        echo "      - Cuenta {$r->clave_cuenta} - Folio {$r->folio} - Año {$r->ejercicio} - {$r->estatus}\n";
    }

    echo "\n✅ DESPLIEGUE COMPLETADO EXITOSAMENTE\n";
    echo "\nTabla utilizada: catastro_gdl.reqdiftransmision\n";
    echo "Columnas: clave_cuenta (TEXT), folio (INTEGER), ejercicio (INTEGER), estatus (TEXT)\n";
    echo "Total de registros: " . count($allRecords) . "\n";

} catch (Exception $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
    echo $e->getTraceAsString() . "\n";
}
