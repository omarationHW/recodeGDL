<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "=== Corrigiendo sp_consulta_general_buscar (sin JOIN) ===\n\n";

$pdo->exec("DROP FUNCTION IF EXISTS public.sp_consulta_general_buscar(INTEGER, INTEGER, INTEGER, VARCHAR, INTEGER, VARCHAR, VARCHAR)");
$pdo->exec("
CREATE OR REPLACE FUNCTION public.sp_consulta_general_buscar(
    p_oficina INTEGER, p_num_mercado INTEGER, p_categoria INTEGER, p_seccion VARCHAR,
    p_local INTEGER, p_letra_local VARCHAR, p_bloque VARCHAR
)
RETURNS TABLE(
    id_local INTEGER, nombre VARCHAR, arrendatario VARCHAR, giro VARCHAR,
    superficie NUMERIC, vigencia VARCHAR, fecha_alta DATE, fecha_baja DATE,
    usuario VARCHAR, bloqueo VARCHAR, observacion VARCHAR, nombre_mercado VARCHAR
) AS \$\$
BEGIN
    RETURN QUERY
    SELECT l.id_local::INTEGER, l.nombre::VARCHAR, l.arrendatario::VARCHAR, l.giro::VARCHAR,
           l.superficie::NUMERIC, l.vigencia::VARCHAR, l.fecha_alta::DATE, l.fecha_baja::DATE,
           l.id_usuario::VARCHAR as usuario, l.bloqueo::VARCHAR, l.observacion::VARCHAR,
           ('Mercado ' || l.num_mercado::VARCHAR)::VARCHAR as nombre_mercado
    FROM comun.ta_11_locales l
    WHERE l.oficina = p_oficina AND l.num_mercado = p_num_mercado AND l.categoria = p_categoria
      AND l.seccion = p_seccion AND l.local = p_local
      AND (p_letra_local IS NULL OR l.letra_local = p_letra_local)
      AND (p_bloque IS NULL OR l.bloque = p_bloque)
    ORDER BY l.id_local;
END;
\$\$ LANGUAGE plpgsql;
");
echo "   OK\n";

// Test
echo "\nTest sp_consulta_general_buscar (oficina 1, mercado 34, seccion SS, local 1):\n";
try {
    $stmt = $pdo->query("SELECT * FROM sp_consulta_general_buscar(1, 34, 1, 'SS', 1, NULL, NULL) LIMIT 3");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Registros: " . count($rows) . "\n";
    foreach ($rows as $row) {
        echo "  Local {$row['id_local']}: {$row['nombre']} - {$row['arrendatario']}\n";
    }
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}

// Test adeudos
echo "\nTest sp_consulta_general_adeudos:\n";
try {
    $stmt = $pdo->query("SELECT * FROM sp_consulta_general_adeudos(1) LIMIT 3");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Registros: " . count($rows) . "\n";
    foreach ($rows as $row) {
        echo "  {$row['axo']}/{$row['periodo']}: \${$row['importe']} + \${$row['recargos']}\n";
    }
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}

// Test pagos
echo "\nTest sp_consulta_general_pagos:\n";
try {
    $stmt = $pdo->query("SELECT * FROM sp_consulta_general_pagos(1) LIMIT 3");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Registros: " . count($rows) . "\n";
    foreach ($rows as $row) {
        echo "  {$row['axo']}/{$row['periodo']}: \${$row['importe_pago']} - {$row['fecha_pago']}\n";
    }
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}

echo "\n=== SP corregido exitosamente ===\n";
