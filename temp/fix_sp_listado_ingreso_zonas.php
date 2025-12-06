<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "Corrigiendo sp_listado_ingreso_zonas...\n";

$pdo->exec("DROP FUNCTION IF EXISTS public.sp_listado_ingreso_zonas(DATE, DATE)");

$pdo->exec("
CREATE OR REPLACE FUNCTION public.sp_listado_ingreso_zonas(
    p_fecha_desde DATE,
    p_fecha_hasta DATE
)
RETURNS TABLE(
    id_zona INTEGER,
    zona VARCHAR,
    pagado NUMERIC
) AS \$\$
BEGIN
    RETURN QUERY
    SELECT
        z.id_zona::INTEGER,
        z.zona::VARCHAR,
        COALESCE(SUM(p.importe_pago), 0)::NUMERIC as pagado
    FROM db_ingresos.ta_12_zonas z
    LEFT JOIN comun.ta_11_locales l ON l.zona = z.id_zona
    LEFT JOIN db_ingresos.ta_11_pagos_local p ON p.id_local = l.id_local
        AND p.fecha_pago BETWEEN p_fecha_desde AND p_fecha_hasta
    GROUP BY z.id_zona, z.zona
    ORDER BY z.id_zona;
END;
\$\$ LANGUAGE plpgsql;
");

echo "SP corregido exitosamente\n";

// Test
echo "\n=== Test con fechas 2024 ===\n";
$stmt = $pdo->query("SELECT * FROM sp_listado_ingreso_zonas('2024-01-01', '2024-12-31') LIMIT 10");
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "Zonas encontradas: " . count($rows) . "\n";
foreach ($rows as $row) {
    echo "Zona {$row['id_zona']}: {$row['zona']} | Pagado: \${$row['pagado']}\n";
}
