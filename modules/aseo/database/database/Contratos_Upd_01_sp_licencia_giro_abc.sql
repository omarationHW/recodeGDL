-- Stored Procedure: sp_licencia_giro_abc
-- Tipo: CRUD
-- Descripción: Aplica acción sobre relación licencia-giro/contrato
-- Generado para formulario: Contratos_Upd_01
-- Fecha: 2025-08-27 14:24:09

CREATE OR REPLACE FUNCTION sp_licencia_giro_abc(opc varchar, licencia_giro integer, control_contrato integer) RETURNS TABLE (status integer, leyenda varchar) AS $$
BEGIN
  IF opc = 'A' THEN
    -- Activar/Re-Activar
    INSERT INTO ta_16_rel_licgiro (id, num_licencia, control_contrato, vigencia)
    VALUES (DEFAULT, licencia_giro, control_contrato, 'V')
    ON CONFLICT (num_licencia, control_contrato) DO UPDATE SET vigencia = 'V';
    RETURN QUERY SELECT 0, 'Licencia activada o reactivada';
  ELSIF opc = 'D' THEN
    -- Desligar/Eliminar
    DELETE FROM ta_16_rel_licgiro WHERE num_licencia = licencia_giro AND control_contrato = control_contrato;
    RETURN QUERY SELECT 0, 'Licencia desligada/eliminada';
  ELSIF opc = 'C' THEN
    -- Cancelar
    UPDATE ta_16_rel_licgiro SET vigencia = 'C' WHERE num_licencia = licencia_giro AND control_contrato = control_contrato;
    RETURN QUERY SELECT 0, 'Licencia cancelada';
  ELSE
    RETURN QUERY SELECT 1, 'Opción no válida';
  END IF;
END; $$ LANGUAGE plpgsql;