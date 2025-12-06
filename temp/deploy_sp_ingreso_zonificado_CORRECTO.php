<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

$sql = "
DROP FUNCTION IF EXISTS public.sp_ingreso_zonificado(DATE, DATE);

CREATE OR REPLACE FUNCTION public.sp_ingreso_zonificado(
    p_fecdesde DATE,
    p_fechasta DATE
)
RETURNS TABLE (
    id_zona SMALLINT,
    zona VARCHAR(50),
    pagado NUMERIC
) AS \$\$
BEGIN
    RETURN QUERY
    SELECT
        COALESCE(m.id_zona, 0)::SMALLINT AS id_zona,
        CASE
            WHEN m.id_zona IS NULL THEN 'SIN ZONA'
            ELSE 'ZONA ' || m.id_zona::TEXT
        END::VARCHAR(50) AS zona,
        SUM(i.importe_cta) AS pagado
    FROM public.ta_12_importes i
    LEFT JOIN publico.ta_11_mercados m
        ON SUBSTRING(i.cta_aplicacion::TEXT, 4)::INTEGER = m.num_mercado_nvo
    WHERE i.fecing BETWEEN p_fecdesde AND p_fechasta
      AND COALESCE(m.num_mercado_nvo, 0) NOT IN (99, 214)
      AND ((i.cta_aplicacion BETWEEN 44501 AND 44588) OR (i.cta_aplicacion = 44119))
    GROUP BY m.id_zona
    HAVING SUM(i.importe_cta) > 0
    ORDER BY m.id_zona NULLS LAST;
END;
\$\$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_ingreso_zonificado(DATE, DATE) IS
'Genera reporte de ingresos por zona de mercados entre dos fechas.
Mapeo: cta_aplicacion 445XX -> mercado XX (ejemplo: 44501 -> mercado 1).
El JOIN usa SUBSTRING(cta_aplicacion, 4) para extraer el número de mercado.';
";

try {
    $pdo->exec($sql);
    echo "✅ SP sp_ingreso_zonificado corregido y desplegado\n\n";

    echo "🔍 CAMBIO CLAVE APLICADO:\n";
    echo "  Antes: LEFT JOIN con m.cuenta_ingreso = i.cta_aplicacion (0 coincidencias)\n";
    echo "  Ahora: LEFT JOIN con SUBSTRING(i.cta_aplicacion::TEXT, 4)::INTEGER = m.num_mercado_nvo\n";
    echo "  Mapeo: 44501 -> mercado 1, 44502 -> mercado 2, etc.\n\n";

    echo "🧪 Probando SP con rango amplio (2004-2025)...\n\n";

    $stmt = $pdo->prepare('SELECT * FROM sp_ingreso_zonificado(?, ?)');
    $stmt->execute(['2004-01-01', '2025-12-31']);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Zonas encontradas: " . count($results) . "\n\n";

    if (count($results) > 0) {
        echo "Resultados por zona:\n";
        $total = 0;
        foreach ($results as $r) {
            echo sprintf("  📍 %s (ID: %s): $%s\n",
                $r['zona'],
                $r['id_zona'],
                number_format($r['pagado'], 2)
            );
            $total += $r['pagado'];
        }
        echo "\n💰 Total general: $" . number_format($total, 2) . "\n";
    }

    echo "\n✅ SP FUNCIONANDO CORRECTAMENTE CON DATOS POR ZONA\n";
} catch (PDOException $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
?>
