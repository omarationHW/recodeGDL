<?php

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "🔍 Explorando catastro_gdl.presc_multas en detalle...\n\n";

try {
    // Ver estructura completa
    $cols = DB::connection('pgsql')->select("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl' AND table_name = 'presc_multas'
        ORDER BY ordinal_position
    ");

    echo "📋 ESTRUCTURA DE catastro_gdl.presc_multas:\n\n";
    foreach ($cols as $col) {
        $len = $col->character_maximum_length ? "({$col->character_maximum_length})" : '';
        echo "  • {$col->column_name} - {$col->data_type}{$len}\n";
    }

    // Obtener 10 ejemplos con datos completos
    echo "\n═══════════════════════════════════════════════════════════\n";
    echo "📝 EJEMPLOS DE PRESCRIPCIONES (10 registros):\n";
    echo "═══════════════════════════════════════════════════════════\n\n";

    $samples = DB::connection('pgsql')->select("
        SELECT
            id_prescri,
            fecaut,
            fecha_prescri,
            oficio,
            capturista,
            dependencia,
            LEFT(COALESCE(observaciones, ''), 50) as observaciones_short,
            id_multa
        FROM catastro_gdl.presc_multas
        WHERE id_multa IS NOT NULL
        ORDER BY id_prescri DESC
        LIMIT 10
    ");

    foreach ($samples as $i => $s) {
        echo "Ejemplo " . ($i + 1) . ":\n";
        echo "  ID Prescripción: {$s->id_prescri}\n";
        echo "  Fecha Autorización: {$s->fecaut}\n";
        echo "  Fecha Prescripción: {$s->fecha_prescri}\n";
        echo "  Oficio: " . ($s->oficio ?? 'N/A') . "\n";
        echo "  Capturista: " . ($s->capturista ?? 'N/A') . "\n";
        echo "  Dependencia: " . ($s->dependencia ?? 'N/A') . "\n";
        echo "  ID Multa: {$s->id_multa}\n";
        if ($s->observaciones_short) {
            echo "  Observaciones: {$s->observaciones_short}...\n";
        }
        echo "\n";
    }

    // Contar por dependencia
    echo "═══════════════════════════════════════════════════════════\n";
    echo "📊 PRESCRIPCIONES POR DEPENDENCIA:\n";
    echo "═══════════════════════════════════════════════════════════\n\n";

    $stats = DB::connection('pgsql')->select("
        SELECT
            COALESCE(TRIM(dependencia), 'SIN DEPENDENCIA') as dependencia,
            COUNT(*) as total
        FROM catastro_gdl.presc_multas
        GROUP BY TRIM(dependencia)
        ORDER BY total DESC
        LIMIT 10
    ");

    foreach ($stats as $st) {
        echo "  • {$st->dependencia}: {$st->total} registros\n";
    }

    // Contar por año
    echo "\n═══════════════════════════════════════════════════════════\n";
    echo "📊 PRESCRIPCIONES POR AÑO:\n";
    echo "═══════════════════════════════════════════════════════════\n\n";

    $years = DB::connection('pgsql')->select("
        SELECT
            EXTRACT(YEAR FROM fecha_prescri) as axo,
            COUNT(*) as total
        FROM catastro_gdl.presc_multas
        WHERE fecha_prescri IS NOT NULL
        GROUP BY EXTRACT(YEAR FROM fecha_prescri)
        ORDER BY axo DESC
        LIMIT 10
    ");

    foreach ($years as $y) {
        echo "  • Año {$y->axo}: {$y->total} registros\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
