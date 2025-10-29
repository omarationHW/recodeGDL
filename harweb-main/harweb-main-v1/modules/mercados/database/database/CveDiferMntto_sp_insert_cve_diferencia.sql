-- Stored Procedure: sp_insert_cve_diferencia
-- Tipo: CRUD
-- Descripción: Inserta una nueva clave de diferencia en ta_11_catalogo_dif
-- Generado para formulario: CveDiferMntto
-- Fecha: 2025-08-26 23:41:20

CREATE OR REPLACE FUNCTION sp_insert_cve_diferencia(
    p_clave_diferencia integer,
    p_descripcion text,
    p_cuenta_ingreso integer,
    p_id_usuario integer
) RETURNS TABLE(success boolean, msg text) AS $$
DECLARE
    existe integer;
BEGIN
    SELECT COUNT(*) INTO existe FROM ta_11_catalogo_dif WHERE clave_diferencia = p_clave_diferencia;
    IF existe > 0 THEN
        RETURN QUERY SELECT false, 'La clave de diferencia ya existe';
        RETURN;
    END IF;
    INSERT INTO ta_11_catalogo_dif (clave_diferencia, descripcion, cuenta_ingreso, fecha_actual, id_usuario)
    VALUES (p_clave_diferencia, UPPER(p_descripcion), p_cuenta_ingreso, NOW(), p_id_usuario);
    RETURN QUERY SELECT true, 'Clave de diferencia insertada correctamente';
END;
$$ LANGUAGE plpgsql;