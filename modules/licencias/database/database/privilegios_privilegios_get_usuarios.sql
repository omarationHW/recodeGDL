-- Stored Procedure: privilegios_get_usuarios
-- Tipo: Catalog
-- Descripción: Obtiene la lista de usuarios con privilegios, filtrando por campo y filtro, y tipo (usuario/depto)
-- Generado para formulario: privilegios
-- Fecha: 2025-08-26 17:28:26

CREATE OR REPLACE FUNCTION privilegios_get_usuarios(campo TEXT, filtro TEXT, tipo TEXT)
RETURNS TABLE(usuario TEXT, nombres TEXT, baja DATE, nombredepto TEXT) AS $$
BEGIN
  RETURN QUERY
  WITH usuarios AS (
    SELECT a.usuario, u.nombres, u.fecbaj AS baja, d.nombredepto
    FROM c_programas p
    INNER JOIN aud_auto a ON a.num_tag = p.num_tag
    INNER JOIN usuarios u ON u.usuario = a.usuario
    LEFT JOIN deptos d ON d.cvedepto = u.cvedepto
    WHERE p.num_tag BETWEEN 8000 AND 8999
    GROUP BY a.usuario, u.nombres, u.fecbaj, d.nombredepto
    UNION ALL
    SELECT a.usuario, u.nombres, u.fecbaj AS baja, d.nombredepto
    FROM c_programas p
    INNER JOIN autoriza a ON a.num_tag = p.num_tag
    INNER JOIN usuarios u ON u.usuario = a.usuario
    LEFT JOIN deptos d ON d.cvedepto = u.cvedepto
    WHERE p.num_tag BETWEEN 8000 AND 8999
    GROUP BY a.usuario, u.nombres, u.fecbaj, d.nombredepto
  )
  SELECT * FROM usuarios
  WHERE (
    (tipo = 'usuario' AND (LOWER(usuario) LIKE '%' || LOWER(filtro) || '%' OR LOWER(nombres) LIKE '%' || LOWER(filtro) || '%'))
    OR (tipo = 'depto' AND UPPER(nombredepto) LIKE '%' || UPPER(filtro) || '%')
  )
  ORDER BY CASE WHEN campo = 'usuario' THEN usuario
                WHEN campo = 'nombres' THEN nombres
                WHEN campo = 'baja' THEN baja::text
                WHEN campo = 'nombredepto' THEN nombredepto
                ELSE usuario END;
END;
$$ LANGUAGE plpgsql;