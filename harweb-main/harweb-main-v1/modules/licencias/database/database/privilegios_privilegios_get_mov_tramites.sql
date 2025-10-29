-- Stored Procedure: privilegios_get_mov_tramites
-- Tipo: Report
-- Descripción: Obtiene movimientos de trámites por usuario y rango de fechas
-- Generado para formulario: privilegios
-- Fecha: 2025-08-26 17:28:26

CREATE OR REPLACE FUNCTION privilegios_get_mov_tramites(p_usuario TEXT, p_fechaini DATE, p_fechafin DATE)
RETURNS TABLE(
  id INTEGER, uid SMALLINT, username TEXT, ttyin TEXT, ttyout TEXT, ttyerr TEXT, cwd TEXT, hostname TEXT, time TIMESTAMP, event TEXT, id_tramite INTEGER, folio INTEGER, tipo_tramite TEXT, id_giro INTEGER, x FLOAT, y FLOAT, zona SMALLINT, subzona SMALLINT, actividad TEXT, cvecuenta INTEGER, recaud SMALLINT, licencia_ref INTEGER, tramita_apoderado TEXT, propietario TEXT, rfc TEXT, curp TEXT, domicilio TEXT, numext_prop INTEGER, numint_prop TEXT, colonia_prop TEXT, telefono_prop TEXT, email TEXT, cvecalle INTEGER, ubicacion TEXT, numext_ubic INTEGER, letraext_ubic TEXT, letraint_ubic TEXT, colonia_ubic TEXT, espubic TEXT, documentos TEXT, sup_construida FLOAT, sup_autorizada FLOAT, num_cajones SMALLINT, num_empleados SMALLINT, aforo SMALLINT, inversion NUMERIC, costo NUMERIC, fecha_consejo DATE, id_fabricante INTEGER, texto_anuncio TEXT, medidas1 FLOAT, medidas2 FLOAT, area_anuncio FLOAT, num_caras SMALLINT, calificacion NUMERIC, usr_califica TEXT, estatus TEXT, id_licencia INTEGER, id_anuncio INTEGER, feccap DATE, capturista TEXT, numint_ubic TEXT, bloqueado SMALLINT, dictamen SMALLINT, observaciones TEXT, rhorario TEXT, descripciontramite TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT t.*, c.descripcion as descripciontramite
  FROM sysbacktram t
  LEFT JOIN c_tipotramite c ON c.id_tipotramite::TEXT = t.tipo_tramite
  WHERE t.username = p_usuario
    AND DATE(t.time) BETWEEN p_fechaini AND p_fechafin;
END;
$$ LANGUAGE plpgsql;