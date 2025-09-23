-- Stored Procedure: sp_autcargapag_list
-- Tipo: Catalog
-- Descripción: Lista todas las fechas de autorización de carga de pagos de mantenimiento.
-- Generado para formulario: AutCargaPagosMtto
-- Fecha: 2025-08-26 20:30:43

CREATE OR REPLACE FUNCTION sp_autcargapag_list()
RETURNS TABLE (
    fecha_ingreso DATE,
    oficina INTEGER,
    autorizar CHAR(1),
    fecha_limite DATE,
    id_usupermiso INTEGER,
    comentarios TEXT,
    id_usuario INTEGER,
    actualizacion TIMESTAMP,
    nombre_usuario_permiso TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.fecha_ingreso, a.oficina, a.autorizar, a.fecha_limite, a.id_usupermiso, a.comentarios, a.id_usuario, a.actualizacion, u.nombre AS nombre_usuario_permiso
    FROM ta_11_autcargapag a
    LEFT JOIN ta_12_passwords u ON u.id_usuario = a.id_usupermiso
    ORDER BY a.fecha_ingreso DESC;
END;
$$ LANGUAGE plpgsql;