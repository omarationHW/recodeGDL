<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "=== Verificando estructura de tablas de energia ===\n\n";

// Buscar tabla ta_11_energia
echo "Buscando tabla de energia...\n";
$stmt = $pdo->query("
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_name LIKE '%energia%' AND table_name NOT LIKE '%pago%'
    ORDER BY table_schema, table_name
");
$tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($tables as $t) {
    echo "  {$t['table_schema']}.{$t['table_name']}\n";
}

// Verificar columnas de ta_11_energia en comun
echo "\nColumnas de comun.ta_11_energia:\n";
$stmt = $pdo->query("
    SELECT column_name, data_type
    FROM information_schema.columns
    WHERE table_schema = 'comun' AND table_name = 'ta_11_energia'
    ORDER BY ordinal_position
");
$cols = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($cols as $c) {
    echo "  {$c['column_name']} ({$c['data_type']})\n";
}

// Ahora crear los SPs correctos usando la tabla intermedia ta_11_energia
echo "\n=== Corrigiendo SPs para ConsPagosEnergia ===\n\n";

// SP 1: Buscar pagos energia por local (con JOIN correcto)
echo "1. Corrigiendo sp_cons_pagos_energia_por_local...\n";
$pdo->exec("DROP FUNCTION IF EXISTS public.sp_cons_pagos_energia_por_local(INTEGER, INTEGER, INTEGER, VARCHAR, INTEGER, VARCHAR, VARCHAR)");
$pdo->exec("
CREATE OR REPLACE FUNCTION public.sp_cons_pagos_energia_por_local(
    p_oficina INTEGER, p_num_mercado INTEGER, p_categoria INTEGER, p_seccion VARCHAR,
    p_local INTEGER, p_letra_local VARCHAR, p_bloque VARCHAR
)
RETURNS TABLE(
    id_pago_energia INTEGER, id_local INTEGER, oficina INTEGER, num_mercado INTEGER,
    categoria INTEGER, seccion VARCHAR, local INTEGER, letra_local VARCHAR, bloque VARCHAR,
    axo INTEGER, periodo INTEGER, fecha_pago DATE, oficina_pago INTEGER, caja_pago VARCHAR,
    operacion_pago INTEGER, importe_pago NUMERIC, folio VARCHAR, usuario VARCHAR
) AS \$\$
BEGIN
    RETURN QUERY
    SELECT p.id_pago_energia::INTEGER, l.id_local::INTEGER, l.oficina::INTEGER, l.num_mercado::INTEGER,
           l.categoria::INTEGER, l.seccion::VARCHAR, l.local::INTEGER, l.letra_local::VARCHAR, l.bloque::VARCHAR,
           p.axo::INTEGER, p.periodo::INTEGER, p.fecha_pago::DATE, p.oficina_pago::INTEGER, p.caja_pago::VARCHAR,
           p.operacion_pago::INTEGER, p.importe_pago::NUMERIC, p.folio::VARCHAR, p.id_usuario::VARCHAR as usuario
    FROM comun.ta_11_locales l
    JOIN comun.ta_11_energia e ON e.id_local = l.id_local
    JOIN db_ingresos.ta_11_pago_energia p ON p.id_energia = e.id_energia
    WHERE l.oficina = p_oficina AND l.num_mercado = p_num_mercado AND l.categoria = p_categoria
      AND l.seccion = p_seccion AND l.local = p_local
      AND (p_letra_local IS NULL OR l.letra_local = p_letra_local)
      AND (p_bloque IS NULL OR l.bloque = p_bloque)
    ORDER BY p.axo, p.periodo;
END;
\$\$ LANGUAGE plpgsql;
");
echo "   OK\n";

// SP 2: Buscar pagos energia por fecha (con JOIN correcto)
echo "2. Corrigiendo sp_cons_pagos_energia_por_fecha...\n";
$pdo->exec("DROP FUNCTION IF EXISTS public.sp_cons_pagos_energia_por_fecha(DATE, INTEGER, VARCHAR, INTEGER)");
$pdo->exec("
CREATE OR REPLACE FUNCTION public.sp_cons_pagos_energia_por_fecha(
    p_fecha_pago DATE, p_oficina_pago INTEGER, p_caja_pago VARCHAR, p_operacion_pago INTEGER
)
RETURNS TABLE(
    id_pago_energia INTEGER, id_local INTEGER, oficina INTEGER, num_mercado INTEGER,
    categoria INTEGER, seccion VARCHAR, local INTEGER, letra_local VARCHAR, bloque VARCHAR,
    axo INTEGER, periodo INTEGER, fecha_pago DATE, oficina_pago INTEGER, caja_pago VARCHAR,
    operacion_pago INTEGER, importe_pago NUMERIC, folio VARCHAR, usuario VARCHAR
) AS \$\$
BEGIN
    RETURN QUERY
    SELECT p.id_pago_energia::INTEGER, l.id_local::INTEGER, l.oficina::INTEGER, l.num_mercado::INTEGER,
           l.categoria::INTEGER, l.seccion::VARCHAR, l.local::INTEGER, l.letra_local::VARCHAR, l.bloque::VARCHAR,
           p.axo::INTEGER, p.periodo::INTEGER, p.fecha_pago::DATE, p.oficina_pago::INTEGER, p.caja_pago::VARCHAR,
           p.operacion_pago::INTEGER, p.importe_pago::NUMERIC, p.folio::VARCHAR, p.id_usuario::VARCHAR as usuario
    FROM db_ingresos.ta_11_pago_energia p
    JOIN comun.ta_11_energia e ON p.id_energia = e.id_energia
    JOIN comun.ta_11_locales l ON e.id_local = l.id_local
    WHERE p.fecha_pago = p_fecha_pago AND p.oficina_pago = p_oficina_pago
      AND (p_caja_pago IS NULL OR p.caja_pago = p_caja_pago)
      AND (p_operacion_pago IS NULL OR p.operacion_pago = p_operacion_pago)
    ORDER BY p.oficina_pago, p.caja_pago, p.operacion_pago;
END;
\$\$ LANGUAGE plpgsql;
");
echo "   OK\n";

// Tests
echo "\n=== Tests ===\n";

echo "\nTest sp_cons_pagos_energia_por_local (oficina 1, mercado 34, seccion SS, local 1):\n";
try {
    $stmt = $pdo->query("SELECT * FROM sp_cons_pagos_energia_por_local(1, 34, 1, 'SS', 1, NULL, NULL) LIMIT 3");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Registros: " . count($rows) . "\n";
    foreach ($rows as $row) {
        echo "  Pago {$row['id_pago_energia']}: {$row['axo']}/{$row['periodo']} - \${$row['importe_pago']}\n";
    }
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}

echo "\nTest sp_cons_pagos_energia_por_fecha (fecha 2024-01-15, oficina 1):\n";
try {
    $stmt = $pdo->query("SELECT * FROM sp_cons_pagos_energia_por_fecha('2024-01-15', 1, NULL, NULL) LIMIT 3");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Registros: " . count($rows) . "\n";
    foreach ($rows as $row) {
        echo "  Pago {$row['id_pago_energia']}: Local {$row['local']} - \${$row['importe_pago']}\n";
    }
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}

echo "\n=== SPs corregidos exitosamente ===\n";
