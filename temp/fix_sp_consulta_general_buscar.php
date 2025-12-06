<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "=== Buscando tabla catalogo_mercados ===\n\n";

$stmt = $pdo->query("
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_name LIKE '%catalogo_mercados%' OR table_name LIKE '%mercados%catalogo%'
    ORDER BY table_schema, table_name
");
$tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($tables as $t) {
    echo "  {$t['table_schema']}.{$t['table_name']}\n";
}

echo "\n=== Corrigiendo sp_consulta_general_buscar ===\n\n";

// Usar db_ingresos si existe ahí, si no, quitar el JOIN
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
           COALESCE(m.nombre, 'Mercado ' || l.num_mercado::VARCHAR)::VARCHAR as nombre_mercado
    FROM comun.ta_11_locales l
    LEFT JOIN db_ingresos.ta_11_catalogo_mercados m ON m.oficina = l.oficina AND m.num_mercado_nvo = l.num_mercado
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
        echo "  Local {$row['id_local']}: {$row['nombre']} - Mercado: {$row['nombre_mercado']}\n";
    }
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}

echo "\n=== SP corregido exitosamente ===\n";
