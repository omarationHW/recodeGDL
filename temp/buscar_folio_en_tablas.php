<?php
/**
 * Script para buscar el folio en diferentes tablas
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✅ Conectado a la base de datos: $dbname\n\n";

    $clave_cuenta = '11111111111111';
    $folio = 1003;
    $anio = 2024;

    // Lista de tablas a buscar
    $tables = [
        'reqpredial',
        'ctaempexterna',
        'reqdiftransmision',
        'reqtransmision',
        'reqctasfavor',
        'requepredial'
    ];

    foreach ($tables as $table) {
        echo "🔍 Buscando en tabla: {$table}\n";
        echo "=====================================\n";

        try {
            // Primero ver si la tabla existe
            $exists = $pdo->query("
                SELECT EXISTS (
                    SELECT FROM information_schema.tables
                    WHERE table_name = '{$table}'
                )
            ")->fetchColumn();

            if (!$exists) {
                echo "  ⚠️  Tabla no existe\n\n";
                continue;
            }

            // Ver estructura de la tabla
            $columns = $pdo->query("
                SELECT column_name, data_type
                FROM information_schema.columns
                WHERE table_name = '{$table}'
                ORDER BY ordinal_position
            ")->fetchAll(PDO::FETCH_ASSOC);

            echo "  Columnas de la tabla:\n";
            $col_names = array_column($columns, 'column_name');

            // Buscar columnas que podrían contener la clave de cuenta
            $cuenta_cols = array_filter($col_names, function($col) {
                return stripos($col, 'cuenta') !== false || stripos($col, 'cve') !== false;
            });

            // Buscar columnas que podrían contener el folio
            $folio_cols = array_filter($col_names, function($col) {
                return stripos($col, 'folio') !== false;
            });

            // Buscar columnas que podrían contener el año
            $anio_cols = array_filter($col_names, function($col) {
                return stripos($col, 'anio') !== false || stripos($col, 'axo') !== false || stripos($col, 'year') !== false;
            });

            echo "    - Columnas de cuenta posibles: " . implode(', ', $cuenta_cols) . "\n";
            echo "    - Columnas de folio posibles: " . implode(', ', $folio_cols) . "\n";
            echo "    - Columnas de año posibles: " . implode(', ', $anio_cols) . "\n";

            // Intentar buscar por folio
            if (!empty($folio_cols)) {
                $folio_col = reset($folio_cols);
                $query = "SELECT * FROM {$table} WHERE {$folio_col} = :folio LIMIT 5";
                echo "\n  Buscando con query: {$query}\n";

                $stmt = $pdo->prepare($query);
                $stmt->execute(['folio' => $folio]);
                $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

                if (count($results) > 0) {
                    echo "  ✅ Se encontraron " . count($results) . " registros con folio {$folio}:\n";
                    foreach ($results as $i => $row) {
                        echo "  Registro " . ($i + 1) . ":\n";
                        foreach ($row as $key => $value) {
                            if ($value !== null) {
                                echo "    - {$key}: {$value}\n";
                            }
                        }
                        echo "\n";
                    }
                } else {
                    echo "  ❌ No se encontraron registros con folio {$folio}\n";
                }
            }

            echo "\n  📊 Total de registros en tabla: ";
            $total = $pdo->query("SELECT COUNT(*) FROM {$table}")->fetchColumn();
            echo "{$total}\n";

        } catch (Exception $e) {
            echo "  ❌ Error: " . $e->getMessage() . "\n";
        }

        echo "\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "\n🔍 Stack trace:\n" . $e->getTraceAsString() . "\n";
    exit(1);
}
