-- Stored Procedure: sp_ejecutores_buscar_nombre
-- Tipo: Catalog
-- Descripción: Busca ejecutores activos por nombre (búsqueda parcial, insensible a mayúsculas/minúsculas).
-- Generado para formulario: Ejecutores
-- Fecha: 2025-08-27 13:44:05

CREATE OR REPLACE FUNCTION sp_ejecutores_buscar_nombre(p_nombre VARCHAR)
RETURNS TABLE (
    id_ejecutor INTEGER,
    cve_eje INTEGER,
    ini_rfc CHAR(4),
    fec_rfc DATE,
    hom_rfc CHAR(3),
    nombre VARCHAR(60),
    id_rec SMALLINT,
    categoria VARCHAR(60),
    observacion VARCHAR(60)
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_ejecutor, cve_eje, ini_rfc, fec_rfc, hom_rfc, nombre, id_rec, categoria, observacion
    FROM ta_15_ejecutores
    WHERE oficio IS NOT NULL AND oficio <> '' AND vigencia = 'A'
      AND unaccent(upper(nombre)) LIKE unaccent(upper('%' || p_nombre || '%'))
    ORDER BY cve_eje;
END;
$$ LANGUAGE plpgsql;