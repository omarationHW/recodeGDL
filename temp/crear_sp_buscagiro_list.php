<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "CREAR SP: buscagiro_list\n";
echo "========================================\n\n";

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$database", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa\n\n";

    // SP para búsqueda de giros
    $sp = "
CREATE OR REPLACE FUNCTION comun.buscagiro_list(
    p_descripcion VARCHAR DEFAULT NULL,
    p_tipo VARCHAR DEFAULT 'L',
    p_vigente VARCHAR DEFAULT 'V'
)
RETURNS TABLE(
    id_giro INTEGER,
    cod_giro INTEGER,
    descripcion VARCHAR,
    caracteristicas VARCHAR,
    clasificacion VARCHAR,
    tipo VARCHAR,
    vigente VARCHAR,
    costo NUMERIC,
    reglamentada VARCHAR
) AS \$\$
BEGIN
    RETURN QUERY
    SELECT
        cg.id_giro,
        cg.cod_giro,
        TRIM(cg.descripcion)::VARCHAR AS descripcion,
        TRIM(cg.caracteristicas)::VARCHAR AS caracteristicas,
        TRIM(cg.clasificacion)::VARCHAR AS clasificacion,
        TRIM(cg.tipo)::VARCHAR AS tipo,
        TRIM(cg.vigente)::VARCHAR AS vigente,
        0::NUMERIC AS costo,  -- Placeholder, se puede calcular después
        TRIM(cg.reglamentada)::VARCHAR AS reglamentada
    FROM comun.c_giros cg
    WHERE
        (p_descripcion IS NULL OR cg.descripcion ILIKE '%' || p_descripcion || '%')
        AND (p_tipo IS NULL OR cg.tipo = p_tipo)
        AND (p_vigente IS NULL OR cg.vigente = p_vigente)
    ORDER BY cg.descripcion
    LIMIT 1000;  -- Límite de seguridad
END;
\$\$ LANGUAGE plpgsql;
    ";

    echo "Creando SP: comun.buscagiro_list()\n\n";
    $pdo->exec($sp);
    echo "✅ SP creado exitosamente\n\n";

    // Test del SP
    echo "========================================\n";
    echo "TEST DEL SP\n";
    echo "========================================\n\n";

    echo "Test 1: Búsqueda sin filtros (primeros 10)\n";
    $start = microtime(true);
    $stmt = $pdo->query("
        SELECT * FROM comun.buscagiro_list(NULL, 'L', 'V')
        LIMIT 10
    ");
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $duration = round((microtime(true) - $start) * 1000, 2);

    echo "  Resultados: " . count($results) . "\n";
    echo "  ⏱ Tiempo: {$duration}ms\n\n";

    if (count($results) > 0) {
        echo "  Ejemplo:\n";
        $sample = $results[0];
        echo "    ID: {$sample['id_giro']}\n";
        echo "    Descripción: {$sample['descripcion']}\n";
        echo "    Tipo: {$sample['tipo']}\n";
        echo "    Vigente: {$sample['vigente']}\n\n";
    }

    echo "Test 2: Búsqueda con filtro 'comercio'\n";
    $start = microtime(true);
    $stmt = $pdo->query("
        SELECT COUNT(*) FROM comun.buscagiro_list('comercio', 'L', 'V')
    ");
    $count = $stmt->fetchColumn();
    $duration = round((microtime(true) - $start) * 1000, 2);

    echo "  Resultados: " . number_format($count) . "\n";
    echo "  ⏱ Tiempo: {$duration}ms\n\n";

    echo "✅ Tests completados\n";

} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
