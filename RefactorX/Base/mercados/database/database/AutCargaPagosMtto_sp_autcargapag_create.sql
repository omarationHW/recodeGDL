-- Stored Procedure: sp_autcargapag_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo registro de autorización de carga de pagos.
-- Generado para formulario: AutCargaPagosMtto
-- Fecha: 2025-08-26 20:30:43

CREATE OR REPLACE FUNCTION sp_autcargapag_create(
    p_fecha_ingreso DATE,
    p_oficina INTEGER,
    p_autorizar CHAR(1),
    p_fecha_limite DATE,
    p_id_usupermiso INTEGER,
    p_comentarios TEXT,
    p_id_usuario INTEGER
) RETURNS TABLE (
    fecha_ingreso DATE,
    oficina INTEGER,
    autorizar CHAR(1),
    fecha_limite DATE,
    id_usupermiso INTEGER,
    comentarios TEXT,
    id_usuario INTEGER,
    actualizacion TIMESTAMP
) AS $$
BEGIN
    INSERT INTO ta_11_autcargapag (
        fecha_ingreso, oficina, autorizar, fecha_limite, id_usupermiso, comentarios, id_usuario, actualizacion
    ) VALUES (
        p_fecha_ingreso, p_oficina, p_autorizar, p_fecha_limite, p_id_usupermiso, p_comentarios, p_id_usuario, NOW()
    );
    RETURN QUERY
    SELECT fecha_ingreso, oficina, autorizar, fecha_limite, id_usupermiso, comentarios, id_usuario, actualizacion
    FROM ta_11_autcargapag
    WHERE fecha_ingreso = p_fecha_ingreso;
END;
$$ LANGUAGE plpgsql;