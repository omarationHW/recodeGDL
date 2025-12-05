<?php

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "🔍 Explorando tablas de usuarios...\n\n";

try {
    // Buscar tablas relacionadas con usuarios
    $tables = DB::connection('pgsql')->select("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE schemaname IN ('catastro_gdl', 'comun', 'db_ingresos', 'public')
        AND (
            tablename ILIKE '%usuario%'
            OR tablename ILIKE '%user%'
            OR tablename ILIKE '%usu%'
        )
        ORDER BY schemaname, tablename
        LIMIT 30
    ");

    if (count($tables) > 0) {
        echo "📊 TABLAS ENCONTRADAS:\n\n";

        foreach ($tables as $table) {
            echo "═══════════════════════════════════════════════════════════\n";
            echo "📋 {$table->schemaname}.{$table->tablename}\n";
            echo "═══════════════════════════════════════════════════════════\n";

            try {
                $count = DB::connection('pgsql')->selectOne("
                    SELECT COUNT(*) as total FROM {$table->schemaname}.{$table->tablename}
                ");
                echo "Registros: {$count->total}\n";

                if ($count->total > 0 && $count->total < 5000) {
                    // Obtener estructura
                    $cols = DB::connection('pgsql')->select("
                        SELECT column_name, data_type
                        FROM information_schema.columns
                        WHERE table_schema = ? AND table_name = ?
                        ORDER BY ordinal_position
                        LIMIT 15
                    ", [$table->schemaname, $table->tablename]);

                    echo "\nColumnas:\n";
                    foreach ($cols as $col) {
                        echo "  • {$col->column_name} ({$col->data_type})\n";
                    }

                    // Buscar columna de password
                    $hasPass = false;
                    foreach ($cols as $col) {
                        if (stripos($col->column_name, 'pass') !== false ||
                            stripos($col->column_name, 'clave') !== false ||
                            stripos($col->column_name, 'password') !== false) {
                            $hasPass = $col->column_name;
                            break;
                        }
                    }

                    if ($hasPass) {
                        echo "\n✅ Tiene columna de password: {$hasPass}\n";

                        // Obtener 3 usuarios de ejemplo (sin mostrar password)
                        $samples = DB::connection('pgsql')->select("
                            SELECT * FROM {$table->schemaname}.{$table->tablename}
                            ORDER BY 1 DESC
                            LIMIT 3
                        ");

                        if (count($samples) > 0) {
                            echo "\n📝 Ejemplos de usuarios:\n";
                            foreach ($samples as $i => $s) {
                                $data = (array)$s;
                                echo "  " . ($i + 1) . ". ";
                                $c = 0;
                                foreach ($data as $key => $value) {
                                    if ($c >= 3) break;
                                    // No mostrar passwords
                                    if (stripos($key, 'pass') === false && stripos($key, 'clave') === false) {
                                        $val = $value ?? 'NULL';
                                        if (strlen($val) > 20) $val = substr($val, 0, 20) . '...';
                                        echo "$key=$val ";
                                        $c++;
                                    }
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
        echo "❌ No se encontraron tablas de usuarios\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
