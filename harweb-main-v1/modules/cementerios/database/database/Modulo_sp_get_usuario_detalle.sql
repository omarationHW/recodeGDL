-- Stored Procedure: sp_get_usuario_detalle
-- Tipo: Catalog
-- Descripción: Obtiene detalles del usuario por nombre de usuario.
-- Generado para formulario: Modulo
-- Fecha: 2025-08-27 14:38:06

CREATE OR REPLACE FUNCTION sp_get_usuario_detalle(p_usuario VARCHAR)
RETURNS TABLE(
    id_usuario INTEGER,
    usuario VARCHAR,
    nombre VARCHAR,
    estado VARCHAR,
    id_rec SMALLINT,
    id_zona INTEGER,
    recaudadora VARCHAR,
    domicilio VARCHAR,
    tel VARCHAR,
    recaudador VARCHAR,
    nivel SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id_usuario,
        a.usuario,
        a.nombre,
        a.estado,
        a.id_rec,
        b.id_zona,
        b.recaudadora,
        b.domicilio,
        b.tel,
        b.recaudador,
        a.nivel
    FROM ta_12_passwords a
    JOIN ta_12_recaudadoras b ON a.id_rec = b.id_rec
    WHERE a.usuario = p_usuario
      AND a.estado = 'A';
END;
$$ LANGUAGE plpgsql;