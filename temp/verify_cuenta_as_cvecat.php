<?php

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "🔍 Verificando si cvecuenta puede usarse como clave catastral...\n\n";

try {
    // Verificar controladora
    echo "📊 Verificando tabla catastro_gdl.controladora...\n\n";

    $controladora = DB::connection('pgsql')->select("
        SELECT cvecuenta, cvecatnva
        FROM catastro_gdl.controladora
        WHERE cvecuenta IS NOT NULL
        LIMIT 5
    ");

    foreach ($controladora as $i => $row) {
        echo "Ejemplo " . ($i + 1) . ":\n";
        echo "  CVE Cuenta: {$row->cvecuenta}\n";
        echo "  CVE Catastral Nueva: {$row->cvecatnva}\n";
        echo "\n";
    }

    // Buscar si algún requerimiento tiene coincidencia en controladora
    echo "\n🔗 JOIN entre h_reqpredial y controladora:\n\n";

    $joinControladora = DB::connection('pgsql')->select("
        SELECT
            r.cvereq,
            r.folioreq,
            r.cvecuenta as cuenta,
            r.axoreq as ejercicio,
            r.total,
            r.vigencia,
            c.cvecatnva as clave_catastral
        FROM catastro_gdl.h_reqpredial r
        LEFT JOIN catastro_gdl.controladora c ON c.cvecuenta = r.cvecuenta
        WHERE c.cvecatnva IS NOT NULL
        ORDER BY r.cvereq DESC
        LIMIT 5
    ");

    if (count($joinControladora) > 0) {
        echo "✅ JOIN exitoso con controladora!\n\n";
        foreach ($joinControladora as $i => $row) {
            echo "Ejemplo " . ($i + 1) . ":\n";
            echo "  CVE Req: {$row->cvereq}\n";
            echo "  Folio: {$row->folioreq}\n";
            echo "  Cuenta: {$row->cuenta}\n";
            echo "  Clave Catastral: {$row->clave_catastral}\n";
            echo "  Ejercicio: {$row->ejercicio}\n";
            echo "  Total: \${$row->total}\n";
            echo "  Vigencia: {$row->vigencia}\n";
            echo "\n";
        }
    } else {
        echo "❌ No hay coincidencias\n";
    }

    // Estadísticas
    echo "\n📈 Estadísticas:\n\n";

    $stats = DB::connection('pgsql')->selectOne("
        SELECT
            COUNT(DISTINCT r.cvereq) as total_req,
            COUNT(DISTINCT CASE WHEN c.cvecatnva IS NOT NULL THEN r.cvereq END) as con_cvecat
        FROM catastro_gdl.h_reqpredial r
        LEFT JOIN catastro_gdl.controladora c ON c.cvecuenta = r.cvecuenta
    ");

    echo "  Total requerimientos: {$stats->total_req}\n";
    echo "  Con clave catastral: {$stats->con_cvecat}\n";

    if ($stats->con_cvecat > 0) {
        $porcentaje = round(($stats->con_cvecat / $stats->total_req) * 100, 2);
        echo "  Porcentaje: {$porcentaje}%\n";
    }

    // Si no hay coincidencias, simplemente usar cvecuenta como cvecat
    if ($stats->con_cvecat == 0) {
        echo "\n💡 DECISIÓN: Usar cvecuenta como clave catastral directamente\n";
        echo "   En este sistema, la cuenta ES la clave catastral\n\n";

        echo "📝 Ejemplos usando cvecuenta como cvecat:\n\n";

        $ejemplos = DB::connection('pgsql')->select("
            SELECT
                r.cvereq,
                r.folioreq,
                r.cvecuenta as clave_catastral,
                r.axoreq as ejercicio,
                r.fecemi as fecha_emision,
                r.impuesto,
                r.recargos,
                r.gastos,
                r.multas,
                r.total,
                CASE
                    WHEN r.vigencia = 'P' THEN 'Pendiente'
                    WHEN r.vigencia = 'C' THEN 'Cancelado'
                    WHEN r.vigencia = 'E' THEN 'Entregado'
                    ELSE r.vigencia
                END as vigencia
            FROM catastro_gdl.h_reqpredial r
            ORDER BY r.cvereq DESC
            LIMIT 3
        ");

        foreach ($ejemplos as $i => $ej) {
            echo "Ejemplo " . ($i + 1) . ":\n";
            echo "  CVE Req: {$ej->cvereq}\n";
            echo "  Folio: {$ej->folioreq}\n";
            echo "  Clave Catastral: {$ej->clave_catastral}\n";
            echo "  Ejercicio: {$ej->ejercicio}\n";
            echo "  Fecha Emisión: {$ej->fecha_emision}\n";
            echo "  Impuesto: \${$ej->impuesto}\n";
            echo "  Recargos: \${$ej->recargos}\n";
            echo "  Gastos: \${$ej->gastos}\n";
            echo "  Multas: \${$ej->multas}\n";
            echo "  Total: \${$ej->total}\n";
            echo "  Vigencia: {$ej->vigencia}\n";
            echo "\n";
        }
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
