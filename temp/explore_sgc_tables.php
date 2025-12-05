<?php

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "🔍 Buscando tablas relacionadas con SGC...\n\n";

try {
    // Buscar tablas con 'sgc' en el nombre
    $tables = DB::connection('pgsql')->select("
        SELECT
            schemaname,
            tablename,
            schemaname || '.' || tablename as full_name
        FROM pg_tables
        WHERE schemaname IN ('catastro_gdl', 'comun', 'comunX', 'db_ingresos', 'public', 'publicX')
        AND (
            tablename ILIKE '%sgc%'
            OR tablename ILIKE '%gestion%'
            OR tablename ILIKE '%control%'
        )
        ORDER BY schemaname, tablename
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

                if ($count->total > 0 && $count->total < 100000) {
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

                    // Si tiene pocos registros, mostrar algunos ejemplos
                    if ($count->total > 0 && $count->total < 10000) {
                        $samples = DB::connection('pgsql')->select("
                            SELECT * FROM {$table->full_name}
                            ORDER BY 1 DESC
                            LIMIT 3
                        ");

                        if (count($samples) > 0) {
                            echo "\n📝 Ejemplos:\n";
                            foreach ($samples as $i => $s) {
                                $data = (array)$s;
                                echo "  " . ($i + 1) . ". ";
                                $c = 0;
                                foreach ($data as $key => $value) {
                                    if ($c >= 5) break;
                                    $val = $value ?? 'NULL';
                                    if (is_string($val) && strlen($val) > 30) {
                                        $val = substr($val, 0, 30) . '...';
                                    }
                                    echo "$key=$val ";
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
        echo "❌ No se encontraron tablas con 'sgc' en el nombre\n\n";

        // Buscar stored procedures existentes que contengan 'sgc'
        echo "🔍 Buscando stored procedures con 'sgc'...\n\n";

        $sps = DB::connection('pgsql')->select("
            SELECT
                n.nspname as schema_name,
                p.proname as function_name,
                pg_get_function_arguments(p.oid) as arguments
            FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
            AND p.proname ILIKE '%sgc%'
            ORDER BY n.nspname, p.proname
            LIMIT 20
        ");

        if (count($sps) > 0) {
            echo "📋 STORED PROCEDURES ENCONTRADOS:\n\n";
            foreach ($sps as $sp) {
                echo "  • {$sp->schema_name}.{$sp->function_name}({$sp->arguments})\n";
            }
        } else {
            echo "❌ No se encontraron stored procedures con 'sgc'\n";
        }
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
