-- Stored Procedure: sp_ejecutores_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo ejecutor
-- Generado para formulario: ABCEjec
-- Fecha: 2025-08-27 13:29:40

CREATE OR REPLACE FUNCTION sp_ejecutores_create(
  p_cve_eje integer,
  p_ini_rfc varchar(4),
  p_fec_rfc date,
  p_hom_rfc varchar(3),
  p_nombre varchar(60),
  p_id_rec smallint,
  p_oficio varchar(14),
  p_fecinic date,
  p_fecterm date
) RETURNS TABLE (result text) AS $$
DECLARE
  existe integer;
BEGIN
  SELECT COUNT(*) INTO existe FROM ta_15_ejecutores WHERE cve_eje = p_cve_eje AND id_rec = p_id_rec;
  IF existe > 0 THEN
    RETURN QUERY SELECT 'Ya existe ejecutor con ese número en la recaudadora';
    RETURN;
  END IF;
  INSERT INTO ta_15_ejecutores (
    cve_eje, ini_rfc, fec_rfc, hom_rfc, nombre, id_rec, oficio, fecinic, fecterm, vigencia
  ) VALUES (
    p_cve_eje, p_ini_rfc, p_fec_rfc, p_hom_rfc, p_nombre, p_id_rec, p_oficio, p_fecinic, p_fecterm, 'A'
  );
  RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;