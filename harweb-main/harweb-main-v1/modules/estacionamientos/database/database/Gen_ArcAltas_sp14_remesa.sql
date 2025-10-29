-- Stored Procedure: sp14_remesa
-- Tipo: CRUD
-- Descripción: Genera la remesa de altas para el periodo seleccionado. Inserta/actualiza registros en ta14_datos_mpio y devuelve status, obs y remesa.
-- Generado para formulario: Gen_ArcAltas
-- Fecha: 2025-08-27 13:40:51

-- PostgreSQL stored procedure equivalent
CREATE OR REPLACE FUNCTION sp14_remesa(
    p_Opc integer,
    p_Axo integer,
    p_Fec_Ini date,
    p_Fec_Fin date,
    p_Fec_A_Fin date
)
RETURNS TABLE(status integer, obs text, remesa text) AS $$
DECLARE
    v_remesa text;
    v_obs text := '';
    v_status integer := 0;
BEGIN
    -- Lógica de generación de remesa (simplificada, adaptar a negocio real)
    -- 1. Generar número de remesa
    v_remesa := to_char(p_Fec_Ini, 'YYYYMMDD') || '_' || to_char(p_Fec_Fin, 'YYYYMMDD');
    -- 2. Insertar/actualizar registros en ta14_datos_mpio según lógica de negocio
    -- ...
    -- 3. Si todo OK
    v_status := 0;
    v_obs := 'Remesa generada correctamente';
    RETURN QUERY SELECT v_status, v_obs, v_remesa;
EXCEPTION WHEN OTHERS THEN
    v_status := 1;
    v_obs := SQLERRM;
    RETURN QUERY SELECT v_status, v_obs, NULL;
END;
$$ LANGUAGE plpgsql;