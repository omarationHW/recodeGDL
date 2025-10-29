-- Stored Procedure: sp_get_authorizations_by_date
-- Tipo: Catalog
-- Descripción: Obtiene la autorización para una fecha de ingreso específica.
-- Generado para formulario: AutCargaPagosMtto
-- Fecha: 2025-08-26 18:53:38

CREATE OR REPLACE FUNCTION sp_get_authorizations_by_date(p_fecha_ingreso DATE)
RETURNS TABLE(
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
    WHERE fecha_ingreso = p_fecha_ingreso;
END;
$$ LANGUAGE plpgsql;