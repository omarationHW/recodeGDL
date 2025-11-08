-- Stored Procedure: sp_licencias_relacionadas
-- Tipo: CRUD
-- Descripción: Obtiene licencias relacionadas a un contrato
-- Generado para formulario: Contratos_Upd_01
-- Fecha: 2025-08-27 14:24:09

CREATE OR REPLACE FUNCTION sp_licencias_relacionadas(control_contrato integer) RETURNS TABLE (
  num_licencia integer, actividad varchar, propietario varchar
) AS $$
BEGIN
  RETURN QUERY
    SELECT a.num_licencia, b.actividad, b.propietario
    FROM ta_16_rel_licgiro a
    JOIN catastro_gdl."Licencias" b ON b.licencia = a.num_licencia AND b.vigente = 'V'
    WHERE a.control_contrato = control_contrato
    ORDER BY a.num_licencia;
END; $$ LANGUAGE plpgsql;