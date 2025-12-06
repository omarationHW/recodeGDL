-- ============================================
-- Stored Procedure: sp_consulta_usuario_por_dependencia_depto
-- Base de Datos: padron_licencias
-- Esquema: comun
-- Descripción: Consulta usuarios por dependencia y departamento
-- Tablas: comun.usuarios, comun.deptos, comun.c_dependencias
-- Fecha: 2025-11-03
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_consulta_usuario_por_dependencia_depto(
    p_id_dependencia INTEGER,
    p_cvedepto INTEGER
)
RETURNS TABLE (
    descripcion VARCHAR,
    nombredepto VARCHAR,
    telefono VARCHAR,
    usuario VARCHAR,
    nombres VARCHAR,
    fecalt DATE,
    fecbaj DATE,
    feccap DATE,
    capturo VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        TRIM(c.descripcion)::VARCHAR,
        TRIM(d.nombredepto)::VARCHAR,
        TRIM(d.telefono)::VARCHAR,
        TRIM(u.usuario)::VARCHAR,
        TRIM(u.nombres)::VARCHAR,
        u.fecalt,
        u.fecbaj,
        u.feccap,
        TRIM(u.capturo)::VARCHAR
    FROM comun.usuarios u
    INNER JOIN comun.deptos d ON d.cvedepto = u.cvedepto
    INNER JOIN comun.c_dependencias c ON c.id_dependencia = d.cvedependencia
    WHERE d.cvedependencia = p_id_dependencia
      AND u.cvedepto = p_cvedepto;
END;
$$ LANGUAGE plpgsql;

-- Comentarios
COMMENT ON FUNCTION comun.sp_consulta_usuario_por_dependencia_depto(INTEGER, INTEGER) IS 'Consulta usuarios por dependencia y departamento';
