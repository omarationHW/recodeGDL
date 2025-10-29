-- Stored Procedure: sp_baja_anuncio_verificar_permisos
-- Tipo: CRUD
-- Descripción: Verifica los permisos del usuario para dar de baja anuncios.
-- Generado para formulario: bajaAnunciofrm
-- Fecha: 2025-08-27 15:56:52

CREATE OR REPLACE FUNCTION sp_baja_anuncio_verificar_permisos(p_usuario TEXT)
RETURNS TABLE (
  nivel SMALLINT,
  cvedependencia INTEGER,
  cvedepto INTEGER
) AS $$
BEGIN
  RETURN QUERY
    SELECT u.nivel, d.cvedependencia, u.cvedepto
    FROM usuarios u
    JOIN deptos d ON d.cvedepto = u.cvedepto
    WHERE u.usuario = p_usuario;
END;
$$ LANGUAGE plpgsql;