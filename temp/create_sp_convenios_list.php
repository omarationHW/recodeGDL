<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host={$host};port={$port};dbname={$dbname}", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die("Error: " . $e->getMessage() . "\n");
}

$sql = <<<'SQL'
CREATE OR REPLACE FUNCTION sp_convenios_list(
    p_nombre VARCHAR DEFAULT NULL,
    p_vigencia CHAR DEFAULT NULL
)
RETURNS TABLE (
    id_convenio INTEGER,
    folio INTEGER,
    nombre VARCHAR(60),
    desc_calle VARCHAR(50),
    numero VARCHAR(11),
    metros2 NUMERIC,
    pago_total NUMERIC,
    fecha_firma DATE,
    fecha_vencimiento DATE,
    vigencia CHAR(1),
    estado VARCHAR(20)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id_convenio,
        c.folio,
        c.nombre,
        c.desc_calle,
        c.numero,
        c.metros2,
        c.pago_total,
        c.fecha_firma,
        c.fecha_vencimiento,
        c.vigencia,
        CASE
            WHEN c.vigencia = 'V' THEN 'VIGENTE'
            WHEN c.vigencia = 'C' THEN 'CANCELADO'
            WHEN c.vigencia = 'P' THEN 'PAGADO'
            WHEN c.vigencia = 'B' THEN 'BAJA'
            ELSE 'VIGENTE'
        END::VARCHAR(20) as estado
    FROM ta_17_convenios c
    WHERE (p_nombre IS NULL OR c.nombre ILIKE '%' || p_nombre || '%')
      AND (p_vigencia IS NULL OR c.vigencia = p_vigencia)
    ORDER BY c.id_convenio DESC
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;
SQL;

echo "Creando sp_convenios_list... ";
try {
    $pdo->exec("DROP FUNCTION IF EXISTS sp_convenios_list(varchar, char)");
    $pdo->exec($sql);
    echo "OK\n";
} catch (PDOException $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}

// Probar
echo "\n=== Probando sp_convenios_list() ===\n";
$stmt = $pdo->query("SELECT * FROM sp_convenios_list() LIMIT 5");
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "Registros: " . count($rows) . "\n";
if (count($rows) > 0) {
    print_r($rows[0]);
}
