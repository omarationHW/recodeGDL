-- =====================================================
-- Fix para SP sp_gfacturacion_datos_get
-- Base: otras_obligaciones
-- Fecha: 2025-11-26
-- Problema: Columnas incorrectas - usaba t34_adeudos (vacía)
-- Solución: Usar t34_pagos que tiene los datos reales
-- =====================================================

DROP FUNCTION IF EXISTS public.sp_gfacturacion_datos_get(character varying, character varying, character varying, integer, integer);

CREATE OR REPLACE FUNCTION public.sp_gfacturacion_datos_get(
    par_tab CHARACTER VARYING,
    par_ade CHARACTER VARYING,
    par_rcgo CHARACTER VARYING,
    par_axo INTEGER,
    par_mes INTEGER
)
RETURNS TABLE(
    control CHARACTER VARYING,
    concesionario CHARACTER VARYING,
    superficie NUMERIC,
    tipo CHARACTER VARYING,
    licencia INTEGER,
    importe NUMERIC,
    status INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- par_ade: 'A' = Adeudos (no pagados), 'B' = Pagados, 'C' = Todos
    -- par_rcgo: 'S' = Incluir recargos, 'N' = Solo importe base
    -- Los datos están en t34_pagos:
    -- - id_stat = 17 = VIGENTE (no pagado)
    -- - id_stat = 18 = CANCELADO
    -- - id_stat = 19 = PAGADO
    -- - id_stat = 21 = PRESCRITO
    -- - fecha_hora_pago IS NULL = no pagado

    RETURN QUERY
    SELECT
        TRIM(d.control)::CHARACTER VARYING AS control,
        TRIM(d.concesionario)::CHARACTER VARYING AS concesionario,
        COALESCE(d.superficie, 0)::NUMERIC AS superficie,
        COALESCE(u.descripcion, 'SIN TIPO')::CHARACTER VARYING AS tipo,
        COALESCE(d.licencia, 0)::INTEGER AS licencia,
        COALESCE(SUM(
            CASE
                WHEN par_rcgo = 'S' THEN p.importe + COALESCE(p.recargo, 0)
                ELSE p.importe
            END
        ), 0)::NUMERIC AS importe,
        0::INTEGER AS status
    FROM t34_datos d
    INNER JOIN t34_pagos p ON d.id_34_datos = p.id_datos
    LEFT JOIN t34_unidades u ON d.cve_tab = u.cve_tab
        AND u.ejercicio = par_axo
    WHERE d.cve_tab = par_tab
      AND EXTRACT(YEAR FROM p.periodo) = par_axo
      AND EXTRACT(MONTH FROM p.periodo) = par_mes
      AND (
        -- Filtro por estado de pago
        (par_ade = 'A' AND p.fecha_hora_pago IS NULL) OR  -- Adeudos (no pagados)
        (par_ade = 'B' AND p.fecha_hora_pago IS NOT NULL) OR  -- Pagados
        (par_ade = 'C')  -- Todos
      )
    GROUP BY d.control, d.concesionario, d.superficie, u.descripcion, d.licencia
    ORDER BY d.control;
END;
$$;

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE 'SP sp_gfacturacion_datos_get corregido exitosamente - usando t34_pagos';
END $$;
