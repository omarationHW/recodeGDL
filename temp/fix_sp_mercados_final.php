<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

$sql = "
DROP FUNCTION IF EXISTS public.sp_get_mercados_by_recaudadora(INTEGER);

CREATE OR REPLACE FUNCTION public.sp_get_mercados_by_recaudadora(p_id_rec INTEGER)
RETURNS TABLE(
    oficina SMALLINT,
    num_mercado_nvo SMALLINT,
    descripcion VARCHAR
)
LANGUAGE plpgsql
AS \$\$
BEGIN
    RETURN QUERY
    SELECT
        m.oficina,
        m.num_mercado_nvo,
        m.descripcion
    FROM publico.ta_11_mercados m
    WHERE m.oficina = p_id_rec
    ORDER BY m.num_mercado_nvo;
END;
\$\$;

COMMENT ON FUNCTION public.sp_get_mercados_by_recaudadora(INTEGER) IS
'Obtiene la lista de mercados de una recaudadora específica.';
";

try {
    $pdo->exec($sql);
    echo "✅ SP sp_get_mercados_by_recaudadora corregido y desplegado\n\n";
    
    echo "Probando con recaudadora 1...\n";
    $stmt = $pdo->prepare('SELECT * FROM sp_get_mercados_by_recaudadora(?)');
    $stmt->execute([1]);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Mercados encontrados: " . count($results) . "\n";
    foreach ($results as $i => $r) {
        if ($i < 5) {
            echo "  - Mercado {$r['num_mercado_nvo']}: {$r['descripcion']}\n";
        }
    }
    echo "\n✅ SP FUNCIONANDO CORRECTAMENTE\n";
} catch (PDOException $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
?>
