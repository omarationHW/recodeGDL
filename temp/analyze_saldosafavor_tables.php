<?php

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "🔍 Analizando tablas de saldos a favor en detalle...\n\n";

try {
    // Explorar catastro_gdl.saldosafavor
    echo "═══════════════════════════════════════════════════════════\n";
    echo "📊 TABLA: catastro_gdl.saldosafavor (1,243 registros)\n";
    echo "═══════════════════════════════════════════════════════════\n";

    // Obtener estructura completa
    $cols = DB::connection('pgsql')->select("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl' AND table_name = 'saldosafavor'
        ORDER BY ordinal_position
    ");

    echo "\n📋 ESTRUCTURA:\n";
    foreach ($cols as $col) {
        echo "  • {$col->column_name} ({$col->data_type})\n";
    }

    // Obtener 3 ejemplos con todos los datos
    $samples = DB::connection('pgsql')->select("
        SELECT *
        FROM catastro_gdl.saldosafavor
        WHERE cvecuenta IS NOT NULL
        ORDER BY id DESC
        LIMIT 3
    ");

    if (count($samples) > 0) {
        echo "\n📝 EJEMPLOS DE DATOS REALES:\n\n";
        foreach ($samples as $i => $sample) {
            echo "═════════════════════════════════════════════════════════════\n";
            echo "EJEMPLO " . ($i + 1) . ":\n";
            echo "═════════════════════════════════════════════════════════════\n";

            $data = (array)$sample;
            foreach ($data as $key => $value) {
                $val = $value ?? 'NULL';
                if (strlen($val) > 60) $val = substr($val, 0, 60) . '...';
                echo "  {$key}: {$val}\n";
            }
            echo "\n";
        }
    }

    // Verificar si tiene relación con licencias o anuncios
    echo "\n🔎 Verificando relación con licencias (saldosafavor_lic)...\n\n";

    $licSample = DB::connection('pgsql')->selectOne("
        SELECT *
        FROM catastro_gdl.saldosafavor_lic
        WHERE cvecuenta IS NOT NULL
        ORDER BY id DESC
        LIMIT 1
    ");

    if ($licSample) {
        echo "✅ Tabla saldosafavor_lic tiene datos:\n";
        $data = (array)$licSample;
        foreach ($data as $key => $value) {
            $val = $value ?? 'NULL';
            if (strlen($val) > 60) $val = substr($val, 0, 60) . '...';
            echo "  {$key}: {$val}\n";
        }
        echo "\n";
    }

    // Verificar detalles de licencias
    if ($licSample && isset($licSample->id)) {
        echo "🔍 Buscando detalles en saldosafavor_licd...\n\n";

        $licDetails = DB::connection('pgsql')->select("
            SELECT *
            FROM catastro_gdl.saldosafavor_licd
            WHERE saldosafavor_lic_id = ?
            LIMIT 3
        ", [$licSample->id]);

        if (count($licDetails) > 0) {
            echo "✅ Detalles encontrados:\n";
            foreach ($licDetails as $det) {
                echo "  • Importe aplicado: {$det->importeaplicado}, CVE Pago: {$det->cvepago}, Status: {$det->estatus}\n";
            }
            echo "\n";
        }
    }

    // Ahora explorar saldosafavor_anu (anuncios)
    echo "═══════════════════════════════════════════════════════════\n";
    echo "📊 TABLA: catastro_gdl.saldosafavor_anu (297 registros)\n";
    echo "═══════════════════════════════════════════════════════════\n";

    $anuSample = DB::connection('pgsql')->selectOne("
        SELECT *
        FROM catastro_gdl.saldosafavor_anu
        WHERE id_anuncio IS NOT NULL
        ORDER BY id DESC
        LIMIT 1
    ");

    if ($anuSample) {
        echo "\n✅ Ejemplo de anuncio:\n";
        $data = (array)$anuSample;
        foreach ($data as $key => $value) {
            $val = $value ?? 'NULL';
            if (strlen($val) > 60) $val = substr($val, 0, 60) . '...';
            echo "  {$key}: {$val}\n";
        }
        echo "\n";
    }

    // Buscar si hay una tabla de control general
    echo "═══════════════════════════════════════════════════════════\n";
    echo "📊 RESUMEN Y RECOMENDACIÓN\n";
    echo "═══════════════════════════════════════════════════════════\n\n";

    $stats = DB::connection('pgsql')->select("
        SELECT
            'saldosafavor' as tabla,
            COUNT(*) as total,
            COUNT(DISTINCT cvecuenta) as cuentas_unicas
        FROM catastro_gdl.saldosafavor
        UNION ALL
        SELECT
            'saldosafavor_lic' as tabla,
            COUNT(*) as total,
            COUNT(DISTINCT cvecuenta) as cuentas_unicas
        FROM catastro_gdl.saldosafavor_lic
        UNION ALL
        SELECT
            'saldosafavor_anu' as tabla,
            COUNT(*) as total,
            COUNT(DISTINCT id_anuncio) as cuentas_unicas
        FROM catastro_gdl.saldosafavor_anu
    ");

    foreach ($stats as $stat) {
        echo "✓ {$stat->tabla}: {$stat->total} registros, {$stat->cuentas_unicas} únicas\n";
    }

    echo "\n💡 RECOMENDACIÓN:\n";
    echo "   La tabla principal parece ser 'catastro_gdl.saldosafavor'\n";
    echo "   que contiene 1,243 registros de saldos a favor generales.\n";
    echo "   DM probablemente se refiere a 'Derechos Municipales'.\n\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
