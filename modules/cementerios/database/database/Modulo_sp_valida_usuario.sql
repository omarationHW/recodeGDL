-- Stored Procedure: sp_valida_usuario
-- Tipo: CRUD
-- Descripción: Valida usuario y clave, retorna datos del usuario si es válido.
-- Generado para formulario: Modulo
-- Fecha: 2025-08-27 14:38:06

CREATE OR REPLACE FUNCTION sp_valida_usuario(p_usuario VARCHAR, p_clave VARCHAR)
RETURNS TABLE(
    valido BOOLEAN,
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
        TRUE AS valido,
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
      AND a.clave = p_clave
      AND a.estado = 'A'
    LIMIT 1;
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;