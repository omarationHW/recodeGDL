-- Stored Procedure: sp_autcargapag_list
-- Tipo: Catalog
-- Descripción: Lista todas las autorizaciones de carga de pagos, con datos de usuario y permisos.
-- Generado para formulario: AutCargaPagos
-- Fecha: 2025-08-26 22:46:42

CREATE OR REPLACE FUNCTION sp_autcargapag_list(p_oficina integer DEFAULT NULL)
RETURNS TABLE (
    fecha_ingreso date,
    oficina smallint,
    autorizar char(1),
    fecha_limite date,
    id_usupermiso integer,
    comentarios text,
    id_usuario integer,
    actualizacion timestamp,
    nombre varchar,
    usuario varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.fecha_ingreso, a.oficina, a.autorizar, a.fecha_limite, a.id_usupermiso, a.comentarios, a.id_usuario, a.actualizacion, b.nombre, c.usuario
    FROM ta_11_autcargapag a
    JOIN ta_12_passwords b ON b.id_usuario = a.id_usupermiso
    JOIN ta_12_passwords c ON c.id_usuario = a.id_usuario
    WHERE (p_oficina IS NULL OR a.oficina = p_oficina)
    ORDER BY a.fecha_ingreso DESC;
END;
$$ LANGUAGE plpgsql;