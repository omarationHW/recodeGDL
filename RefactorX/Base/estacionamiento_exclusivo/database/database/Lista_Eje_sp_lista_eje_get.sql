-- Stored Procedure: sp_lista_eje_get
-- Tipo: Catalog
-- Descripción: Obtiene la lista de ejecutores entre dos recaudadoras (id_rec)
-- Generado para formulario: Lista_Eje
-- Fecha: 2025-08-27 20:45:22

CREATE OR REPLACE FUNCTION sp_lista_eje_get(p_rec integer, p_rec1 integer)
RETURNS TABLE (
    id_ejecutor integer,
    cve_eje integer,
    ini_rfc varchar(4),
    fec_rfc date,
    hom_rfc varchar(3),
    nombre varchar(60),
    id_rec smallint,
    categoria varchar(60),
    observacion varchar(60),
    oficio varchar(14),
    fecinic date,
    fecterm date,
    vigencia varchar(1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_ejecutor, cve_eje, ini_rfc, fec_rfc, hom_rfc, nombre, id_rec, categoria, observacion, oficio, fecinic, fecterm, vigencia
    FROM ta_15_ejecutores
    WHERE id_rec >= p_rec AND id_rec <= p_rec1
    ORDER BY id_rec, cve_eje;
END;
$$ LANGUAGE plpgsql;