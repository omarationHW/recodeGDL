-- Stored Procedure: sp_update_cve_diferencia
-- Tipo: CRUD
-- Descripción: Actualiza una clave de diferencia existente en ta_11_catalogo_dif
-- Generado para formulario: CveDiferMntto
-- Fecha: 2025-08-26 23:41:20

CREATE OR REPLACE FUNCTION sp_update_cve_diferencia(
    p_clave_diferencia integer,
    p_descripcion text,
    p_cuenta_ingreso integer,
    p_id_usuario integer
) RETURNS TABLE(success boolean, msg text) AS $$
DECLARE
    existe integer;
BEGIN
    SELECT COUNT(*) INTO existe FROM ta_11_catalogo_dif WHERE clave_diferencia = p_clave_diferencia;
    IF existe = 0 THEN
        RETURN QUERY SELECT false, 'La clave de diferencia no existe';
        RETURN;
    END IF;
    UPDATE ta_11_catalogo_dif
    SET descripcion = UPPER(p_descripcion),
        cuenta_ingreso = p_cuenta_ingreso,
        fecha_actual = NOW(),
        id_usuario = p_id_usuario
    WHERE clave_diferencia = p_clave_diferencia;
    RETURN QUERY SELECT true, 'Clave de diferencia actualizada correctamente';
END;
$$ LANGUAGE plpgsql;