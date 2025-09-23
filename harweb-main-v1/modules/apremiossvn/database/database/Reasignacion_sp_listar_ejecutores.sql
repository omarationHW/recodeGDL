-- Stored Procedure: sp_listar_ejecutores
-- Tipo: Catalog
-- Descripción: Devuelve la lista de ejecutores activos entre dos recaudadoras.
-- Generado para formulario: Reasignacion
-- Fecha: 2025-08-27 14:23:03

CREATE OR REPLACE FUNCTION sp_listar_ejecutores(
    p_id_rec_min INTEGER,
    p_id_rec_max INTEGER
) RETURNS TABLE (
    id_ejecutor INTEGER,
    cve_eje INTEGER,
    ini_rfc VARCHAR,
    fec_rfc DATE,
    hom_rfc VARCHAR,
    nombre VARCHAR,
    id_rec INTEGER,
    categoria VARCHAR,
    observacion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_ejecutor, cve_eje, ini_rfc, fec_rfc, hom_rfc, nombre, id_rec, categoria, observacion
    FROM ta_15_ejecutores
    WHERE id_rec >= p_id_rec_min AND id_rec <= p_id_rec_max AND oficio <> ''
    ORDER BY id_rec, cve_eje;
END;
$$ LANGUAGE plpgsql;