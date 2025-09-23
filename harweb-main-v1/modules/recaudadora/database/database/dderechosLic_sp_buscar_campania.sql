-- Stored Procedure: sp_buscar_campania
-- Tipo: Catalog
-- Descripción: Busca campañas de descuento vigentes para derechos
-- Generado para formulario: dderechosLic
-- Fecha: 2025-08-26 23:58:23

CREATE OR REPLACE FUNCTION sp_buscar_campania(p_fecha DATE)
RETURNS TABLE(cveautoriza INTEGER, descripcion TEXT, nombre TEXT, porcentajetope INTEGER) AS $$
BEGIN
  RETURN QUERY
    SELECT cveautoriza, descripcion, nombre, porcentajetope
    FROM c_autdescmul
    WHERE vigencia='V' AND (fecha_inicio<=p_fecha AND fecha_fin>=p_fecha);
END;
$$ LANGUAGE plpgsql;