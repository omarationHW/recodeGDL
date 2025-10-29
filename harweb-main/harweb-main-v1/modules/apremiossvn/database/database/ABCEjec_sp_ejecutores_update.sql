-- Stored Procedure: sp_ejecutores_update
-- Tipo: CRUD
-- Descripción: Actualiza los datos de un ejecutor
-- Generado para formulario: ABCEjec
-- Fecha: 2025-08-27 13:29:40

CREATE OR REPLACE FUNCTION sp_ejecutores_update(
  p_cve_eje integer,
  p_id_rec smallint,
  p_ini_rfc varchar(4),
  p_fec_rfc date,
  p_hom_rfc varchar(3),
  p_nombre varchar(60),
  p_oficio varchar(14),
  p_fecinic date,
  p_fecterm date
) RETURNS TABLE (result text) AS $$
BEGIN
  UPDATE ta_15_ejecutores
  SET ini_rfc = p_ini_rfc,
      fec_rfc = p_fec_rfc,
      hom_rfc = p_hom_rfc,
      nombre = p_nombre,
      oficio = p_oficio,
      fecinic = p_fecinic,
      fecterm = p_fecterm,
      vigencia = 'A'
  WHERE cve_eje = p_cve_eje AND id_rec = p_id_rec;
  IF FOUND THEN
    RETURN QUERY SELECT 'OK';
  ELSE
    RETURN QUERY SELECT 'No existe ejecutor';
  END IF;
END;
$$ LANGUAGE plpgsql;