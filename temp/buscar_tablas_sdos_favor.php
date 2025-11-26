<?php
/**
 * Buscar tablas relacionadas con saldos a favor
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "🔍 Buscando tablas relacionadas con saldos a favor...\n\n";

    // Buscar tablas que contengan "saldo", "favor", "sdos" en el nombre
    $sql = "
        SELECT
            schemaname,
            tablename,
            pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
        FROM pg_tables
        WHERE schemaname IN ('catastro_gdl', 'comun', 'public', 'db_ingresos')
        AND (
            tablename LIKE '%saldo%'
            OR tablename LIKE '%favor%'
            OR tablename LIKE '%sdos%'
            OR tablename LIKE '%sdf%'
        )
        ORDER BY schemaname, tablename
    ";

    $stmt = $pdo->query($sql);
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        echo "✅ Tablas encontradas: " . count($tables) . "\n\n";

        foreach ($tables as $table) {
            echo sprintf(
                "📊 %s.%s (Tamaño: %s)\n",
                $table['schemaname'],
                $table['tablename'],
                $table['size']
            );
        }
    } else {
        echo "❌ No se encontraron tablas\n";
    }

    echo "\n\n🔍 Verificando estructura de tablas principales...\n\n";

    // Verificar si existe alguna tabla específica
    $tablasVerificar = [
        'catastro_gdl.reqsdosfavor',
        'catastro_gdl.sdosfavor',
        'catastro_gdl.reqdiftransmision',
        'comun.sdosfavor'
    ];

    foreach ($tablasVerificar as $tabla) {
        list($schema, $tablename) = explode('.', $tabla);

        $sql = "
            SELECT COUNT(*) as count
            FROM information_schema.tables
            WHERE table_schema = :schema
            AND table_name = :tablename
        ";

        $stmt = $pdo->prepare($sql);
        $stmt->execute(['schema' => $schema, 'tablename' => $tablename]);
        $exists = $stmt->fetchColumn() > 0;

        if ($exists) {
            echo "✅ $tabla existe\n";

            // Obtener conteo de registros
            try {
                $count = $pdo->query("SELECT COUNT(*) FROM $tabla")->fetchColumn();
                echo "   📝 Registros: " . number_format($count) . "\n";

                // Obtener estructura
                $sql = "
                    SELECT column_name, data_type, character_maximum_length
                    FROM information_schema.columns
                    WHERE table_schema = :schema
                    AND table_name = :tablename
                    ORDER BY ordinal_position
                    LIMIT 10
                ";

                $stmt = $pdo->prepare($sql);
                $stmt->execute(['schema' => $schema, 'tablename' => $tablename]);
                $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

                echo "   📋 Columnas principales:\n";
                foreach ($columns as $col) {
                    $type = $col['data_type'];
                    if ($col['character_maximum_length']) {
                        $type .= "({$col['character_maximum_length']})";
                    }
                    echo "      - {$col['column_name']}: $type\n";
                }

                // Obtener ejemplo de datos
                echo "   🔍 Ejemplo de datos:\n";
                $sample = $pdo->query("SELECT * FROM $tabla LIMIT 3")->fetchAll(PDO::FETCH_ASSOC);
                foreach ($sample as $idx => $row) {
                    echo "      Registro " . ($idx + 1) . ": " . json_encode($row, JSON_UNESCAPED_UNICODE) . "\n";
                }

                echo "\n";

            } catch (Exception $e) {
                echo "   ⚠️ Error al obtener detalles: " . $e->getMessage() . "\n\n";
            }
        } else {
            echo "❌ $tabla NO existe\n";
        }
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
