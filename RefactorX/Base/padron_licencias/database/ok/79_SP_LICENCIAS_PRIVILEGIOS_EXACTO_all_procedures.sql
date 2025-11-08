-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: PRIVILEGIOS (EXACTO del archivo original)
-- Archivo: 79_SP_LICENCIAS_PRIVILEGIOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 1/7: sp_get_usuarios_privilegios
-- Tipo: Catalog
-- Descripción: Obtiene la lista de usuarios con privilegios, filtrando por campo y texto, paginado.
-- --------------------------------------------

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

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: PRIVILEGIOS (EXACTO del archivo original)
-- Archivo: 79_SP_LICENCIAS_PRIVILEGIOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 3/7: sp_get_auditoria_usuario
-- Tipo: Report
-- Descripción: Obtiene la bitácora de auditoría de permisos de un usuario.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_auditoria_usuario(
    p_usuario VARCHAR
)
RETURNS TABLE (
    num_tag INTEGER,
    descripcion VARCHAR,
    id INTEGER,
    fechahora TIMESTAMP,
    equipo VARCHAR,
    proc VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.num_tag, p.descripcion, a.id, a.fechahora, a.equipo,
        CASE a.proc
            WHEN 'I' THEN 'Asignado'
            WHEN 'D' THEN 'Eliminado'
            WHEN 'U' THEN 'Actualizado'
            ELSE a.proc
        END AS proc
    FROM c_programas p
    INNER JOIN aud_auto a ON a.num_tag = p.num_tag AND a.usuario = p_usuario
    WHERE p.num_tag BETWEEN 8000 AND 8999;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: PRIVILEGIOS (EXACTO del archivo original)
-- Archivo: 79_SP_LICENCIAS_PRIVILEGIOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 5/7: sp_get_mov_licencias
-- Tipo: Report
-- Descripción: Obtiene los movimientos de licencias de un usuario en un rango de fechas.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_mov_licencias(
    p_usuario VARCHAR,
    p_fechaini DATE,
    p_fechafin DATE
)
RETURNS TABLE (
    id INTEGER,
    uid INTEGER,
    username VARCHAR,
    ttyin VARCHAR,
    ttyout VARCHAR,
    ttyerr VARCHAR,
    cwd TEXT,
    hostname TEXT,
    time TIMESTAMP,
    event VARCHAR,
    id_licencia INTEGER,
    licencia INTEGER,
    empresa INTEGER,
    recaud SMALLINT,
    id_giro INTEGER,
    x FLOAT,
    y FLOAT,
    zona SMALLINT,
    subzona SMALLINT,
    tipo_registro VARCHAR,
    actividad VARCHAR,
    cvecuenta INTEGER,
    fecha_otorgamiento DATE,
    propietario VARCHAR,
    rfc VARCHAR,
    curp VARCHAR,
    domicilio VARCHAR,
    numext_prop INTEGER,
    numint_prop VARCHAR,
    colonia_prop VARCHAR,
    telefono_prop VARCHAR,
    email VARCHAR,
    cvecalle INTEGER,
    ubicacion VARCHAR,
    numext_ubic INTEGER,
    letraext_ubic VARCHAR,
    numint_ubic VARCHAR,
    letraint_ubic VARCHAR,
    colonia_ubic VARCHAR,
    sup_construida FLOAT,
    sup_autorizada FLOAT,
    num_cajones SMALLINT,
    num_empleados SMALLINT,
    aforo SMALLINT,
    inversion NUMERIC,
    rhorario VARCHAR,
    fecha_consejo DATE,
    bloqueado SMALLINT,
    asiento SMALLINT,
    vigente VARCHAR,
    fecha_baja DATE,
    axo_baja INTEGER,
    folio_baja INTEGER,
    espubic VARCHAR,
    base_impuesto NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM get_sysbacklcs(p_usuario, p_fechaini, p_fechafin);
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: PRIVILEGIOS (EXACTO del archivo original)
-- Archivo: 79_SP_LICENCIAS_PRIVILEGIOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 7/7: sp_get_revisiones
-- Tipo: Report
-- Descripción: Obtiene las revisiones realizadas por un usuario en un rango de fechas.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_revisiones(
    p_fechaini DATE,
    p_fechafin DATE,
    p_usuario VARCHAR
)
RETURNS TABLE (
    id_revision INTEGER,
    id_tramite INTEGER,
    dependencia VARCHAR,
    fecha_inicio DATE,
    fecha_termino DATE,
    estatus_revision VARCHAR,
    fecha_revision DATE,
    usr_revisa VARCHAR,
    estatus_seguimiento VARCHAR,
    observacion TEXT,
    fecha_seguimiento DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.id_revision, r.id_tramite, d.descripcion AS dependencia, r.fecha_inicio, r.fecha_termino, r.estatus AS estatus_revision,
           s.fecha_revision, s.usr_revisa, s.estatus AS estatus_seguimiento, s.observacion, s.feccap AS fecha_seguimiento
    FROM revisiones r
    LEFT JOIN seg_revision s ON s.id_revision = r.id_revision
    LEFT JOIN c_dependencias d ON d.id_dependencia = r.id_dependencia
    WHERE s.feccap BETWEEN p_fechaini AND p_fechafin
      AND s.usr_revisa = p_usuario
    ORDER BY s.feccap;
END;
$$ LANGUAGE plpgsql;

-- ============================================

