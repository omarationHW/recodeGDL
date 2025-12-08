-- =============================================================================
-- STORED PROCEDURE: report_folios_cancelados
-- Base: estacionamiento_publico
-- Esquema: public
-- Formulario: SolicRepFoliosPublicos.vue
-- Descripcion: Devuelve los folios cancelados para una fecha y clave de infraccion
-- Fecha: 2025-12-07
-- =============================================================================

-- Conectar a la base correcta
\c estacionamiento_publico

DROP FUNCTION IF EXISTS public.report_folios_cancelados(integer, date);

CREATE OR REPLACE FUNCTION public.report_folios_cancelados(p_cveinf integer, p_fechora date)
RETURNS TABLE (
    descrip varchar(20),
    fecha_movto date,
    axo smallint,
    folio integer,
    placa varchar(10),
    fecha_folio date,
    estado smallint,
    infraccion smallint,
    tarifa numeric(12,2)
) AS $$
BEGIN
    IF p_cveinf = 0 THEN
        -- Todas las infracciones - Cancelados (codigo_movto = 3 o cve_mov = 'C')
        RETURN QUERY
        SELECT
            'Cancelado'::varchar(20) AS descrip,
            a.fecha_baja::date AS fecha_movto,
            a.axo,
            a.folio,
            a.placa,
            a.fecha_folio,
            a.estado,
            a.infraccion,
            COALESCE(b.tarifa, 0::numeric) AS tarifa
        FROM ta14_folios_histo a
        LEFT JOIN ta14_tarifas b ON a.infraccion = b.num_clave
            AND a.fecha_folio BETWEEN b.fecha_inicial AND b.fecha_fin
        WHERE a.fecha_baja::date = p_fechora
          AND (a.codigo_movto = 3 OR a.cve_mov = 'C')
        ORDER BY a.axo, a.folio;
    ELSE
        -- Infraccion especifica
        RETURN QUERY
        SELECT
            'Cancelado'::varchar(20) AS descrip,
            a.fecha_baja::date AS fecha_movto,
            a.axo,
            a.folio,
            a.placa,
            a.fecha_folio,
            a.estado,
            a.infraccion,
            COALESCE(b.tarifa, 0::numeric) AS tarifa
        FROM ta14_folios_histo a
        LEFT JOIN ta14_tarifas b ON a.infraccion = b.num_clave
            AND a.fecha_folio BETWEEN b.fecha_inicial AND b.fecha_fin
        WHERE a.fecha_baja::date = p_fechora
          AND (a.codigo_movto = 3 OR a.cve_mov = 'C')
          AND a.infraccion = p_cveinf
        ORDER BY a.axo, a.folio;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Verificar creacion
SELECT routine_name, routine_schema
FROM information_schema.routines
WHERE routine_name = 'report_folios_cancelados';

-- =============================================================================
-- FIN STORED PROCEDURE
-- =============================================================================
