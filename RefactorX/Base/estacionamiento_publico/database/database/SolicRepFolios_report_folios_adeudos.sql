-- =============================================================================
-- STORED PROCEDURE: report_folios_adeudos
-- Base: estacionamiento_publico
-- Esquema: public
-- Formulario: SolicRepFoliosPublicos.vue
-- Descripcion: Devuelve los folios en adeudo para una fecha y clave de infraccion
-- Fecha: 2025-12-07
-- =============================================================================

-- Conectar a la base correcta
\c estacionamiento_publico

DROP FUNCTION IF EXISTS public.report_folios_adeudos(integer, date);

CREATE OR REPLACE FUNCTION public.report_folios_adeudos(p_cveinf integer, p_fechora date)
RETURNS TABLE (
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
        -- Todas las infracciones
        RETURN QUERY
        SELECT a.axo, a.folio, a.placa, a.fecha_folio, a.estado, a.infraccion, b.tarifa
        FROM ta14_folios_adeudo a
        JOIN ta14_tarifas b ON a.infraccion = b.num_clave
            AND a.fecha_folio BETWEEN b.fecha_inicial AND b.fecha_fin
        WHERE a.fecha_folio = p_fechora
        ORDER BY a.axo, a.folio;
    ELSE
        -- Infraccion especifica
        RETURN QUERY
        SELECT a.axo, a.folio, a.placa, a.fecha_folio, a.estado, a.infraccion, b.tarifa
        FROM ta14_folios_adeudo a
        JOIN ta14_tarifas b ON a.infraccion = b.num_clave
            AND a.fecha_folio BETWEEN b.fecha_inicial AND b.fecha_fin
        WHERE a.fecha_folio = p_fechora AND a.infraccion = p_cveinf
        ORDER BY a.axo, a.folio;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Verificar creacion
SELECT routine_name, routine_schema
FROM information_schema.routines
WHERE routine_name = 'report_folios_adeudos';

-- =============================================================================
-- FIN STORED PROCEDURE
-- =============================================================================
