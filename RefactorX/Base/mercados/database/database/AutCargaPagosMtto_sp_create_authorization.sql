-- Stored Procedure: sp_create_authorization
-- Tipo: CRUD
-- Descripción: Crea una nueva autorización de fecha de ingreso.
-- Generado para formulario: AutCargaPagosMtto
-- Fecha: 2025-08-26 18:53:38

CREATE OR REPLACE FUNCTION sp_create_authorization(
    p_fecha_ingreso DATE,
    p_oficina SMALLINT,
    p_autorizar CHAR(1),
    p_fecha_limite DATE,
    p_id_usupermiso INTEGER,
    p_comentarios TEXT,
    p_id_usuario INTEGER
) RETURNS TABLE(result TEXT) AS $$
BEGIN
    INSERT INTO ta_11_autcargapag (
        fecha_ingreso, oficina, autorizar, fecha_limite, id_usupermiso, comentarios, id_usuario, actualizacion
    ) VALUES (
        p_fecha_ingreso, p_oficina, p_autorizar, p_fecha_limite, p_id_usupermiso, p_comentarios, p_id_usuario, NOW()
    );
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;