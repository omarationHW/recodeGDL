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

    // SP para estadísticas
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
        COUNT(*) FILTER (WHERE vigente = 'V')::BIGINT AS vigentes,
        COUNT(*) FILTER (WHERE tipo = 'L')::BIGINT AS licencias,
        COUNT(*) FILTER (WHERE tipo = 'A')::BIGINT AS anuncios
    FROM comun.c_giros;
END;
\$\$ LANGUAGE plpgsql;
    ";

    echo "Creando SP: consulta_giros_estadisticas()\n\n";
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

    echo "Resultado:\n\n";
    foreach ($result as $key => $value) {
        echo sprintf("  %-15s: %s\n", $key, number_format($value));
    }
    echo "\n";
    echo "⏱ Tiempo: {$duration}ms\n";

    if ($duration < 500) {
        echo "✅ EXCELENTE\n";
    } elseif ($duration < 1000) {
        echo "✅ BUENO\n";
    } else {
        echo "⚠️ Puede mejorar\n";
    }

    echo "\n✅ Proceso completado\n";

} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
