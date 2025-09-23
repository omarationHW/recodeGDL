-- Stored Procedure: sp_autcargapag_get
-- Tipo: Catalog
-- Descripción: Obtiene un registro de autorización de carga de pagos por fecha_ingreso.
-- Generado para formulario: AutCargaPagosMtto
-- Fecha: 2025-08-26 20:30:43

CREATE OR REPLACE FUNCTION sp_autcargapag_get(p_fecha_ingreso DATE)
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
    WHERE a.fecha_ingreso = p_fecha_ingreso;
END;
$$ LANGUAGE plpgsql;