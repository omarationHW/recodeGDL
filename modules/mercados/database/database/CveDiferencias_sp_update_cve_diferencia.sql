-- Stored Procedure: sp_update_cve_diferencia
-- Tipo: CRUD
-- Descripción: Actualiza una clave de diferencia existente.
-- Generado para formulario: CveDiferencias
-- Fecha: 2025-08-26 23:39:54

CREATE OR REPLACE FUNCTION sp_update_cve_diferencia(
    p_clave_diferencia smallint,
    p_descripcion varchar(60),
    p_cuenta_ingreso integer,
    p_id_usuario integer
) RETURNS void AS $$
BEGIN
    UPDATE ta_11_catalogo_dif
    SET descripcion = UPPER(p_descripcion),
        cuenta_ingreso = p_cuenta_ingreso,
        fecha_actual = NOW(),
        id_usuario = p_id_usuario
    WHERE clave_diferencia = p_clave_diferencia;
END;
$$ LANGUAGE plpgsql;