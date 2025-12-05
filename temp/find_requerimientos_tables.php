<?php

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "🔍 Buscando tablas de requerimientos...\n\n";

try {
    // Buscar en esquemas específicos
    $schemas = ['catastro_gdl', 'comun', 'comunX', 'db_ingresos', 'multas_reglamentos', 'public'];

    foreach ($schemas as $schema) {
        echo "📂 Schema: $schema\n";

        $tables = DB::connection('pgsql')->select("
            SELECT tablename
            FROM pg_tables
            WHERE schemaname = ?
            AND (tablename ILIKE '%req%dm%' OR tablename ILIKE '%requerimiento%')
            ORDER BY tablename
        ", [$schema]);

        if (count($tables) > 0) {
            foreach ($tables as $table) {
                echo "  ✓ {$table->tablename}\n";

                // Ver estructura
                $cols = DB::connection('pgsql')->select("
                    SELECT column_name, data_type
                    FROM information_schema.columns
                    WHERE table_schema = ? AND table_name = ?
                    ORDER BY ordinal_position
                    LIMIT 10
                ", [$schema, $table->tablename]);

                $colNames = array_map(fn($c) => "{$c->column_name} ({$c->data_type})", $cols);
                echo "    Columnas: " . implode(', ', $colNames) . "\n";

                // Contar registros
                try {
                    $count = DB::connection('pgsql')->selectOne("SELECT COUNT(*) as total FROM $schema.{$table->tablename}");
                    echo "    Registros: {$count->total}\n";

                    // Obtener 2 ejemplos si hay datos
                    if ($count->total > 0) {
                        $samples = DB::connection('pgsql')->select("SELECT * FROM $schema.{$table->tablename} LIMIT 2");
                        echo "    Ejemplos:\n";
                        foreach ($samples as $i => $sample) {
                            echo "      " . ($i+1) . ". " . json_encode($sample) . "\n";
                        }
                    }
                } catch (Exception $e) {
                    echo "    Error al consultar: " . $e->getMessage() . "\n";
                }

                echo "\n";
            }
        } else {
            echo "  (sin tablas)\n";
        }
        echo "\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
