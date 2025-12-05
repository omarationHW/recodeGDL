<?php

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== EJEMPLOS DE REQUERIMIENTOS ===\n\n";

try {
    DB::connection('pgsql')->getPdo();
    echo "✅ Conectado a PostgreSQL\n\n";

    // Ejemplos de reqpredial
    echo "=== TABLA: comun.reqpredial (3,676,785 registros) ===\n";
    echo str_repeat("=", 80) . "\n\n";

    $reqpred = DB::connection('pgsql')->select("
        SELECT
            cvereq,
            folioreq,
            axoreq,
            cvecuenta,
            recaud,
            impuesto,
            total,
            fecemi
        FROM comun.reqpredial
        WHERE cvereq IS NOT NULL
        AND folioreq IS NOT NULL
        ORDER BY fecemi DESC
        LIMIT 5
    ");

    foreach ($reqpred as $i => $r) {
        $num = $i + 1;
        echo "Ejemplo $num:\n";
        echo "  Clave Req: {$r->cvereq}\n";
        echo "  Folio: {$r->folioreq}/{$r->axoreq}\n";
        echo "  Cuenta: {$r->cvecuenta}\n";
        echo "  Recaudadora: {$r->recaud}\n";
        echo "  Impuesto: $" . number_format($r->impuesto, 2) . "\n";
        echo "  Total: $" . number_format($r->total, 2) . "\n";
        echo "  Fecha Emisión: {$r->fecemi}\n";
        echo "\n";
    }

    // Ejemplos de reqmultas
    echo "\n" . str_repeat("=", 80) . "\n";
    echo "=== TABLA: comun.reqmultas (403,145 registros) ===\n";
    echo str_repeat("=", 80) . "\n\n";

    $reqmul = DB::connection('pgsql')->select("
        SELECT
            cvereq,
            folioreq,
            axoreq,
            id_multa,
            recaud,
            total,
            fecemi
        FROM comun.reqmultas
        WHERE cvereq IS NOT NULL
        AND folioreq IS NOT NULL
        ORDER BY fecemi DESC
        LIMIT 5
    ");

    foreach ($reqmul as $i => $r) {
        $num = $i + 1;
        echo "Ejemplo $num:\n";
        echo "  Clave Req: {$r->cvereq}\n";
        echo "  Folio: {$r->folioreq}/{$r->axoreq}\n";
        echo "  ID Multa: {$r->id_multa}\n";
        echo "  Recaudadora: {$r->recaud}\n";
        echo "  Total: $" . number_format($r->total, 2) . "\n";
        echo "  Fecha Emisión: {$r->fecemi}\n";
        echo "\n";
    }

    // Ejemplos de reqlicencias
    echo "\n" . str_repeat("=", 80) . "\n";
    echo "=== TABLA: comun.reqlicencias (224,736 registros) ===\n";
    echo str_repeat("=", 80) . "\n\n";

    $reqlic = DB::connection('pgsql')->select("
        SELECT
            cvereq,
            folioreq,
            axoreq,
            id_licencia,
            recaud,
            total,
            tipolic
        FROM comun.reqlicencias
        WHERE cvereq IS NOT NULL
        AND folioreq IS NOT NULL
        ORDER BY axoreq DESC
        LIMIT 5
    ");

    foreach ($reqlic as $i => $r) {
        $num = $i + 1;
        echo "Ejemplo $num:\n";
        echo "  Clave Req: {$r->cvereq}\n";
        echo "  Folio: {$r->folioreq}/{$r->axoreq}\n";
        echo "  ID Licencia: {$r->id_licencia}\n";
        echo "  Recaudadora: {$r->recaud}\n";
        echo "  Tipo Licencia: {$r->tipolic}\n";
        echo "  Total: $" . number_format($r->total, 2) . "\n";
        echo "\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
