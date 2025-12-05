<?php
// Fix recaudadora_dderechoslic SP - Drop and recreate

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== FIXING recaudadora_dderechoslic ===\n\n";

    // Drop the old function
    echo "1. Dropping old function...\n";
    $pdo->exec("DROP FUNCTION IF EXISTS multas_reglamentos.recaudadora_dderechoslic(integer) CASCADE");
    echo "   ✓ Dropped\n\n";

    // Create the new function with correct types
    echo "2. Creating new function...\n";

    $sql = "
CREATE OR REPLACE FUNCTION multas_reglamentos.recaudadora_dderechoslic(
    p_licencia INTEGER DEFAULT NULL
)
RETURNS TABLE (
    licencia INTEGER,
    id_licencia INTEGER,
    propietario CHARACTER(80),
    actividad CHARACTER(130),
    domicilio CHARACTER(50),
    axo SMALLINT,
    derechos NUMERIC,
    recargos NUMERIC,
    multas NUMERIC,
    total_licencia NUMERIC,
    pagado TEXT
)
LANGUAGE plpgsql
AS \$\$
BEGIN
    RETURN QUERY
    SELECT
        l.licencia,
        l.id_licencia,
        l.propietario,
        l.actividad,
        l.domicilio,
        d.axo,
        d.derechos,
        d.recargos,
        COALESCE(s.multas, 0) AS multas,
        s.total AS total_licencia,
        CASE WHEN d.cvepago > 0 THEN 'Sí' ELSE 'No' END AS pagado
    FROM catastro_gdl.licencias l
    JOIN catastro_gdl.saldos_lic s ON l.id_licencia = s.id_licencia
    LEFT JOIN catastro_gdl.detsal_lic d ON l.id_licencia = d.id_licencia
    WHERE
        (p_licencia IS NULL OR l.licencia = p_licencia)
        AND l.licencia > 0
        AND s.derechos > 0
        AND (d.derechos IS NULL OR d.derechos > 0)
    ORDER BY l.licencia, d.axo DESC;
END;
\$\$;
";

    $pdo->exec($sql);
    echo "   ✓ Created\n\n";

    // Test the function
    echo "3. Testing with licencia 14862...\n";

    $stmt = $pdo->query("SELECT * FROM multas_reglamentos.recaudadora_dderechoslic(14862) LIMIT 3");
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($results) > 0) {
        echo "   ✓ Test successful!\n";
        echo "   Found " . count($results) . " records\n\n";

        $first = $results[0];
        echo "   Sample data:\n";
        echo "   - Licencia: {$first['licencia']}\n";
        echo "   - Propietario: " . trim($first['propietario']) . "\n";
        echo "   - Total: $" . number_format($first['total_licencia'], 2) . "\n";
        echo "   - Pagado: {$first['pagado']}\n";
    } else {
        echo "   ! No results returned\n";
    }

    echo "\n✓✓✓ SP Fixed successfully! ✓✓✓\n";

} catch (Exception $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
