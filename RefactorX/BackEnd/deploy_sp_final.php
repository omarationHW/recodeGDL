<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== DESPLEGANDO STORED PROCEDURE FINAL ===\n\n";

try {
    // Drop y crear SP principal
    echo "1. Eliminando SP anterior...\n";
    DB::statement("DROP FUNCTION IF EXISTS recaudadora_reqmultas400frm(VARCHAR) CASCADE");
    echo "   ✓ Eliminado\n\n";

    echo "2. Creando recaudadora_reqmultas400frm...\n";

    $sql = <<<'SQL'
CREATE OR REPLACE FUNCTION recaudadora_reqmultas400frm(
    p_clave_cuenta VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    cvelet TEXT,
    cvenum INTEGER,
    ctarfc INTEGER,
    cveapl INTEGER,
    axoreq INTEGER,
    folreq INTEGER,
    fecreq TEXT,
    impcuo NUMERIC,
    observr TEXT,
    vigreq TEXT,
    actreq TEXT,
    tipo_multa TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        TRIM(r.cvelet)::TEXT,
        r.cvenum::INTEGER,
        r.ctarfc::INTEGER,
        r.cveapl::INTEGER,
        r.axoreq::INTEGER,
        r.folreq::INTEGER,
        r.fecreq::TEXT,
        r.impcuo::NUMERIC,
        TRIM(r.observr)::TEXT,
        TRIM(r.vigreq)::TEXT,
        r.actreq::TEXT,
        CASE
            WHEN r.cveapl = 6 THEN 'Federal'
            WHEN r.cveapl = 5 THEN 'Municipal'
            ELSE 'Otro'
        END::TEXT as tipo_multa
    FROM catastro_gdl.req_mul_400 r
    WHERE p_clave_cuenta IS NULL
       OR TRIM(r.cvelet) ILIKE '%' || p_clave_cuenta || '%'
       OR CAST(r.folreq AS TEXT) = p_clave_cuenta
       OR CAST(r.axoreq AS TEXT) = p_clave_cuenta
    ORDER BY r.axoreq DESC, r.folreq DESC
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;
SQL;

    DB::statement($sql);
    echo "   ✓ Creado exitosamente\n\n";

    // Probar el SP
    echo "3. Probando SP...\n";
    $test = DB::select("SELECT * FROM recaudadora_reqmultas400frm(NULL) LIMIT 3");
    echo "   ✓ SP funciona correctamente\n";
    echo "   Retornó " . count($test) . " registros\n\n";

    if (count($test) > 0) {
        echo "4. Ejemplo de resultado:\n";
        $first = (array)$test[0];
        foreach ($first as $key => $value) {
            echo "   $key: " . ($value ?? 'NULL') . "\n";
        }
        echo "\n";
    }

    // Obtener 3 ejemplos para probar
    echo "5. EJEMPLOS PARA PROBAR EN EL FORMULARIO:\n\n";

    $examples = DB::select("
        SELECT DISTINCT
            cvelet,
            cvenum,
            ctarfc,
            cveapl,
            axoreq,
            folreq
        FROM catastro_gdl.req_mul_400
        WHERE axoreq >= 2002
        ORDER BY axoreq DESC, folreq DESC
        LIMIT 3
    ");

    foreach ($examples as $i => $ex) {
        echo "   Ejemplo " . ($i + 1) . ":\n";
        echo "      Búsqueda General:\n";
        echo "         - Folio: {$ex->folreq}\n";
        echo "         - Año: {$ex->axoreq}\n";
        echo "\n";
        echo "      Búsqueda por Acta:\n";
        echo "         - Dependencia: " . trim(substr($ex->cvelet, 0, 3)) . "\n";
        echo "         - Año Acta: {$ex->cvenum}\n";
        echo "         - Núm Acta: {$ex->ctarfc}\n";
        echo "         - Tipo: {$ex->cveapl}\n";
        echo "\n";
        echo "      Búsqueda por Folio:\n";
        echo "         - Año Req: {$ex->axoreq}\n";
        echo "         - Folio Req: {$ex->folreq}\n";
        echo "         - Tipo: {$ex->cveapl}\n";
        echo "\n";
    }

    echo "\n✅ DESPLIEGUE COMPLETADO EXITOSAMENTE\n";
    echo "Puedes probar el formulario en: http://localhost:3000\n";

} catch (Exception $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
