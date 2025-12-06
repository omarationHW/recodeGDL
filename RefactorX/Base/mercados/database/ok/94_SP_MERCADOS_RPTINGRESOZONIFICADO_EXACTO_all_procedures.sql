-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: mercados
-- ESQUEMA: public
-- ============================================
\c mercados;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptIngresoZonificado
-- Generado: 2025-12-04
-- Total SPs: 1
-- ============================================

-- SP 1/1: sp_ingreso_zonificado
-- Tipo: Report
-- Descripción: Obtiene el ingreso global por zona entre dos fechas, sumando ingresos y ajustes.
-- Tablas:
--   - padron_licencias.comun.ta_12_ingreso (ingresos base)
--   - mercados.public.ta_12_importes (detalle de importes)
--   - padron_licencias.comun.ta_11_mercados (catálogo de mercados)
--   - padron_licencias.comun.ta_12_zonas (catálogo de zonas)
--   - padron_licencias.comun.ta_12_ajustes (ajustes a ingresos)
-- --------------------------------------------

DROP FUNCTION IF EXISTS sp_ingreso_zonificado(date, date);

CREATE OR REPLACE FUNCTION sp_ingreso_zonificado(
    p_fecdesde date,
    p_fechasta date
)
RETURNS TABLE (
    id_zona integer,
    zona varchar(50),
    pagado numeric
) AS $$
BEGIN
    RETURN QUERY
    -- Ingresos regulares desde ta_12_ingreso y ta_12_importes
    SELECT
        c.id_zona,
        UPPER(d.zona)::varchar(50) AS zona,
        SUM(b.importe_cta) AS pagado
    FROM padron_licencias.comun.ta_12_ingreso a
    JOIN mercados.public.ta_12_importes b
        ON b.fecing = a.fecing
        AND b.recing = a.recing
        AND b.cajing = a.cajing
        AND b.opcaja = a.opcaja
    JOIN padron_licencias.comun.ta_11_mercados c
        ON c.cuenta_ingreso = b.cta_aplicacion
    JOIN padron_licencias.comun.ta_12_zonas d
        ON d.id_zona = c.id_zona
    WHERE a.fecing BETWEEN p_fecdesde AND p_fechasta
      AND c.num_mercado_nvo NOT IN (99, 214)
      AND ((b.cta_aplicacion BETWEEN 44501 AND 44588) OR (b.cta_aplicacion = 44119))
    GROUP BY c.id_zona, d.zona

    UNION ALL

    -- Ajustes desde ta_12_ajustes
    SELECT
        f.id_zona,
        UPPER(g.zona)::varchar(50) AS zona,
        SUM(e.importe_ajuste) AS pagado
    FROM padron_licencias.comun.ta_11_mercados f
    JOIN padron_licencias.comun.ta_12_zonas g
        ON g.id_zona = f.id_zona
    JOIN padron_licencias.comun.ta_12_ajustes e
        ON e.cta_aplicacion = f.cuenta_ingreso
    WHERE e.fecha_ajuste BETWEEN p_fecdesde AND p_fechasta
      AND ((e.cta_aplicacion BETWEEN 44501 AND 44588) OR (e.cta_aplicacion = 44119))
    GROUP BY f.id_zona, g.zona

    ORDER BY id_zona;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FIN DE SCRIPT
-- ============================================
