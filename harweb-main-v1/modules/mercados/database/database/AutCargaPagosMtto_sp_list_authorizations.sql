-- Stored Procedure: sp_list_authorizations
-- Tipo: Catalog
-- Descripción: Lista todas las autorizaciones de fechas de ingreso para una oficina.
-- Generado para formulario: AutCargaPagosMtto
-- Fecha: 2025-08-26 18:53:38

CREATE OR REPLACE FUNCTION sp_list_authorizations(p_oficina SMALLINT)
RETURNS TABLE(
    fecha_ingreso DATE,
    oficina SMALLINT,
    autorizar CHAR(1),
    fecha_limite DATE,
    id_usupermiso INTEGER,
    comentarios TEXT,
    id_usuario INTEGER,
    actualizacion TIMESTAMP,
    nombre VARCHAR,
    usuario VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.fecha_ingreso, a.oficina, a.autorizar, a.fecha_limite, a.id_usupermiso, a.comentarios, a.id_usuario, a.actualizacion, b.nombre, b.usuario
    FROM ta_11_autcargapag a
    LEFT JOIN ta_12_passwords b ON b.id_usuario = a.id_usupermiso
    WHERE a.oficina = p_oficina
    ORDER BY a.fecha_ingreso DESC;
END;
$$ LANGUAGE plpgsql;