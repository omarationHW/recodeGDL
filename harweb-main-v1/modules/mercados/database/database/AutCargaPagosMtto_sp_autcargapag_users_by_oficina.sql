-- Stored Procedure: sp_autcargapag_users_by_oficina
-- Tipo: Catalog
-- Descripción: Obtiene los usuarios con permiso de autorización para una oficina.
-- Generado para formulario: AutCargaPagosMtto
-- Fecha: 2025-08-26 20:30:43

CREATE OR REPLACE FUNCTION sp_autcargapag_users_by_oficina(p_oficina INTEGER)
RETURNS TABLE (
    id_usuario INTEGER,
    usuario TEXT,
    nombre TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_usuario, a.usuario, a.nombre
    FROM ta_12_passwords a
    JOIN ta_autoriza b ON b.id_usuario = a.id_usuario
    WHERE a.id_rec = p_oficina
      AND a.estado = 'A'
      AND b.id_modulo = 11
      AND b.tag IN (202,203,204)
    ORDER BY a.id_usuario;
END;
$$ LANGUAGE plpgsql;