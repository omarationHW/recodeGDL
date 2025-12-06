<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "Corrigiendo sp_rpt_pagos_locales...\n";
$pdo->exec("DROP FUNCTION IF EXISTS public.sp_rpt_pagos_locales(DATE, DATE, INTEGER)");
$pdo->exec("
CREATE OR REPLACE FUNCTION public.sp_rpt_pagos_locales(
    p_fecha_desde DATE,
    p_fecha_hasta DATE,
    p_oficina INTEGER
)
RETURNS TABLE(
    id_pago_local INTEGER,
    id_local INTEGER,
    fecha_pago DATE,
    oficina_pago INTEGER,
    caja_pago VARCHAR,
    operacion_pago INTEGER,
    axo INTEGER,
    periodo INTEGER,
    importe_pago NUMERIC,
    folio VARCHAR,
    usuario VARCHAR
) AS \$\$
BEGIN
    RETURN QUERY
    SELECT
        p.id_pago_local::INTEGER,
        p.id_local::INTEGER,
        p.fecha_pago::DATE,
        p.oficina_pago::INTEGER,
        p.caja_pago::VARCHAR,
        p.operacion_pago::INTEGER,
        p.axo::INTEGER,
        p.periodo::INTEGER,
        p.importe_pago::NUMERIC,
        p.folio::VARCHAR,
        p.id_usuario::VARCHAR as usuario
    FROM db_ingresos.ta_11_pagos_local p
    JOIN comun.ta_11_locales l ON p.id_local = l.id_local
    WHERE p.fecha_pago BETWEEN p_fecha_desde AND p_fecha_hasta
      AND l.oficina = p_oficina
    ORDER BY p.fecha_pago, p.id_pago_local;
END;
\$\$ LANGUAGE plpgsql;
");
echo "SP corregido\n";

// Test
echo "\n=== Test con oficina 1, fechas 2024 ===\n";
$stmt = $pdo->query("SELECT * FROM sp_rpt_pagos_locales('2024-01-01', '2024-12-31', 1) LIMIT 5");
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "Registros encontrados: " . count($rows) . "\n";
foreach ($rows as $row) {
    echo "Local: {$row['id_local']} | Fecha: {$row['fecha_pago']} | Importe: {$row['importe_pago']}\n";
}
