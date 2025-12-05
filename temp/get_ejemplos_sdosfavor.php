<?php

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "🔍 Obteniendo ejemplos para SdosFavor_CtrlExp...\n\n";

try {
    // Primero verificar si el SP existe
    $spExists = DB::connection('pgsql')->select("
        SELECT EXISTS (
            SELECT 1
            FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE p.proname ILIKE '%sdosfavor%ctrlexp%'
        ) as exists
    ");

    if (!$spExists[0]->exists) {
        echo "⚠️  El SP no existe aún. Buscando datos en tablas relacionadas...\n\n";

        // Buscar tablas relacionadas con saldos a favor
        $tables = DB::connection('pgsql')->select("
            SELECT
                schemaname,
                tablename
            FROM pg_tables
            WHERE schemaname IN ('catastro_gdl', 'comun', 'db_ingresos', 'public')
            AND (
                tablename ILIKE '%saldo%favor%'
                OR tablename ILIKE '%sdos%favor%'
                OR tablename ILIKE '%ctrl%exp%'
                OR tablename ILIKE '%control%expediente%'
            )
            ORDER BY schemaname, tablename
            LIMIT 20
        ");

        if (count($tables) > 0) {
            echo "📊 Tablas encontradas relacionadas con saldos a favor:\n\n";

            foreach ($tables as $table) {
                echo "✓ {$table->schemaname}.{$table->tablename}\n";

                // Contar registros
                try {
                    $count = DB::connection('pgsql')->selectOne("
                        SELECT COUNT(*) as total FROM {$table->schemaname}.{$table->tablename}
                    ");
                    echo "  Registros: {$count->total}\n";

                    if ($count->total > 0) {
                        // Obtener estructura
                        $cols = DB::connection('pgsql')->select("
                            SELECT column_name
                            FROM information_schema.columns
                            WHERE table_schema = ? AND table_name = ?
                            ORDER BY ordinal_position
                            LIMIT 10
                        ", [$table->schemaname, $table->tablename]);

                        $colNames = array_map(fn($c) => $c->column_name, $cols);
                        echo "  Columnas: " . implode(', ', $colNames) . "\n";

                        // Obtener 3 ejemplos si hay una columna que parezca cuenta
                        $hasCuenta = false;
                        foreach ($cols as $col) {
                            if (stripos($col->column_name, 'cuenta') !== false || stripos($col->column_name, 'cve') !== false) {
                                $hasCuenta = $col->column_name;
                                break;
                            }
                        }

                        if ($hasCuenta) {
                            $samples = DB::connection('pgsql')->select("
                                SELECT * FROM {$table->schemaname}.{$table->tablename}
                                WHERE {$hasCuenta} IS NOT NULL
                                ORDER BY {$hasCuenta} DESC
                                LIMIT 3
                            ");

                            if (count($samples) > 0) {
                                echo "\n  📝 Ejemplos:\n";
                                foreach ($samples as $i => $sample) {
                                    $data = (array)$sample;
                                    echo "    Ejemplo " . ($i + 1) . ":\n";
                                    $c = 0;
                                    foreach ($data as $key => $value) {
                                        if ($c >= 5) break;
                                        $val = $value ?? 'NULL';
                                        if (strlen($val) > 40) $val = substr($val, 0, 40) . '...';
                                        echo "      {$key}: {$val}\n";
                                        $c++;
                                    }
                                }
                            }
                        }
                    }
                } catch (Exception $e) {
                    echo "  Error al consultar: " . $e->getMessage() . "\n";
                }

                echo "\n";
            }
        } else {
            echo "❌ No se encontraron tablas relacionadas\n";
            echo "\n📋 Buscando en tablas generales de control...\n\n";

            // Buscar en tablas más generales
            $generalTables = ['catastro_gdl.h_reqpredial', 'catastro_gdl.controladora', 'comun.controladora'];

            foreach ($generalTables as $tableName) {
                try {
                    echo "✓ Probando $tableName\n";
                    $samples = DB::connection('pgsql')->select("
                        SELECT cvecuenta
                        FROM $tableName
                        WHERE cvecuenta IS NOT NULL
                        ORDER BY cvecuenta DESC
                        LIMIT 3
                    ");

                    if (count($samples) > 0) {
                        echo "  Ejemplos de cuentas:\n";
                        foreach ($samples as $s) {
                            echo "    - {$s->cvecuenta}\n";
                        }
                    }
                    echo "\n";
                } catch (Exception $e) {
                    // Ignorar errores
                }
            }
        }
    } else {
        echo "✅ El SP existe. Probando con datos...\n\n";

        // Buscar el nombre exacto del SP
        $spName = DB::connection('pgsql')->select("
            SELECT
                n.nspname as schema,
                p.proname as name
            FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE p.proname ILIKE '%sdosfavor%'
            LIMIT 1
        ");

        if (count($spName) > 0) {
            $sp = "{$spName[0]->schema}.{$spName[0]->name}";
            echo "📋 SP encontrado: $sp\n\n";

            // Intentar ejecutar el SP sin parámetros para ver qué retorna
            try {
                $examples = DB::connection('pgsql')->select("
                    SELECT * FROM $sp(NULL)
                    LIMIT 3
                ");

                if (count($examples) > 0) {
                    echo "📊 EJEMPLOS DE DATOS REALES:\n\n";

                    foreach ($examples as $i => $ex) {
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

                    // Extraer cuentas de los ejemplos
                    echo "\n╔════════════════════════════════════════════════════════════╗\n";
                    echo "║               📋 EJEMPLOS PARA PROBAR                      ║\n";
                    echo "╚════════════════════════════════════════════════════════════╝\n\n";

                    foreach ($examples as $i => $ex) {
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
                            echo "Ejemplo " . ($i + 1) . ": Cuenta = {$cuenta}\n";
                        }
                    }
                }
            } catch (Exception $e) {
                echo "❌ Error al ejecutar SP: " . $e->getMessage() . "\n";
            }
        }
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
