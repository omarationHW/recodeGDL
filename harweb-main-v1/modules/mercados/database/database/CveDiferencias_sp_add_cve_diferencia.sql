-- Stored Procedure: sp_add_cve_diferencia
-- Tipo: CRUD
-- Descripción: Agrega una nueva clave de diferencia.
-- Generado para formulario: CveDiferencias
-- Fecha: 2025-08-26 23:39:54

CREATE OR REPLACE FUNCTION sp_add_cve_diferencia(
    p_descripcion varchar(60),
    p_cuenta_ingreso integer,
    p_id_usuario integer
) RETURNS TABLE (clave_diferencia smallint) AS $$
DECLARE
    new_clave smallint;
BEGIN
    SELECT COALESCE(MAX(clave_diferencia), 0) + 1 INTO new_clave FROM ta_11_catalogo_dif;
    INSERT INTO ta_11_catalogo_dif (clave_diferencia, descripcion, cuenta_ingreso, fecha_actual, id_usuario)
    VALUES (new_clave, UPPER(p_descripcion), p_cuenta_ingreso, NOW(), p_id_usuario);
    RETURN QUERY SELECT new_clave;
END;
$$ LANGUAGE plpgsql;