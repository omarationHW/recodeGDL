<?php

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "🔍 Verificando tipos de datos de catastro_gdl.h_reqpredial...\n\n";

try {
    $columns = DB::connection('pgsql')->select("
        SELECT
            column_name,
            data_type,
            udt_name,
            character_maximum_length,
            numeric_precision,
            numeric_scale
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
        AND table_name = 'h_reqpredial'
        ORDER BY ordinal_position
    ");

    echo "📊 Columnas de h_reqpredial:\n\n";

    foreach ($columns as $col) {
        echo "  {$col->column_name}:\n";
        echo "    data_type: {$col->data_type}\n";
        echo "    udt_name: {$col->udt_name}\n";
        if ($col->character_maximum_length) {
            echo "    max_length: {$col->character_maximum_length}\n";
        }
        if ($col->numeric_precision) {
            echo "    precision: {$col->numeric_precision}\n";
        }
        echo "\n";
    }

    // Obtener un ejemplo de datos
    echo "\n📝 Ejemplo de datos:\n\n";
    $sample = DB::connection('pgsql')->select("
        SELECT * FROM catastro_gdl.h_reqpredial LIMIT 1
    ");

    if (count($sample) > 0) {
        $data = (array)$sample[0];
        foreach ($data as $key => $value) {
            $type = gettype($value);
            echo "  {$key}: {$value} (PHP: {$type})\n";
        }
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
