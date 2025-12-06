<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "Creando sp_estadistica_pagos_adeudos...\n";

$pdo->exec("DROP FUNCTION IF EXISTS public.sp_estadistica_pagos_adeudos(INTEGER, INTEGER, INTEGER, DATE, DATE)");

$pdo->exec("
CREATE OR REPLACE FUNCTION public.sp_estadistica_pagos_adeudos(
    p_oficina INTEGER,
    p_axo INTEGER,
    p_mes INTEGER,
    p_fecha_desde DATE,
    p_fecha_hasta DATE
)
RETURNS TABLE(
    num_mercado_nvo INTEGER,
    descripcion VARCHAR,
    localpag INTEGER,
    pagospag NUMERIC,
    periodospag INTEGER,
    localcap INTEGER,
    pagoscap NUMERIC,
    periodoscap INTEGER,
    localade INTEGER,
    pagosade NUMERIC,
    periodosade INTEGER
) AS \$\$
BEGIN
    RETURN QUERY
    WITH mercados_rec AS (
        SELECT m.num_mercado_nvo, m.descripcion
        FROM comun.ta_11_mercados m
        WHERE m.oficina = p_oficina
    ),
    -- Pagos realizados en el periodo
    pagos AS (
        SELECT
            l.num_mercado,
            COUNT(DISTINCT l.id_local) as locales,
            COALESCE(SUM(p.importe_pago), 0) as importe,
            COUNT(p.id_pago_local) as periodos
        FROM comun.ta_11_locales l
        JOIN db_ingresos.ta_11_pagos_local p ON p.id_local = l.id_local
        WHERE l.oficina = p_oficina
          AND p.fecha_pago BETWEEN p_fecha_desde AND p_fecha_hasta
        GROUP BY l.num_mercado
    ),
    -- Adeudos (locales sin pago del periodo actual)
    adeudos AS (
        SELECT
            l.num_mercado,
            COUNT(DISTINCT l.id_local) as locales,
            COALESCE(SUM(a.importe), 0) as importe,
            COUNT(a.id_adeudo_local) as periodos
        FROM comun.ta_11_locales l
        JOIN db_ingresos.ta_11_adeudos_local a ON a.id_local = l.id_local
        WHERE l.oficina = p_oficina
          AND l.vigencia = 'A'
          AND a.axo = p_axo
          AND a.periodo <= p_mes
          AND a.estatus = 'P'
        GROUP BY l.num_mercado
    ),
    -- Capturas del periodo
    capturas AS (
        SELECT
            l.num_mercado,
            COUNT(DISTINCT l.id_local) as locales,
            COALESCE(SUM(c.importe_cuota), 0) as importe,
            COUNT(*) as periodos
        FROM comun.ta_11_locales l
        JOIN db_ingresos.ta_11_cuo_locales c ON l.clave_cuota = c.clave_cuota
        WHERE l.oficina = p_oficina
          AND l.vigencia = 'A'
        GROUP BY l.num_mercado
    )
    SELECT
        mr.num_mercado_nvo::INTEGER,
        mr.descripcion::VARCHAR,
        COALESCE(pg.locales, 0)::INTEGER as localpag,
        COALESCE(pg.importe, 0)::NUMERIC as pagospag,
        COALESCE(pg.periodos, 0)::INTEGER as periodospag,
        COALESCE(cp.locales, 0)::INTEGER as localcap,
        COALESCE(cp.importe, 0)::NUMERIC as pagoscap,
        COALESCE(cp.periodos, 0)::INTEGER as periodoscap,
        COALESCE(ad.locales, 0)::INTEGER as localade,
        COALESCE(ad.importe, 0)::NUMERIC as pagosade,
        COALESCE(ad.periodos, 0)::INTEGER as periodosade
    FROM mercados_rec mr
    LEFT JOIN pagos pg ON pg.num_mercado = mr.num_mercado_nvo
    LEFT JOIN capturas cp ON cp.num_mercado = mr.num_mercado_nvo
    LEFT JOIN adeudos ad ON ad.num_mercado = mr.num_mercado_nvo
    WHERE COALESCE(pg.locales, 0) > 0
       OR COALESCE(cp.locales, 0) > 0
       OR COALESCE(ad.locales, 0) > 0
    ORDER BY mr.num_mercado_nvo;
END;
\$\$ LANGUAGE plpgsql;
");

echo "SP creado exitosamente\n";

// Test
echo "\n=== Test con oficina 1, 2024, mes 6 ===\n";
$stmt = $pdo->query("SELECT * FROM sp_estadistica_pagos_adeudos(1, 2024, 6, '2024-01-01', '2024-06-30') LIMIT 5");
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "Mercados encontrados: " . count($rows) . "\n";
foreach ($rows as $row) {
    echo "Mercado {$row['num_mercado_nvo']}: {$row['descripcion']}\n";
    echo "  Pagados: {$row['localpag']} locales, \${$row['pagospag']}\n";
    echo "  Adeudos: {$row['localade']} locales, \${$row['pagosade']}\n";
}
