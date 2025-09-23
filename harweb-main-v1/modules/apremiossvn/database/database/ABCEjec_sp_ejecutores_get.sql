-- Stored Procedure: sp_ejecutores_get
-- Tipo: Catalog
-- Descripción: Obtiene un ejecutor específico por clave y recaudadora
-- Generado para formulario: ABCEjec
-- Fecha: 2025-08-27 13:29:40

CREATE OR REPLACE FUNCTION sp_ejecutores_get(p_cve_eje integer, p_id_rec integer)
RETURNS TABLE (
  cve_eje integer,
  ini_rfc varchar(4),
  fec_rfc date,
  hom_rfc varchar(3),
  nombre varchar(60),
  id_rec smallint,
  oficio varchar(14),
  fecinic date,
  fecterm date,
  vigencia char(1)
) AS $$
BEGIN
  RETURN QUERY
    SELECT cve_eje, ini_rfc, fec_rfc, hom_rfc, nombre, id_rec, oficio, fecinic, fecterm, vigencia
    FROM ta_15_ejecutores
    WHERE cve_eje = p_cve_eje AND id_rec = p_id_rec;
END;
$$ LANGUAGE plpgsql;