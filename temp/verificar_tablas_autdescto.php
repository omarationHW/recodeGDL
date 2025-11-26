<?php
/**
 * Script para verificar si existen las tablas necesarias para autdescto
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== Verificando tablas necesarias ===\n\n";

    $tablasNecesarias = ['descpred', 'c_descpred'];

    foreach ($tablasNecesarias as $tabla) {
        echo "Buscando tabla: $tabla\n";

        $sql = "
            SELECT
                schemaname,
                tablename,
                (SELECT COUNT(*) FROM {schemaname}.{tablename}) as row_count
            FROM pg_tables
            WHERE tablename = :tabla
            ORDER BY schemaname;
        ";

        $stmt = $pdo->prepare("
            SELECT
                schemaname,
                tablename
            FROM pg_tables
            WHERE tablename = :tabla
            ORDER BY schemaname;
        ");
        $stmt->execute(['tabla' => $tabla]);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (empty($results)) {
            echo "  ❌ No se encontró la tabla $tabla en ningún esquema\n";
        } else {
            foreach ($results as $row) {
                echo "  ✅ Encontrada: {$row['schemaname']}.{$row['tablename']}\n";

                // Obtener conteo de registros
                try {
                    $countSql = "SELECT COUNT(*) as count FROM {$row['schemaname']}.{$row['tablename']}";
                    $countStmt = $pdo->query($countSql);
                    $count = $countStmt->fetch(PDO::FETCH_ASSOC)['count'];
                    echo "     Registros: $count\n";
                } catch (Exception $e) {
                    echo "     Error al contar registros: {$e->getMessage()}\n";
                }
            }
        }
        echo "\n";
    }

    // Probar el SP con una cuenta de ejemplo
    echo "=== Probando SP recaudadora_autdescto ===\n\n";
    echo "Probando con cuenta vacía (esperando 0 resultados):\n";

    try {
        $stmt = $pdo->prepare("SELECT * FROM recaudadora_autdescto('99999')");
        $stmt->execute();
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "  ✅ SP ejecutado correctamente\n";
        echo "  Resultados: " . count($results) . " registros\n";

        if (count($results) > 0) {
            echo "  Primera fila:\n";
            foreach ($results[0] as $key => $value) {
                echo "    $key: $value\n";
            }
        }
    } catch (PDOException $e) {
        echo "  ❌ Error: {$e->getMessage()}\n";
    }

} catch (PDOException $e) {
    echo "❌ Error de BD: " . $e->getMessage() . "\n";
}
