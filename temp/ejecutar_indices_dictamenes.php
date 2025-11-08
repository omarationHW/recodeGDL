<?php
/**
 * Ejecutar creación de índices para dictamenes
 * Fecha: 2025-11-05
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "\n========================================\n";
    echo "CREANDO ÍNDICES - comun.dictamenes\n";
    echo "========================================\n\n";

    $sqlFile = __DIR__ . '/crear_indices_dictamenes.sql';

    if (!file_exists($sqlFile)) {
        throw new Exception("Archivo SQL no encontrado: $sqlFile");
    }

    echo "📄 Leyendo archivo SQL...\n\n";
    $sql = file_get_contents($sqlFile);

    // Separar por punto y coma para ejecutar cada CREATE INDEX
    $statements = explode(';', $sql);

    $created = 0;
    $start = microtime(true);

    foreach ($statements as $statement) {
        $statement = trim($statement);

        // Ignorar comentarios y líneas vacías
        if (empty($statement) ||
            strpos($statement, '--') === 0 ||
            strpos($statement, '/*') === 0) {
            continue;
        }

        // Detectar si es un CREATE INDEX
        if (stripos($statement, 'CREATE INDEX') !== false) {
            // Extraer el nombre del índice
            preg_match('/idx_[a-z_]+/', $statement, $matches);
            $indexName = $matches[0] ?? 'unknown';

            echo "⚙️  Creando: {$indexName}...\n";

            try {
                $pdo->exec($statement);
                echo "   ✅ Creado\n\n";
                $created++;
            } catch (PDOException $e) {
                if (strpos($e->getMessage(), 'already exists') !== false) {
                    echo "   ℹ️  Ya existe\n\n";
                } else {
                    throw $e;
                }
            }
        }
        // Ejecutar SELECT final para verificación
        else if (stripos($statement, 'SELECT') !== false &&
                 stripos($statement, 'pg_size_pretty') !== false) {
            echo "\n📊 Verificando índices creados:\n";
            echo str_repeat("-", 100) . "\n";
            printf("%-45s %-35s %-15s\n", "Index Name", "Columns", "Size");
            echo str_repeat("-", 100) . "\n";

            $stmt = $pdo->query($statement);
            $indices = $stmt->fetchAll(PDO::FETCH_OBJ);

            foreach ($indices as $idx) {
                printf("%-45s %-35s %-15s\n",
                    $idx->index_name,
                    substr($idx->columns, 0, 35),
                    $idx->index_size
                );
            }
            echo str_repeat("-", 100) . "\n";
        }
    }

    $elapsed = round(microtime(true) - $start, 2);

    echo "\n========================================\n";
    echo "ÍNDICES CREADOS EXITOSAMENTE\n";
    echo "========================================\n";
    echo "Total de índices creados: {$created}\n";
    echo "Tiempo transcurrido: {$elapsed} segundos\n\n";

    echo "✅ La tabla comun.dictamenes ahora tiene índices\n";
    echo "✅ Las búsquedas serán significativamente más rápidas\n\n";

} catch (PDOException $e) {
    echo "\n❌ ERROR DE BASE DE DATOS:\n";
    echo "   " . $e->getMessage() . "\n\n";
    exit(1);
} catch (Exception $e) {
    echo "\n❌ ERROR:\n";
    echo "   " . $e->getMessage() . "\n\n";
    exit(1);
}
