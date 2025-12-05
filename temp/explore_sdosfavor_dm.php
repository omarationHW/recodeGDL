<?php

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "🔍 Explorando tablas relacionadas con Saldos a Favor DM...\n\n";

try {
    // Buscar tablas relacionadas con saldos a favor y DM
    echo "📋 Buscando tablas con 'sdo' o 'favor' y 'dm'...\n\n";

    $tables = DB::connection('pgsql')->select("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE schemaname IN ('catastro_gdl', 'comun', 'comunX', 'db_ingresos', 'public')
        AND (
            (tablename ILIKE '%sdo%favor%' AND tablename ILIKE '%dm%')
            OR tablename ILIKE '%sdosfavor%dm%'
            OR tablename ILIKE '%saldo%favor%dm%'
        )
        ORDER BY schemaname, tablename
        LIMIT 20
    ");

    if (count($tables) > 0) {
        echo "✅ Tablas encontradas:\n\n";

        foreach ($tables as $table) {
            echo "═══════════════════════════════════════════════════════════\n";
            echo "📊 {$table->schemaname}.{$table->tablename}\n";
            echo "═══════════════════════════════════════════════════════════\n";

            // Contar registros
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
                    $samples = DB::connection('pgsql')->select("
                        SELECT * FROM {$table->schemaname}.{$table->tablename}
                        ORDER BY 1 DESC
                        LIMIT 3
                    ");

                    if (count($samples) > 0) {
                        echo "\n📝 Ejemplos de datos:\n\n";
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
            } catch (Exception $e) {
                echo "Error al consultar: " . $e->getMessage() . "\n";
            }

            echo "\n";
        }
    } else {
        echo "❌ No se encontraron tablas con esa combinación exacta\n\n";

        // Buscar tablas solo con 'favor' en diferentes schemas
        echo "🔎 Buscando tablas solo con 'favor'...\n\n";

        $tables2 = DB::connection('pgsql')->select("
            SELECT
                schemaname,
                tablename
            FROM pg_tables
            WHERE schemaname IN ('catastro_gdl', 'comun', 'comunX', 'db_ingresos', 'public')
            AND tablename ILIKE '%favor%'
            ORDER BY schemaname, tablename
            LIMIT 20
        ");

        if (count($tables2) > 0) {
            foreach ($tables2 as $table) {
                echo "✓ {$table->schemaname}.{$table->tablename}\n";

                try {
                    $count = DB::connection('pgsql')->selectOne("
                        SELECT COUNT(*) as total FROM {$table->schemaname}.{$table->tablename}
                    ");
                    echo "  Registros: {$count->total}\n";

                    if ($count->total > 0 && $count->total < 1000) {
                        // Ver estructura básica
                        $cols = DB::connection('pgsql')->select("
                            SELECT column_name
                            FROM information_schema.columns
                            WHERE table_schema = ? AND table_name = ?
                            ORDER BY ordinal_position
                            LIMIT 10
                        ", [$table->schemaname, $table->tablename]);

                        $colNames = array_map(fn($c) => $c->column_name, $cols);
                        echo "  Columnas: " . implode(', ', $colNames) . "\n";

                        // Verificar si tiene columna de cuenta
                        $hasCuenta = false;
                        foreach ($cols as $col) {
                            if (stripos($col->column_name, 'cuenta') !== false) {
                                $hasCuenta = $col->column_name;
                                break;
                            }
                        }

                        if ($hasCuenta) {
                            // Obtener un ejemplo
                            $sample = DB::connection('pgsql')->selectOne("
                                SELECT * FROM {$table->schemaname}.{$table->tablename}
                                WHERE {$hasCuenta} IS NOT NULL
                                ORDER BY {$hasCuenta} DESC
                                LIMIT 1
                            ");

                            if ($sample) {
                                echo "  Ejemplo cuenta: " . $sample->{$hasCuenta} . "\n";
                            }
                        }
                    }
                } catch (Exception $e) {
                    echo "  Error: " . $e->getMessage() . "\n";
                }
                echo "\n";
            }
        }
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
