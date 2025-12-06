-- Stored Procedure: sp_catalogo_secciones
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de secciones de mercado.
-- Generado para formulario: AltaPagos
-- Fecha: 2025-08-26 20:25:40
-- Corregido: 2025-11-27 - Usa ta_11_cuo_locales en lugar de ta_11_secciones

CREATE OR REPLACE FUNCTION sp_catalogo_secciones()
RETURNS TABLE(
    clave character varying,
    descripcion character varying
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        l.seccion::VARCHAR as clave,
        CASE l.seccion
            WHEN '01' THEN 'SECCION 01'
            WHEN '02' THEN 'SECCION 02'
            WHEN 'EA' THEN 'ENERGIA ALUMBRADO'
            WHEN 'PS' THEN 'PLAZAS Y SECTORES'
            WHEN 'SS' THEN 'SOBRE SUELO'
            WHEN 'T1' THEN 'TIPO 1'
            WHEN 'T2' THEN 'TIPO 2'
            ELSE l.seccion::VARCHAR
        END as descripcion
    FROM public.ta_11_cuo_locales l
    WHERE l.seccion IS NOT NULL
    ORDER BY clave;
END;
$$;