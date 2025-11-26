<?php
/**
 * Script para corregir y desplegar SP sp_get_ejecutores y recaudadora_get_ejecutores
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

    // 1. Desplegar sp_get_ejecutores corregido
    echo "📝 Desplegando sp_get_ejecutores (versión corregida)...\n";

    $sp1 = "
-- Stored Procedure: sp_get_ejecutores
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de ejecutores vigentes.
CREATE OR REPLACE FUNCTION sp_get_ejecutores()
RETURNS TABLE(cveejecutor SMALLINT, ejecutor TEXT) AS \$\$
BEGIN
  RETURN QUERY
    SELECT e.cveejecutor, TRIM(e.paterno)||' '||TRIM(e.materno)||' '||TRIM(e.nombres) AS ejecutor
    FROM ejecutor e
    WHERE e.vigencia = 'V' AND e.fecinic >= DATE '2022-01-01';
END;
\$\$ LANGUAGE plpgsql;

COMMENT ON FUNCTION sp_get_ejecutores() IS 'Obtiene el catálogo de ejecutores vigentes';
";

    $pdo->exec($sp1);
    echo "✅ sp_get_ejecutores desplegado correctamente\n\n";

    // 2. Desplegar recaudadora_get_ejecutores
    echo "📝 Desplegando recaudadora_get_ejecutores (wrapper)...\n";

    $sp2 = "
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

    $pdo->exec($sp2);
    echo "✅ recaudadora_get_ejecutores desplegado correctamente\n\n";

    // 3. Verificar que existan
    echo "🔍 Verificando SPs desplegados...\n";
    $check = $pdo->query("
        SELECT routine_name, routine_schema
        FROM information_schema.routines
        WHERE routine_name IN ('sp_get_ejecutores', 'recaudadora_get_ejecutores')
        ORDER BY routine_name
    ");

    while ($row = $check->fetch(PDO::FETCH_ASSOC)) {
        echo "  ✅ {$row['routine_name']} - Schema: {$row['routine_schema']}\n";
    }

    // 4. Probar el SP
    echo "\n🧪 Probando recaudadora_get_ejecutores...\n";
    $test = $pdo->query("SELECT * FROM recaudadora_get_ejecutores() LIMIT 5");
    $results = $test->fetchAll(PDO::FETCH_ASSOC);

    echo "✅ SP funciona correctamente. Total ejecutores encontrados: " . count($results) . "\n";

    if (count($results) > 0) {
        echo "\n📋 Primeros ejecutores:\n";
        foreach ($results as $idx => $row) {
            echo "  " . ($idx + 1) . ". Clave: {$row['cveejecutor']}, Empresa: {$row['empresa']}\n";
        }
    } else {
        echo "\n⚠️  No se encontraron ejecutores. Esto puede ser normal si la tabla está vacía.\n";
    }

    echo "\n✅ ¡Despliegue completado exitosamente!\n";
    echo "\n📝 Nota: El componente Vue puede usar 'RECAUDADORA_GET_EJECUTORES' en la base 'multas_reglamentos'\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "\n🔍 Stack trace:\n" . $e->getTraceAsString() . "\n";
    exit(1);
}
