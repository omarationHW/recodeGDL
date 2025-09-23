-- PostgreSQL stored procedure equivalent for sp14_remesa
-- Asume que la lógica de negocio original está implementada aquí
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
    v_obs text;
    v_status integer := 0;
BEGIN
    -- Ejemplo de lógica (ajustar según reglas de negocio reales)
    v_remesa := 'R' || to_char(now(), 'YYYYMMDDHH24MISS');
    v_obs := 'Remesa generada para el periodo ' || p_Fec_Ini || ' a ' || p_Fec_Fin;
    -- Aquí iría la lógica de inserción/actualización de ta14_datos_mpio
    -- Si ocurre error, setear v_status := 1 y v_obs := mensaje de error
    RETURN QUERY SELECT v_status, v_obs, v_remesa;
END;
$$ LANGUAGE plpgsql;