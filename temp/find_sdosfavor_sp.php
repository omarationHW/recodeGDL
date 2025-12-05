<?php

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "🔍 Buscando SP RECAUDADORA_SDOSFAVOR_CTRLEXP...\n\n";

try {
    // Buscar el SP exacto
    $sp = DB::connection('pgsql')->select("
        SELECT
            n.nspname as schema,
            p.proname as name,
            pg_get_function_arguments(p.oid) as arguments,
            pg_get_function_result(p.oid) as return_type
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname ILIKE 'recaudadora_sdosfavor_ctrlexp'
    ");

    if (count($sp) > 0) {
        echo "✅ SP encontrado:\n";
        echo "  Schema: {$sp[0]->schema}\n";
        echo "  Nombre: {$sp[0]->name}\n";
        echo "  Argumentos: {$sp[0]->arguments}\n";
        echo "  Retorna: {$sp[0]->return_type}\n\n";

        // Intentar ejecutar con parámetro vacío
        $spFullName = "{$sp[0]->schema}.{$sp[0]->name}";

        echo "📝 Probando con parámetro vacío...\n\n";

        try {
            $examples = DB::connection('pgsql')->select("
                SELECT * FROM $spFullName('')
                LIMIT 5
            ");

            if (count($examples) > 0) {
                echo "📊 EJEMPLOS DE DATOS REALES:\n\n";

                foreach ($examples as $i => $ex) {
                    if ($i >= 3) break;

                    echo "═════════════════════════════════════════════════════════════\n";
                    echo "EJEMPLO " . ($i + 1) . ":\n";
                    echo "═════════════════════════════════════════════════════════════\n";

                    $data = (array)$ex;
                    foreach ($data as $key => $value) {
                        $val = $value ?? 'NULL';
                        if (strlen($val) > 60) $val = substr($val, 0, 60) . '...';
                        echo "  {$key}: {$val}\n";
                    }
                    echo "\n";
                }

                // Extraer cuentas
                echo "\n╔════════════════════════════════════════════════════════════╗\n";
                echo "║           📋 EJEMPLOS PARA PROBAR EL FORMULARIO           ║\n";
                echo "╚════════════════════════════════════════════════════════════╝\n\n";

                foreach ($examples as $i => $ex) {
                    if ($i >= 3) break;

                    $data = (array)$ex;

                    // Buscar columna que parezca cuenta
                    $cuenta = null;
                    foreach ($data as $key => $value) {
                        if (stripos($key, 'cuenta') !== false && $value) {
                            $cuenta = $value;
                            break;
                        }
                    }

                    if ($cuenta) {
                        echo "Ejemplo " . ($i + 1) . ":\n";
                        echo "  Cuenta: {$cuenta}\n";

                        // Mostrar algunos datos adicionales
                        $c = 0;
                        foreach ($data as $key => $value) {
                            if ($c >= 4) break;
                            if (stripos($key, 'cuenta') === false && $value) {
                                $val = $value;
                                if (strlen($val) > 40) $val = substr($val, 0, 40) . '...';
                                echo "  {$key}: {$val}\n";
                                $c++;
                            }
                        }
                        echo "\n";
                    }
                }
            } else {
                echo "⚠️  No se encontraron datos\n";
            }
        } catch (Exception $e) {
            echo "❌ Error al ejecutar: " . $e->getMessage() . "\n\n";

            // Intentar con otros parámetros
            echo "Probando con ejemplos de cuentas conocidas...\n\n";

            $testCuentas = ['98925', '376230', '247299', '244170'];

            foreach ($testCuentas as $cuenta) {
                try {
                    $result = DB::connection('pgsql')->select("
                        SELECT * FROM $spFullName(?)
                        LIMIT 1
                    ", [$cuenta]);

                    if (count($result) > 0) {
                        echo "✓ Cuenta {$cuenta} tiene datos:\n";
                        $data = (array)$result[0];
                        $c = 0;
                        foreach ($data as $key => $value) {
                            if ($c >= 3) break;
                            $val = $value ?? 'NULL';
                            if (strlen($val) > 40) $val = substr($val, 0, 40) . '...';
                            echo "  {$key}: {$val}\n";
                            $c++;
                        }
                        echo "\n";
                    }
                } catch (Exception $e2) {
                    // Ignorar
                }
            }
        }
    } else {
        echo "❌ SP RECAUDADORA_SDOSFAVOR_CTRLEXP no encontrado\n\n";

        // Buscar tablas relacionadas
        echo "🔎 Buscando tablas relacionadas...\n\n";

        $tables = DB::connection('pgsql')->select("
            SELECT
                schemaname,
                tablename
            FROM pg_tables
            WHERE schemaname IN ('catastro_gdl', 'comun', 'db_ingresos', 'public')
            AND tablename ILIKE '%sdo%favor%'
            LIMIT 10
        ");

        if (count($tables) > 0) {
            foreach ($tables as $table) {
                echo "✓ {$table->schemaname}.{$table->tablename}\n";

                $count = DB::connection('pgsql')->selectOne("
                    SELECT COUNT(*) as total FROM {$table->schemaname}.{$table->tablename}
                ");
                echo "  Registros: {$count->total}\n";

                if ($count->total > 0 && $count->total < 1000) {
                    $samples = DB::connection('pgsql')->select("
                        SELECT * FROM {$table->schemaname}.{$table->tablename}
                        LIMIT 3
                    ");

                    echo "  Ejemplos:\n";
                    foreach ($samples as $i => $s) {
                        $data = (array)$s;
                        $preview = [];
                        $c = 0;
                        foreach ($data as $k => $v) {
                            if ($c >= 3) break;
                            $val = $v ?? 'NULL';
                            if (strlen($val) > 20) $val = substr($val, 0, 20) . '...';
                            $preview[] = "$k=$val";
                            $c++;
                        }
                        echo "    " . ($i + 1) . ". " . implode(', ', $preview) . "\n";
                    }
                }
                echo "\n";
            }
        }
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
