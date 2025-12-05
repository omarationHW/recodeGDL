<?php

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "🔍 Verificando relación entre predios y requerimientos...\n\n";

try {
    // Verificar tabla comun.predios
    echo "📊 Tabla comun.predios:\n\n";

    $predioSamples = DB::connection('pgsql')->select("
        SELECT id, cuenta, clave_catastral, propietario
        FROM comun.predios
        WHERE clave_catastral IS NOT NULL
        LIMIT 5
    ");

    foreach ($predioSamples as $i => $predio) {
        echo "Ejemplo " . ($i + 1) . ":\n";
        echo "  ID: {$predio->id}\n";
        echo "  Cuenta: {$predio->cuenta}\n";
        echo "  Clave Catastral: {$predio->clave_catastral}\n";
        echo "  Propietario: {$predio->propietario}\n";
        echo "\n";
    }

    // Verificar tabla public.predio_virtual
    echo "\n📊 Tabla public.predio_virtual:\n\n";

    $predioVirtualSamples = DB::connection('pgsql')->select("
        SELECT id, cvecuenta, cvecatastral, propietario
        FROM public.predio_virtual
        WHERE cvecatastral IS NOT NULL
        LIMIT 5
    ");

    foreach ($predioVirtualSamples as $i => $predio) {
        echo "Ejemplo " . ($i + 1) . ":\n";
        echo "  ID: {$predio->id}\n";
        echo "  CVE Cuenta: {$predio->cvecuenta}\n";
        echo "  CVE Catastral: {$predio->cvecatastral}\n";
        echo "  Propietario: {$predio->propietario}\n";
        echo "\n";
    }

    // Intentar hacer JOIN con h_reqpredial
    echo "\n🔗 Probando JOIN entre h_reqpredial y predio_virtual:\n\n";

    $joinTest = DB::connection('pgsql')->select("
        SELECT
            r.cvereq,
            r.folioreq,
            r.cvecuenta,
            r.axoreq,
            r.total,
            p.cvecatastral,
            p.propietario
        FROM catastro_gdl.h_reqpredial r
        LEFT JOIN public.predio_virtual p ON p.cvecuenta = r.cvecuenta
        WHERE p.cvecatastral IS NOT NULL
        ORDER BY r.cvereq DESC
        LIMIT 5
    ");

    if (count($joinTest) > 0) {
        echo "✅ JOIN exitoso! Ejemplos:\n\n";
        foreach ($joinTest as $i => $row) {
            echo "Ejemplo " . ($i + 1) . ":\n";
            echo "  CVE Req: {$row->cvereq}\n";
            echo "  Folio: {$row->folioreq}\n";
            echo "  Cuenta: {$row->cvecuenta}\n";
            echo "  Clave Catastral: {$row->cvecatastral}\n";
            echo "  Ejercicio: {$row->axoreq}\n";
            echo "  Total: \${$row->total}\n";
            echo "  Propietario: {$row->propietario}\n";
            echo "\n";
        }
    } else {
        echo "❌ No se encontraron coincidencias en el JOIN\n";
    }

    // Contar coincidencias
    echo "\n📈 Estadísticas de coincidencias:\n\n";

    $stats = DB::connection('pgsql')->selectOne("
        SELECT
            COUNT(DISTINCT r.cvereq) as total_requerimientos,
            COUNT(DISTINCT CASE WHEN p.cvecatastral IS NOT NULL THEN r.cvereq END) as con_clave_catastral
        FROM catastro_gdl.h_reqpredial r
        LEFT JOIN public.predio_virtual p ON p.cvecuenta = r.cvecuenta
    ");

    echo "  Total requerimientos: {$stats->total_requerimientos}\n";
    echo "  Con clave catastral: {$stats->con_clave_catastral}\n";
    $porcentaje = round(($stats->con_clave_catastral / $stats->total_requerimientos) * 100, 2);
    echo "  Porcentaje: {$porcentaje}%\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
