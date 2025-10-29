-- Stored Procedure: sp_contratos_actualizar_periodo_obligacion
-- Tipo: CRUD
-- Descripción: Actualiza el periodo de inicio de obligación de un contrato, registra el documento y descripción en el histórico.
-- Generado para formulario: Contratos_Upd_Periodo
-- Fecha: 2025-08-27 14:27:57

CREATE OR REPLACE FUNCTION sp_contratos_actualizar_periodo_obligacion(
    p_control_contrato INTEGER,
    p_anio INTEGER,
    p_mes INTEGER,
    p_documento VARCHAR,
    p_descripcion VARCHAR,
    p_usuario INTEGER
) RETURNS TABLE(status INTEGER, leyenda VARCHAR) AS $$
DECLARE
    v_fecha DATE;
    v_old_fecha DATE;
    v_count INTEGER;
BEGIN
    -- Validaciones
    IF p_documento IS NULL OR length(trim(p_documento)) = 0 THEN
        RETURN QUERY SELECT 1, 'Falta documento que avale el cambio';
        RETURN;
    END IF;
    v_fecha := make_date(p_anio, p_mes, 1);
    SELECT aso_mes_oblig INTO v_old_fecha FROM ta_16_contratos WHERE control_contrato = p_control_contrato;
    IF v_old_fecha IS NULL THEN
        RETURN QUERY SELECT 2, 'Contrato no encontrado';
        RETURN;
    END IF;
    IF v_fecha = v_old_fecha THEN
        RETURN QUERY SELECT 3, 'El periodo es igual al actual, no hay cambios';
        RETURN;
    END IF;
    -- Actualización
    UPDATE ta_16_contratos
    SET aso_mes_oblig = v_fecha,
        cve = 'C',
        usuario = p_usuario
    WHERE control_contrato = p_control_contrato;
    -- Insertar en histórico
    INSERT INTO ta_16_contratos_h (control, control_contrato, documento, descripcion, id_usuario, fecha_movto)
    VALUES (DEFAULT, p_control_contrato, p_documento, p_descripcion, p_usuario, now());
    RETURN QUERY SELECT 0, 'Periodo de inicio de obligación actualizado correctamente';
END;
$$ LANGUAGE plpgsql;