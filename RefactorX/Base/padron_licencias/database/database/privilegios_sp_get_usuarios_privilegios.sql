-- Stored Procedure: sp_get_usuarios_privilegios
-- Tipo: Catalog
-- Descripción: Obtiene la lista de usuarios con privilegios, filtrando por campo y texto, paginado.
-- Generado para formulario: privilegios
-- Fecha: 2025-08-27 18:54:11

CREATE OR REPLACE FUNCTION sp_get_usuarios_privilegios(
    campo TEXT,
    filtro TEXT,
    offset_val INTEGER DEFAULT 0,
    limit_val INTEGER DEFAULT 20
)
RETURNS TABLE (
    usuario VARCHAR,
    nombres VARCHAR,
    baja DATE,
    nombredepto VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT usuario, nombres, baja, nombredepto FROM (
        SELECT a.usuario, u.nombres, u.fecbaj AS baja, d.nombredepto
        FROM c_programas p
        INNER JOIN aud_auto a ON a.num_tag = p.num_tag
        INNER JOIN usuarios u ON u.usuario = a.usuario
        LEFT JOIN deptos d ON d.cvedepto = u.cvedepto
        WHERE p.num_tag BETWEEN 8000 AND 8999
        GROUP BY 1,2,3,4
        UNION ALL
        SELECT a.usuario, u.nombres, u.fecbaj AS baja, d.nombredepto
        FROM c_programas p
        INNER JOIN autoriza a ON a.num_tag = p.num_tag
        INNER JOIN usuarios u ON u.usuario = a.usuario
        LEFT JOIN deptos d ON d.cvedepto = u.cvedepto
        WHERE p.num_tag BETWEEN 8000 AND 8999
        GROUP BY 1,2,3,4
    ) AS usuarios
    WHERE LOWER(usuario) LIKE '%' || LOWER(filtro) || '%' OR LOWER(nombres) LIKE '%' || LOWER(filtro) || '%'
    ORDER BY CASE WHEN campo = 'usuario' THEN usuario
                  WHEN campo = 'nombres' THEN nombres
                  WHEN campo = 'baja' THEN baja::text
                  WHEN campo = 'nombredepto' THEN nombredepto
                  ELSE usuario END
    OFFSET offset_val LIMIT limit_val;
END;
$$ LANGUAGE plpgsql;