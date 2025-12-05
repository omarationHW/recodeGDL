<?php

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "🔍 Explorando tablas relacionadas con calificación QR...\n\n";

try {
    // Buscar tablas relacionadas con QR o calificación
    echo "📋 Buscando tablas con 'qr' o 'califica'...\n\n";

    $tables = DB::connection('pgsql')->select("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE schemaname IN ('catastro_gdl', 'comun', 'comunX', 'db_ingresos', 'public')
        AND (
            tablename ILIKE '%qr%'
            OR tablename ILIKE '%calific%'
        )
        ORDER BY schemaname, tablename
        LIMIT 30
    ");

    if (count($tables) > 0) {
        echo "✅ Tablas encontradas:\n\n";

        foreach ($tables as $table) {
            echo "═══════════════════════════════════════════════════════════\n";
            echo "📊 {$table->schemaname}.{$table->tablename}\n";
            echo "═══════════════════════════════════════════════════════════\n";

            try {
                $count = DB::connection('pgsql')->selectOne("
                    SELECT COUNT(*) as total FROM {$table->schemaname}.{$table->tablename}
                ");
                echo "Registros: {$count->total}\n";

                if ($count->total > 0) {
                    // Obtener estructura
                    $cols = DB::connection('pgsql')->select("
                        SELECT column_name, data_type
                        FROM information_schema.columns
                        WHERE table_schema = ? AND table_name = ?
                        ORDER BY ordinal_position
                    ", [$table->schemaname, $table->tablename]);

                    echo "\nColumnas:\n";
                    foreach ($cols as $col) {
                        echo "  • {$col->column_name} ({$col->data_type})\n";
                    }

                    // Obtener 3 ejemplos
                    if ($count->total < 10000) {
                        $samples = DB::connection('pgsql')->select("
                            SELECT * FROM {$table->schemaname}.{$table->tablename}
                            ORDER BY 1 DESC
                            LIMIT 3
                        ");

                        if (count($samples) > 0) {
                            echo "\n📝 Ejemplos:\n\n";
                            foreach ($samples as $i => $sample) {
                                echo "Ejemplo " . ($i + 1) . ":\n";
                                $data = (array)$sample;
                                $c = 0;
                                foreach ($data as $key => $value) {
                                    if ($c >= 8) break;
                                    $val = $value ?? 'NULL';
                                    if (strlen($val) > 50) $val = substr($val, 0, 50) . '...';
                                    echo "  {$key}: {$val}\n";
                                    $c++;
                                }
                                echo "\n";
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
        echo "❌ No se encontraron tablas relacionadas con 'qr' o 'califica'\n\n";

        // Buscar en otros términos relacionados
        echo "🔎 Buscando tablas con términos alternativos...\n\n";

        $altTables = DB::connection('pgsql')->select("
            SELECT
                schemaname,
                tablename
            FROM pg_tables
            WHERE schemaname IN ('catastro_gdl', 'comun', 'db_ingresos', 'public')
            AND (
                tablename ILIKE '%multa%'
                OR tablename ILIKE '%pago%'
                OR tablename ILIKE '%folio%'
                OR tablename ILIKE '%validac%'
            )
            ORDER BY tablename
            LIMIT 20
        ");

        if (count($altTables) > 0) {
            foreach ($altTables as $table) {
                echo "✓ {$table->schemaname}.{$table->tablename}\n";

                try {
                    $count = DB::connection('pgsql')->selectOne("
                        SELECT COUNT(*) as total FROM {$table->schemaname}.{$table->tablename}
                    ");
                    echo "  Registros: {$count->total}\n";
                } catch (Exception $e) {
                    // Ignorar
                }
            }
        }
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
