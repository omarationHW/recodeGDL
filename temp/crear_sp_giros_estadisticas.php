<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "CREAR SP: consulta_giros_estadisticas\n";
echo "========================================\n\n";

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$database", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa\n\n";

    // SP para estadísticas de giros
    $sp = "
CREATE OR REPLACE FUNCTION comun.consulta_giros_estadisticas()
RETURNS TABLE(
    total BIGINT,
    vigentes BIGINT,
    licencias BIGINT,
    anuncios BIGINT
) AS \$\$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(*)::BIGINT AS total,
        COUNT(CASE WHEN vigente = 'V' THEN 1 END)::BIGINT AS vigentes,
        COUNT(CASE WHEN tipo = 'L' AND vigente = 'V' THEN 1 END)::BIGINT AS licencias,
        COUNT(CASE WHEN tipo = 'A' AND vigente = 'V' THEN 1 END)::BIGINT AS anuncios
    FROM comun.c_giros;
END;
\$\$ LANGUAGE plpgsql;
    ";

    echo "Creando SP: comun.consulta_giros_estadisticas()\n\n";
    $pdo->exec($sp);
    echo "✅ SP creado exitosamente\n\n";

    // Test del SP
    echo "========================================\n";
    echo "TEST DEL SP\n";
    echo "========================================\n\n";

    $start = microtime(true);
    $stmt = $pdo->query("SELECT * FROM comun.consulta_giros_estadisticas()");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    $duration = round((microtime(true) - $start) * 1000, 2);

    echo "Resultado:\n";
    foreach ($result as $key => $value) {
        echo sprintf("  %-15s: %s\n", $key, number_format($value));
    }
    echo "\n⏱ Tiempo: {$duration}ms\n\n";

    echo "✅ Tests completados\n";

} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
