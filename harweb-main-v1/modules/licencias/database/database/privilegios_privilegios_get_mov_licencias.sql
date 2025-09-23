-- Stored Procedure: privilegios_get_mov_licencias
-- Tipo: Report
-- Descripción: Obtiene movimientos de licencias por usuario y rango de fechas
-- Generado para formulario: privilegios
-- Fecha: 2025-08-26 17:28:26

CREATE OR REPLACE FUNCTION privilegios_get_mov_licencias(p_usuario TEXT, p_fechaini DATE, p_fechafin DATE)
RETURNS TABLE(
  id INTEGER, uid INTEGER, username TEXT, ttyin TEXT, ttyout TEXT, ttyerr TEXT, cwd TEXT, hostname TEXT, time TIMESTAMP, event TEXT, id_licencia INTEGER, licencia INTEGER, empresa INTEGER, recaud SMALLINT, id_giro INTEGER, x FLOAT, y FLOAT, zona SMALLINT, subzona SMALLINT, tipo_registro TEXT, actividad TEXT, cvecuenta INTEGER, fecha_otorgamiento DATE, propietario TEXT, rfc TEXT, curp TEXT, domicilio TEXT, numext_prop INTEGER, numint_prop TEXT, colonia_prop TEXT, telefono_prop TEXT, email TEXT, cvecalle INTEGER, ubicacion TEXT, numext_ubic INTEGER, letraext_ubic TEXT, numint_ubic TEXT, letraint_ubic TEXT, colonia_ubic TEXT, sup_construida FLOAT, sup_autorizada FLOAT, num_cajones SMALLINT, num_empleados SMALLINT, aforo SMALLINT, inversion NUMERIC, rhorario TEXT, fecha_consejo DATE, bloqueado SMALLINT, asiento SMALLINT, vigente TEXT, fecha_baja DATE, axo_baja INTEGER, folio_baja INTEGER, espubic TEXT, base_impuesto NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT * FROM get_sysbacklcs(p_usuario, p_fechaini, p_fechafin);
END;
$$ LANGUAGE plpgsql;