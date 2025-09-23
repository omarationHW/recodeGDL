-- Stored Procedure: sp_get_users_with_permission
-- Tipo: Catalog
-- Descripción: Obtiene los usuarios con permiso para autorizar fechas de ingreso en una oficina.
-- Generado para formulario: AutCargaPagosMtto
-- Fecha: 2025-08-26 22:48:05

CREATE OR REPLACE FUNCTION sp_get_users_with_permission(p_oficina integer)
RETURNS TABLE(id_usuario integer, usuario text, nombre text) AS $$
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