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
    v_new_clave smallint;
BEGIN
    -- Obtener el siguiente número de clave usando alias para evitar ambigüedad
    SELECT COALESCE(MAX(t.clave_diferencia), 0) + 1
    INTO v_new_clave
    FROM ta_11_catalogo_dif t;

    -- Insertar el nuevo registro
    INSERT INTO ta_11_catalogo_dif (
        clave_diferencia,
        descripcion,
        cuenta_ingreso,
        fecha_actual,
        id_usuario
    )
    VALUES (
        v_new_clave,
        UPPER(p_descripcion),
        p_cuenta_ingreso,
        NOW(),
        p_id_usuario
    );

    -- Retornar el nuevo ID
    RETURN QUERY SELECT v_new_clave;
END;
$$ LANGUAGE plpgsql;