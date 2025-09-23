-- Stored Procedure: sp_autcargapag_show
-- Tipo: Catalog
-- Descripción: Devuelve el detalle de una autorización de carga de pagos.
-- Generado para formulario: AutCargaPagos
-- Fecha: 2025-08-26 22:46:42

CREATE OR REPLACE FUNCTION sp_autcargapag_show(
    p_fecha_ingreso date,
    p_oficina smallint
) RETURNS TABLE (
    fecha_ingreso date,
    oficina smallint,
    autorizar char(1),
    fecha_limite date,
    id_usupermiso integer,
    comentarios text,
    id_usuario integer,
    actualizacion timestamp
) AS $$
BEGIN
    RETURN QUERY SELECT fecha_ingreso, oficina, autorizar, fecha_limite, id_usupermiso, comentarios, id_usuario, actualizacion
    FROM ta_11_autcargapag
    WHERE fecha_ingreso = p_fecha_ingreso AND oficina = p_oficina;
END;
$$ LANGUAGE plpgsql;