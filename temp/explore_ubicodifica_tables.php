<?php

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "🔍 Buscando tablas relacionadas con ubicación y codificación...\n\n";

try {
    // Buscar tablas con 'ubica', 'codifica', 'calle', 'colonia' en el nombre
    $tables = DB::connection('pgsql')->select("
        SELECT
            schemaname,
            tablename,
            schemaname || '.' || tablename as full_name
        FROM pg_tables
        WHERE schemaname IN ('catastro_gdl', 'comun', 'comunX', 'db_ingresos', 'public', 'multas_reglamentos')
        AND (
            tablename ILIKE '%ubica%'
            OR tablename ILIKE '%codific%'
            OR tablename ILIKE '%calle%'
            OR tablename ILIKE '%colonia%'
            OR tablename ILIKE '%direccion%'
            OR tablename ILIKE '%domicilio%'
        )
        AND tablename NOT ILIKE '%h_%'
        AND tablename NOT ILIKE '%hist%'
        ORDER BY
            CASE
                WHEN tablename ILIKE '%codific%' THEN 1
                WHEN tablename ILIKE '%ubica%' THEN 2
                WHEN tablename ILIKE '%calle%' THEN 3
                ELSE 4
            END,
            schemaname, tablename
        LIMIT 50
    ");

    if (count($tables) > 0) {
        echo "📊 TABLAS ENCONTRADAS:\n\n";

        foreach ($tables as $table) {
            echo "═══════════════════════════════════════════════════════════\n";
            echo "📋 {$table->full_name}\n";
            echo "═══════════════════════════════════════════════════════════\n";

            try {
                // Contar registros
                $count = DB::connection('pgsql')->selectOne("
                    SELECT COUNT(*) as total FROM {$table->full_name}
                ");
                echo "Registros: {$count->total}\n";

                if ($count->total > 0) {
                    // Obtener estructura
                    $cols = DB::connection('pgsql')->select("
                        SELECT column_name, data_type
                        FROM information_schema.columns
                        WHERE table_schema = ? AND table_name = ?
                        ORDER BY ordinal_position
                        LIMIT 20
                    ", [$table->schemaname, $table->tablename]);

                    echo "\nColumnas:\n";
                    foreach ($cols as $col) {
                        echo "  • {$col->column_name} ({$col->data_type})\n";
                    }

                    // Mostrar algunos ejemplos si hay pocos registros
                    if ($count->total > 0 && $count->total < 50000) {
                        $samples = DB::connection('pgsql')->select("
                            SELECT * FROM {$table->full_name}
                            ORDER BY 1 DESC
                            LIMIT 3
                        ");

                        if (count($samples) > 0) {
                            echo "\n📝 Ejemplos:\n";
                            foreach ($samples as $i => $s) {
                                echo "\nEjemplo " . ($i + 1) . ":\n";
                                $data = (array)$s;
                                $shown = 0;
                                foreach ($data as $key => $value) {
                                    if ($shown >= 10) break;
                                    $val = $value ?? 'NULL';
                                    if (is_string($val) && strlen($val) > 40) {
                                        $val = substr($val, 0, 40) . '...';
                                    }
                                    echo "  • $key: $val\n";
                                    $shown++;
                                }
                            }
                        }
                    }
                }
            } catch (Exception $e) {
                echo "Error: " . $e->getMessage() . "\n";
            }

            echo "\n";
        }
    } else {
        echo "❌ No se encontraron tablas relacionadas\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
