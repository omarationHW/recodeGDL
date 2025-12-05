<?php

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== COLUMNAS DE comun.h_descmultampal ===\n\n";

$cols = DB::connection('pgsql')->select("
    SELECT column_name, data_type, udt_name
    FROM information_schema.columns
    WHERE table_schema = 'comun'
    AND table_name = 'h_descmultampal'
    AND column_name IN ('folio', 'cvepago', 'autoriza', 'estado', 'tipo_descto', 'id_multa')
    ORDER BY ordinal_position
");

foreach ($cols as $c) {
    echo "{$c->column_name}: {$c->data_type} ({$c->udt_name})\n";
}

echo "\n=== MUESTRA DE DATOS ===\n\n";

$sample = DB::connection('pgsql')->select("
    SELECT
        id_multa,
        folio,
        cvepago,
        autoriza,
        estado,
        tipo_descto,
        valor
    FROM comun.h_descmultampal
    WHERE valor > 0
    LIMIT 5
");

foreach ($sample as $s) {
    print_r($s);
    echo "\n";
}
