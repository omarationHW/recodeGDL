-- Stored Procedure: sp_catalogo_sectores
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de SECTORES (no confundir con secciones)
-- Generado para formulario: LocalesModif
-- Fecha: 2025-12-05

CREATE OR REPLACE FUNCTION sp_catalogo_sectores()
RETURNS TABLE(
    clave text,
    descripcion text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        l.sector::text as clave,
        CASE l.sector
            WHEN 'L' THEN 'SECTOR L'::text
            WHEN 'J' THEN 'SECTOR J'::text
            WHEN 'H' THEN 'SECTOR H'::text
            WHEN 'R' THEN 'SECTOR R'::text
            WHEN 'E' THEN 'SECTOR E'::text
            WHEN '0' THEN 'SECTOR 0'::text
            ELSE ('SECTOR ' || l.sector)::text
        END as descripcion
    FROM publico.ta_11_locales l
    WHERE l.sector IS NOT NULL
    ORDER BY clave;
END;
$$;
