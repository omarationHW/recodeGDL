-- Stored Procedure: sp16_licenciagiro_abc
-- Tipo: CRUD
-- Descripción: Alta, baja (desligar), o actualización de relación entre licencia y contrato
-- Generado para formulario: Licencias_Relacionadas
-- Fecha: 2025-08-27 14:41:43

-- PostgreSQL version of sp16_LicenciaGiro_ABC
CREATE OR REPLACE FUNCTION sp16_licenciagiro_abc(
    par_opc VARCHAR,
    par_licenciagiro INTEGER,
    par_control_contrato INTEGER,
    par_usuario INTEGER DEFAULT 0
) RETURNS TABLE(status INTEGER, leyenda VARCHAR) AS $$
DECLARE
BEGIN
    IF par_opc = 'D' THEN
        DELETE FROM ta_16_rel_licgiro
        WHERE num_licencia = par_licenciagiro AND control_contrato = par_control_contrato;
        RETURN QUERY SELECT 0 AS status, 'Licencia desligada correctamente' AS leyenda;
    ELSIF par_opc = 'A' THEN
        INSERT INTO ta_16_rel_licgiro (num_licencia, control_contrato, vigencia, usuario)
        VALUES (par_licenciagiro, par_control_contrato, 'V', par_usuario)
        ON CONFLICT (num_licencia, control_contrato) DO UPDATE SET vigencia = 'V', usuario = par_usuario;
        RETURN QUERY SELECT 0 AS status, 'Licencia ligada correctamente' AS leyenda;
    ELSE
        RETURN QUERY SELECT 1 AS status, 'Operación no soportada' AS leyenda;
    END IF;
END;
$$ LANGUAGE plpgsql;