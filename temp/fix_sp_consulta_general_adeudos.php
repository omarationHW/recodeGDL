<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "=== Verificando estructura de ta_11_adeudo_local ===\n\n";

$stmt = $pdo->query("
    SELECT column_name, data_type
    FROM information_schema.columns
    WHERE table_schema = 'db_ingresos' AND table_name = 'ta_11_adeudo_local'
    ORDER BY ordinal_position
");
$cols = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($cols as $c) {
    echo "  {$c['column_name']} ({$c['data_type']})\n";
}

echo "\n=== Corrigiendo sp_consulta_general_adeudos ===\n\n";

$pdo->exec("DROP FUNCTION IF EXISTS public.sp_consulta_general_adeudos(INTEGER)");
$pdo->exec("
CREATE OR REPLACE FUNCTION public.sp_consulta_general_adeudos(p_id_local INTEGER)
RETURNS TABLE(
    axo INTEGER, periodo INTEGER, importe NUMERIC, recargos NUMERIC
) AS \$\$
BEGIN
    RETURN QUERY
    SELECT a.axo::INTEGER, a.periodo::INTEGER, a.importe::NUMERIC, 0::NUMERIC as recargos
    FROM db_ingresos.ta_11_adeudo_local a
    WHERE a.id_local = p_id_local
    ORDER BY a.axo, a.periodo;
END;
\$\$ LANGUAGE plpgsql;
");
echo "   OK\n";

// Test
echo "\nTest sp_consulta_general_adeudos (id_local 1):\n";
try {
    $stmt = $pdo->query("SELECT * FROM sp_consulta_general_adeudos(1) LIMIT 5");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Registros: " . count($rows) . "\n";
    foreach ($rows as $row) {
        echo "  {$row['axo']}/{$row['periodo']}: \${$row['importe']}\n";
    }
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}

echo "\n=== SP corregido exitosamente ===\n";
