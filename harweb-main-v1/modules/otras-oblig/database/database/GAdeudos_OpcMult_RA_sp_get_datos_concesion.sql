-- Stored Procedure: sp_get_datos_concesion
-- Tipo: CRUD
-- Descripción: Obtiene los datos generales de la concesión para la tabla y control dados.
-- Generado para formulario: GAdeudos_OpcMult_RA
-- Fecha: 2025-08-28 13:01:07

CREATE OR REPLACE FUNCTION sp_get_datos_concesion(par_tab integer, par_control text)
RETURNS TABLE(
  status integer,
  concepto_status text,
  id_datos integer,
  concesionario text,
  ubicacion text,
  nomcomercial text,
  lugar text,
  obs text,
  adicionales text,
  statusregistro text,
  unidades text,
  categoria text,
  seccion text,
  bloque text,
  sector text,
  superficie numeric,
  fechainicio date,
  fechafin date,
  recaudadora integer,
  zona integer,
  licencia integer,
  giro integer
) AS $$
BEGIN
  RETURN QUERY
  SELECT status, concepto_status, id_datos, concesionario, ubicacion, nomcomercial, lugar, obs, adicionales, statusregistro, unidades, categoria, seccion, bloque, sector, superficie, fechainicio, fechafin, recaudadora, zona, licencia, giro
  FROM cob34_gdatosg_02(par_tab, par_control);
END;
$$ LANGUAGE plpgsql;