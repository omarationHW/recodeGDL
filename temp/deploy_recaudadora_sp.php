<?php
/**
 * Script para desplegar SP recaudadora_get_ejecutores
 * Base de datos: multas_reglamentos
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

    // 1. Verificar si sp_get_ejecutores existe
    echo "🔍 Verificando si sp_get_ejecutores existe...\n";
    $check = $pdo->query("
        SELECT routine_name, routine_schema
        FROM information_schema.routines
        WHERE routine_name = 'sp_get_ejecutores'
    ");
    $exists = $check->fetch(PDO::FETCH_ASSOC);

    if ($exists) {
        echo "✅ SP sp_get_ejecutores existe en schema: {$exists['routine_schema']}\n\n";
    } else {
        echo "⚠️  SP sp_get_ejecutores NO existe. Desplegando...\n";

        // Leer el archivo SQL
        $sqlFile = __DIR__ . '/../RefactorX/Base/multas_reglamentos/database/database/Empresas_sp_get_ejecutores.sql';
        if (!file_exists($sqlFile)) {
            throw new Exception("Archivo no encontrado: $sqlFile");
        }

        $sql = file_get_contents($sqlFile);
        $pdo->exec($sql);
        echo "✅ SP sp_get_ejecutores desplegado correctamente\n\n";
    }

    // 2. Verificar si recaudadora_get_ejecutores existe
    echo "🔍 Verificando si recaudadora_get_ejecutores existe...\n";
    $check2 = $pdo->query("
        SELECT routine_name, routine_schema
        FROM information_schema.routines
        WHERE routine_name = 'recaudadora_get_ejecutores'
    ");
    $exists2 = $check2->fetch(PDO::FETCH_ASSOC);

    if ($exists2) {
        echo "✅ SP recaudadora_get_ejecutores ya existe en schema: {$exists2['routine_schema']}\n\n";
    } else {
        echo "⚠️  SP recaudadora_get_ejecutores NO existe. Creando wrapper...\n";

        // Crear el wrapper que adapta los nombres de columnas
        $wrapperSql = "
-- Wrapper para compatibilidad con Vue
CREATE OR REPLACE FUNCTION recaudadora_get_ejecutores()
RETURNS TABLE(cveejecutor SMALLINT, empresa TEXT) AS \$\$
BEGIN
  RETURN QUERY
    SELECT e.cveejecutor, e.ejecutor AS empresa
    FROM sp_get_ejecutores() AS e;
END;
\$\$ LANGUAGE plpgsql;

COMMENT ON FUNCTION recaudadora_get_ejecutores() IS 'Wrapper de sp_get_ejecutores para compatibilidad con componente Vue ActualizaFechaEmpresas';
";

        $pdo->exec($wrapperSql);
        echo "✅ SP recaudadora_get_ejecutores creado correctamente\n\n";
    }

    // 3. Probar el SP
    echo "🧪 Probando recaudadora_get_ejecutores...\n";
    $test = $pdo->query("SELECT * FROM recaudadora_get_ejecutores() LIMIT 5");
    $results = $test->fetchAll(PDO::FETCH_ASSOC);

    echo "✅ SP funciona correctamente. Resultados: " . count($results) . " ejecutores\n";
    if (count($results) > 0) {
        echo "\nPrimeros ejecutores:\n";
        foreach ($results as $row) {
            echo "  - Clave: {$row['cveejecutor']}, Empresa: {$row['empresa']}\n";
        }
    }

    echo "\n✅ ¡Despliegue completado exitosamente!\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
