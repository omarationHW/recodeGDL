<?php
/**
 * Script para desplegar SPs de RptFacturaEmision
 */

$host = 'localhost';
$port = '5432';
$dbname = 'mercados';
$user = 'postgres';
$password = 'casita';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✓ Conectado a la base de datos: $dbname\n\n";

    $sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/ok/92_SP_MERCADOS_RPTFACTURAEMISION_EXACTO_all_procedures.sql';

    if (!file_exists($sqlFile)) {
        throw new Exception("Archivo SQL no encontrado: $sqlFile");
    }

    $sql = file_get_contents($sqlFile);

    // Eliminar comandos \c (cambio de base de datos) y SET search_path
    $sql = preg_replace('/\\\\c\s+\w+;/i', '', $sql);
    $sql = preg_replace('/SET\s+search_path\s+TO\s+\w+;/i', '', $sql);

    // Separar por delimitador de SPs
    $statements = preg_split('/-- ={40,}/i', $sql);

    $deployed = 0;
    $errors = 0;

    foreach ($statements as $statement) {
        $statement = trim($statement);

        if (empty($statement) || strpos($statement, 'CREATE OR REPLACE FUNCTION') === false) {
            continue;
        }

        // Extraer nombre del SP
        preg_match('/CREATE OR REPLACE FUNCTION\s+(\w+)\s*\(/i', $statement, $matches);
        $spName = $matches[1] ?? 'unknown';

        try {
            $pdo->exec($statement);
            echo "✓ SP desplegado: $spName\n";
            $deployed++;
        } catch (PDOException $e) {
            echo "✗ Error en SP $spName: " . $e->getMessage() . "\n";
            $errors++;
        }
    }

    echo "\n" . str_repeat("=", 50) . "\n";
    echo "RESUMEN:\n";
    echo "- SPs desplegados exitosamente: $deployed\n";
    echo "- Errores: $errors\n";
    echo str_repeat("=", 50) . "\n";

} catch (Exception $e) {
    echo "✗ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
