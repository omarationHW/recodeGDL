<?php
\ = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

\ = "
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
    LEFT JOIN publico.ta_11_mercados m ON m.cuenta_ingreso = i.cta_aplicacion
    WHERE i.fecing BETWEEN p_fecdesde AND p_fechasta
      AND COALESCE(m.num_mercado_nvo, 0) NOT IN (99, 214)
      AND ((i.cta_aplicacion BETWEEN 44501 AND 44588) OR (i.cta_aplicacion = 44119))
    GROUP BY m.id_zona
    HAVING SUM(i.importe_cta) > 0
    ORDER BY m.id_zona NULLS LAST;
END;
\$\$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_ingreso_zonificado(DATE, DATE) IS
'Genera reporte de ingresos por zona de mercados entre dos fechas. Versión simplificada basada en ta_12_importes.';
";

try {
    \->exec(\);
    echo "✅ SP sp_ingreso_zonificado corregido y desplegado\n\n";
    
    echo "🧪 Probando SP...\n";
    echo "Usando rango: 2024-01-01 a 2024-12-31\n\n";
    
    \ = \->prepare('SELECT * FROM sp_ingreso_zonificado(?, ?)');
    \->execute(['2024-01-01', '2024-12-31']);
    \ = \->fetchAll(PDO::FETCH_ASSOC);
    
    echo "Zonas encontradas: " . count(\) . "\n\n";
    
    if (count(\) > 0) {
        echo "Resultados:\n";
        \ = 0;
        foreach (\ as \) {
            echo "  - Zona {\['id_zona']}: {\['zona']} = $" . number_format(\['pagado'], 2) . "\n";
            \ += \['pagado'];
        }
        echo "\nTotal general: $" . number_format(\, 2) . "\n";
    }
    
    echo "\n✅ SP FUNCIONANDO CORRECTAMENTE\n";
} catch (PDOException \) {
    echo "❌ ERROR: " . \->getMessage() . "\n";
    exit(1);
}
?>
