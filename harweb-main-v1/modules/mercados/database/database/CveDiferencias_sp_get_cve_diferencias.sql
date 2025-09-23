-- Stored Procedure: sp_get_cve_diferencias
-- Tipo: Catalog
-- Descripción: Obtiene todas las claves de diferencias con información de usuario.
-- Generado para formulario: CveDiferencias
-- Fecha: 2025-08-26 23:39:54

CREATE OR REPLACE FUNCTION sp_get_cve_diferencias()
RETURNS TABLE (
    clave_diferencia smallint,
    descripcion varchar(60),
    cuenta_ingreso integer,
    fecha_actual timestamp,
    id_usuario integer,
    usuario varchar(20),
    nombre varchar(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.clave_diferencia, a.descripcion, a.cuenta_ingreso, a.fecha_actual, a.id_usuario, b.usuario, b.nombre
    FROM ta_11_catalogo_dif a
    JOIN ta_12_passwords b ON b.id_usuario = a.id_usuario
    ORDER BY a.clave_diferencia;
END;
$$ LANGUAGE plpgsql;