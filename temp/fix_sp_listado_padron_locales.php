<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "Corrigiendo sp_listado_padron_locales...\n";

$pdo->exec("DROP FUNCTION IF EXISTS public.sp_listado_padron_locales(INTEGER, INTEGER)");

$pdo->exec("
CREATE OR REPLACE FUNCTION public.sp_listado_padron_locales(
    p_oficina INTEGER,
    p_mercado INTEGER
)
RETURNS TABLE(
    id_local INTEGER,
    oficina INTEGER,
    num_mercado INTEGER,
    categoria INTEGER,
    seccion VARCHAR,
    local INTEGER,
    letra_local VARCHAR,
    bloque VARCHAR,
    nombre VARCHAR,
    superficie NUMERIC,
    renta NUMERIC,
    vigencia VARCHAR
) AS \$\$
BEGIN
    RETURN QUERY
    SELECT
        l.id_local::INTEGER,
        l.oficina::INTEGER,
        l.num_mercado::INTEGER,
        l.categoria::INTEGER,
        l.seccion::VARCHAR,
        l.local::INTEGER,
        l.letra_local::VARCHAR,
        l.bloque::VARCHAR,
        l.nombre::VARCHAR,
        l.superficie::NUMERIC,
        COALESCE(c.importe_cuota, 0)::NUMERIC as renta,
        l.vigencia::VARCHAR
    FROM comun.ta_11_locales l
    LEFT JOIN db_ingresos.ta_11_cuo_locales c ON l.clave_cuota = c.clave_cuota
    WHERE l.oficina = p_oficina
      AND l.num_mercado = p_mercado
    ORDER BY l.seccion, l.local, l.letra_local;
END;
\$\$ LANGUAGE plpgsql;
");

echo "SP corregido exitosamente\n";

// Test
echo "\n=== Test con oficina 1, mercado 34 ===\n";
$stmt = $pdo->query("SELECT * FROM sp_listado_padron_locales(1, 34) LIMIT 5");
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "Registros: " . count($rows) . "\n";
foreach ($rows as $row) {
    echo "Local: {$row['local']} | Nombre: " . substr($row['nombre'], 0, 30) . " | Renta: {$row['renta']}\n";
}
