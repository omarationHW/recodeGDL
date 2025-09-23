-- Stored Procedure: sp_get_user_by_credentials
-- Tipo: CRUD
-- Descripción: Valida usuario y contraseña, retorna datos del usuario si es válido y activo.
-- Generado para formulario: ModuloDb
-- Fecha: 2025-08-27 20:58:42

CREATE OR REPLACE FUNCTION sp_get_user_by_credentials(p_usuario TEXT, p_clave TEXT)
RETURNS TABLE (
    id_usuario INTEGER,
    usuario TEXT,
    nombre TEXT,
    estado TEXT,
    id_rec SMALLINT,
    id_zona INTEGER,
    recaudadora TEXT,
    domicilio TEXT,
    tel TEXT,
    recaudador TEXT,
    nivel SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_usuario, a.usuario, a.nombre, a.estado, a.id_rec, b.id_zona, b.recaudadora, b.domicilio, b.tel, b.recaudador, a.nivel
    FROM ta_12_passwords a
    JOIN ta_12_recaudadoras b ON a.id_rec = b.id_rec
    WHERE a.usuario = p_usuario
      AND a.clave = p_clave
      AND a.estado = 'A';
END;
$$ LANGUAGE plpgsql;