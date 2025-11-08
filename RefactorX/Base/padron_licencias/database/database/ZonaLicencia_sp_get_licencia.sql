-- Stored Procedure: sp_get_licencia
-- Tipo: Catalog
-- Descripción: Obtiene los datos de una licencia por número
-- Generado para formulario: ZonaLicencia
-- Fecha: 2025-08-27 19:54:46

CREATE OR REPLACE FUNCTION sp_get_licencia(p_licencia INTEGER)
RETURNS TABLE(id_licencia INTEGER, licencia INTEGER, empresa INTEGER, recaud SMALLINT, id_giro INTEGER, x FLOAT, y FLOAT, zona SMALLINT, subzona SMALLINT, tipo_registro VARCHAR, actividad VARCHAR, cvecuenta INTEGER, fecha_otorgamiento DATE, propietario VARCHAR, rfc VARCHAR, curp VARCHAR, domicilio VARCHAR, numext_prop INTEGER, numint_prop VARCHAR, colonia_prop VARCHAR, telefono_prop VARCHAR, email VARCHAR, cvecalle INTEGER, ubicacion VARCHAR, numext_ubic INTEGER, letraext_ubic VARCHAR, numint_ubic VARCHAR, letrain_ubic VARCHAR, colonia_ubic VARCHAR, sup_construida FLOAT, sup_autorizada FLOAT, num_cajones SMALLINT, num_empleados SMALLINT, aforo SMALLINT, inversion NUMERIC, rhorario VARCHAR, fecha_consejo DATE, bloqueado SMALLINT, asiento SMALLINT, vigente VARCHAR, fecha_baja DATE, axo_baja INTEGER, folio_baja INTEGER, espubic VARCHAR, base_impuesto NUMERIC) AS $$
BEGIN
  RETURN QUERY
  SELECT * FROM licencias WHERE licencia = p_licencia;
END;
$$ LANGUAGE plpgsql;