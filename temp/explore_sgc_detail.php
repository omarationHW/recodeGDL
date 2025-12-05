<?php

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "🔍 Explorando estructura de SGC y tablas relacionadas...\n\n";

try {
    // Ver estructura de sgc_tramites
    echo "═══════════════════════════════════════════════════════════\n";
    echo "📋 ESTRUCTURA DE comun.sgc_tramites:\n";
    echo "═══════════════════════════════════════════════════════════\n\n";

    $cols = DB::connection('pgsql')->select("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'comun' AND table_name = 'sgc_tramites'
        ORDER BY ordinal_position
    ");

    foreach ($cols as $col) {
        $len = $col->character_maximum_length ? "({$col->character_maximum_length})" : '';
        echo "  • {$col->column_name} - {$col->data_type}{$len}\n";
    }

    // Ver estructura de sgc_tramites_historial
    echo "\n═══════════════════════════════════════════════════════════\n";
    echo "📋 ESTRUCTURA DE comun.sgc_tramites_historial:\n";
    echo "═══════════════════════════════════════════════════════════\n\n";

    $cols2 = DB::connection('pgsql')->select("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'comun' AND table_name = 'sgc_tramites_historial'
        ORDER BY ordinal_position
    ");

    foreach ($cols2 as $col) {
        $len = $col->character_maximum_length ? "({$col->character_maximum_length})" : '';
        echo "  • {$col->column_name} - {$col->data_type}{$len}\n";
    }

    // Explorar tabla t42_control que tiene datos
    echo "\n═══════════════════════════════════════════════════════════\n";
    echo "📋 TABLA RELACIONADA: comun.t42_control (71,983 registros)\n";
    echo "═══════════════════════════════════════════════════════════\n\n";

    $samples = DB::connection('pgsql')->select("
        SELECT
            id,
            ejercicico,
            t42_centros_id,
            t42_tipodocs_id,
            numero,
            LEFT(COALESCE(nombre_generico, ''), 40) as nombre_generico,
            fec_docto,
            tipo_control,
            t42_status_id,
            usuario_mov
        FROM comun.t42_control
        ORDER BY id DESC
        LIMIT 10
    ");

    foreach ($samples as $i => $s) {
        echo "Ejemplo " . ($i + 1) . ":\n";
        echo "  ID: {$s->id}\n";
        echo "  Ejercicio: {$s->ejercicico}\n";
        echo "  Centro: {$s->t42_centros_id}\n";
        echo "  Tipo Doc: {$s->t42_tipodocs_id}\n";
        echo "  Número: {$s->numero}\n";
        echo "  Nombre: {$s->nombre_generico}\n";
        echo "  Fecha: {$s->fec_docto}\n";
        echo "  Status: {$s->t42_status_id}\n";
        echo "  Usuario: {$s->usuario_mov}\n";
        echo "\n";
    }

    // Explorar linea_control
    echo "═══════════════════════════════════════════════════════════\n";
    echo "📋 TABLA RELACIONADA: comun.linea_control (11,308 registros)\n";
    echo "═══════════════════════════════════════════════════════════\n\n";

    $samples2 = DB::connection('pgsql')->select("
        SELECT *
        FROM comun.linea_control
        ORDER BY id DESC
        LIMIT 5
    ");

    foreach ($samples2 as $i => $s) {
        echo "Ejemplo " . ($i + 1) . ":\n";
        echo "  ID: {$s->id}\n";
        echo "  Recaudadora: {$s->recaud}\n";
        echo "  Fecha Carga: {$s->fecha_carga}\n";
        echo "  Fecha Pago: {$s->fecha_pagobco}\n";
        echo "  Total Registros: {$s->totreg}\n";
        echo "  Con Error: {$s->totreg_conerr}\n";
        echo "  Sin Error: {$s->totreg_sinerr}\n";
        echo "\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
