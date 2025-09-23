-- Stored Procedure: sp_autcargapag_get
-- Tipo: Catalog
-- Descripción: Obtiene una autorización de carga de pagos por fecha_ingreso y oficina.
-- Generado para formulario: AutCargaPagos
-- Fecha: 2025-08-26 19:44:53

CREATE OR REPLACE FUNCTION sp_autcargapag_get(
    p_fecha_ingreso DATE,
    p_oficina SMALLINT
) RETURNS TABLE (
    fecha_ingreso DATE,
    oficina SMALLINT,
    autorizar CHAR(1),
    fecha_limite DATE,
    id_usupermiso INTEGER,
    comentarios TEXT,
    id_usuario INTEGER,
    actualizacion TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT fecha_ingreso, oficina, autorizar, fecha_limite, id_usupermiso, comentarios, id_usuario, actualizacion
    FROM ta_11_autcargapag
    WHERE fecha_ingreso = p_fecha_ingreso AND oficina = p_oficina;
END;
$$ LANGUAGE plpgsql;