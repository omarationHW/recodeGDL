<?php
// Script para desplegar el SP sp_vencimiento_rec

$dbConfig = [
    'host' => '192.168.6.146',
    'port' => '5432',
    'dbname' => 'mercados',
    'user' => 'refact',
    'password' => 'FF)-BQk2'
];

try {
    $dsn = "pgsql:host={$dbConfig['host']};port={$dbConfig['port']};dbname={$dbConfig['dbname']}";
    $pdo = new PDO($dsn, $dbConfig['user'], $dbConfig['password']);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✓ Conectado a la base de datos\n\n";

    $createSP = <<<'SQL'
CREATE OR REPLACE FUNCTION sp_vencimiento_rec(p_mes integer)
RETURNS TABLE (
    mes smallint,
    fecha_recargos date,
    fecha_descuento date,
    trimestre smallint,
    sabados smallint,
    sabadosacum smallint
) AS $$
BEGIN
    RETURN QUERY
    SELECT mes, fecha_recargos, fecha_descuento, trimestre, sabados, sabadosacum
    FROM public.ta_11_fecha_desc
    WHERE mes = p_mes;
END;
$$ LANGUAGE plpgsql;
SQL;

    $pdo->exec($createSP);

    echo "✓ SP sp_vencimiento_rec desplegado exitosamente\n";

} catch (Exception $e) {
    echo "✗ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
