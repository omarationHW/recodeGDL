-- Stored Procedure: sp_get_users_by_office
-- Tipo: Catalog
-- Descripción: Obtiene los usuarios autorizados para una oficina específica con permisos de autorización.
-- Generado para formulario: AutCargaPagosMtto
-- Fecha: 2025-08-26 18:53:38

CREATE OR REPLACE FUNCTION sp_get_users_by_office(p_office_id INTEGER)
RETURNS TABLE(
    id_usuario INTEGER,
    usuario VARCHAR,
    nombre VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_usuario, a.usuario, a.nombre
    FROM ta_12_passwords a
    JOIN ta_autoriza b ON b.id_usuario = a.id_usuario
    WHERE a.id_rec = p_office_id
      AND a.estado = 'A'
      AND b.id_modulo = 11
      AND b.tag IN (202,203,204)
    ORDER BY a.id_usuario;
END;
$$ LANGUAGE plpgsql;