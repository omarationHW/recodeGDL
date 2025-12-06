<?php
/**
 * Script para obtener ejemplos de Requerimientos 400 con años recientes
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== BÚSQUEDA DE EJEMPLOS DE REQUERIMIENTOS 400 ===\n\n";

    // Buscar tablas relacionadas con requerimientos
    echo "1. Buscando tablas relacionadas con requerimientos...\n";
    $tables = $pdo->query("
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE tablename ILIKE '%req%'
           OR tablename ILIKE '%requerimiento%'
           OR tablename ILIKE '%400%'
        ORDER BY schemaname, tablename
        LIMIT 20
    ")->fetchAll(PDO::FETCH_ASSOC);

    echo "Tablas encontradas:\n";
    foreach ($tables as $table) {
        echo "  - {$table['schemaname']}.{$table['tablename']}\n";
    }
    echo "\n";

    // Buscar en tablas comunes
    $possibleTables = [
        'comun.ta_12_requerimientos',
        'comun.ta_12_req',
        'public.ta_12_requerimientos',
        'public.ta_12_req',
        'db_ingresos.ta_12_requerimientos',
        'db_ingresos.ta_12_req',
        'comun.requerimientos',
        'public.requerimientos'
    ];

    foreach ($possibleTables as $tableName) {
        try {
            list($schema, $table) = explode('.', $tableName);

            // Verificar si la tabla existe
            $exists = $pdo->query("
                SELECT EXISTS (
                    SELECT 1
                    FROM information_schema.tables
                    WHERE table_schema = '$schema'
                    AND table_name = '$table'
                )
            ")->fetchColumn();

            if ($exists) {
                echo "2. Encontrada tabla: $tableName\n";

                // Obtener estructura de la tabla
                echo "   Columnas de la tabla:\n";
                $columns = $pdo->query("
                    SELECT column_name, data_type
                    FROM information_schema.columns
                    WHERE table_schema = '$schema'
                    AND table_name = '$table'
                    ORDER BY ordinal_position
                ")->fetchAll(PDO::FETCH_ASSOC);

                foreach ($columns as $col) {
                    echo "     - {$col['column_name']} ({$col['data_type']})\n";
                }
                echo "\n";

                // Buscar columnas relacionadas con año/ejercicio
                $yearColumns = ['ejercicio', 'axo', 'ano', 'anio', 'year', 'ejer'];
                $yearCol = null;
                foreach ($yearColumns as $yc) {
                    foreach ($columns as $col) {
                        if (strtolower($col['column_name']) === $yc) {
                            $yearCol = $col['column_name'];
                            break 2;
                        }
                    }
                }

                // Buscar columnas relacionadas con cuenta
                $accountColumns = ['clave_cuenta', 'cvecuenta', 'cuenta', 'cve_cuenta'];
                $accountCol = null;
                foreach ($accountColumns as $ac) {
                    foreach ($columns as $col) {
                        if (strtolower($col['column_name']) === $ac) {
                            $accountCol = $col['column_name'];
                            break 2;
                        }
                    }
                }

                if ($yearCol && $accountCol) {
                    echo "3. Buscando ejemplos con años recientes...\n";
                    echo "   Usando columnas: año=$yearCol, cuenta=$accountCol\n\n";

                    // Buscar años disponibles
                    $years = $pdo->query("
                        SELECT DISTINCT $yearCol as year
                        FROM $tableName
                        WHERE $yearCol IS NOT NULL
                        ORDER BY $yearCol DESC
                        LIMIT 5
                    ")->fetchAll(PDO::FETCH_ASSOC);

                    echo "   Años disponibles en la tabla:\n";
                    foreach ($years as $y) {
                        echo "     - {$y['year']}\n";
                    }
                    echo "\n";

                    // Obtener 3 ejemplos con año más reciente
                    $recentYear = $years[0]['year'] ?? null;

                    if ($recentYear) {
                        echo "4. EJEMPLOS PARA PROBAR (Año: $recentYear):\n\n";

                        $examples = $pdo->query("
                            SELECT *
                            FROM $tableName
                            WHERE $yearCol = $recentYear
                            LIMIT 3
                        ")->fetchAll(PDO::FETCH_ASSOC);

                        foreach ($examples as $idx => $example) {
                            echo "   EJEMPLO " . ($idx + 1) . ":\n";
                            echo "   ----------------------------------------\n";
                            echo "   Cuenta: " . ($example[$accountCol] ?? 'N/A') . "\n";
                            echo "   Año: " . ($example[$yearCol] ?? 'N/A') . "\n";

                            // Mostrar otras columnas importantes
                            $importantCols = ['folio', 'estatus', 'fecha', 'fecent1', 'fecent2'];
                            foreach ($importantCols as $icol) {
                                foreach ($example as $key => $value) {
                                    if (strtolower($key) === $icol) {
                                        echo "   " . ucfirst($icol) . ": " . ($value ?? 'N/A') . "\n";
                                    }
                                }
                            }

                            echo "\n   Datos completos:\n";
                            foreach ($example as $key => $value) {
                                if ($value !== null) {
                                    echo "     $key: $value\n";
                                }
                            }
                            echo "\n";
                        }

                        echo "\n=== INSTRUCCIONES PARA PROBAR ===\n";
                        echo "Usa estos valores en el formulario de ConsReq400.vue:\n\n";
                        foreach ($examples as $idx => $example) {
                            echo "Ejemplo " . ($idx + 1) . ":\n";
                            echo "  Cuenta: " . ($example[$accountCol] ?? 'N/A') . "\n";
                            echo "  Año: " . ($example[$yearCol] ?? 'N/A') . "\n\n";
                        }

                        break; // Salir del loop una vez que encontramos datos
                    }
                } else {
                    echo "   No se encontraron columnas de año o cuenta en esta tabla\n\n";
                }
            }
        } catch (Exception $e) {
            // Continuar con la siguiente tabla
            continue;
        }
    }

} catch (PDOException $e) {
    echo "Error de conexión: " . $e->getMessage() . "\n";
}
