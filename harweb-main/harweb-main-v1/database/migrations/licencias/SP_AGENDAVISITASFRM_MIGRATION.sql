-- ============================================
-- MIGRACIÓN DE STORED PROCEDURES - AGENDAVISITASFRM
-- Base de datos: padron_licencias
-- Esquema: informix
-- Generado: 2025-09-22
-- ============================================

\c padron_licencias;
SET search_path TO informix;

-- ============================================
-- SP 1/3: sp_get_dependencias
-- Descripción: Obtiene el catálogo de dependencias disponibles para agendar visitas
-- ============================================

CREATE OR REPLACE FUNCTION informix.sp_get_dependencias()
RETURNS TABLE (
    id_dependencia INTEGER,
    descripcion CHARACTER(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.id_dependencia, d.descripcion
    FROM informix.c_dep_horario c
    INNER JOIN informix.c_dependencias d ON c.id_dependencia = d.id_dependencia
    GROUP BY d.id_dependencia, d.descripcion
    ORDER BY d.descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 2/3: sp_get_agenda_visitas
-- Descripción: Obtiene el reporte de visitas agendadas filtrado por dependencia y rango de fechas
-- ============================================

CREATE OR REPLACE FUNCTION informix.sp_get_agenda_visitas(
    p_id_dependencia INTEGER,
    p_fechaini DATE,
    p_fechafin DATE
)
RETURNS TABLE (
    fecha DATE,
    dia_letras VARCHAR,
    turno VARCHAR,
    hora VARCHAR,
    zona SMALLINT,
    subzona SMALLINT,
    id_tramite INTEGER,
    feccap DATE,
    propietario VARCHAR,
    domcompleto VARCHAR,
    actividad VARCHAR,
    propietarionvo VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        v.fecha,
        informix.fn_dialetra(EXTRACT(DOW FROM v.fecha)::INTEGER) AS dia_letras,
        v.turno,
        v.hora,
        v.zona,
        v.subzona,
        v.id_tramite,
        t.feccap,
        t.propietario,
        TRIM(COALESCE(v.ubicacion, '')) || ' No. ext.:' || COALESCE(v.numext_ubic, '') || ' Letra ext. ' || COALESCE(v.letraext_ubic, '') || ' No. int.' || COALESCE(v.numint_ubic, '') || ' Letra int. ' || COALESCE(v.letraint_ubic, '') AS domcompleto,
        v.actividad,
        TRIM(COALESCE(t.primer_ap, '') || ' ' || COALESCE(t.segundo_ap, '') || ' ' || COALESCE(t.propietario, '')) AS propietarionvo
    FROM informix.tramites_visitas v
    INNER JOIN informix.c_dep_horario h ON h.id = v.c_dep_horario_id AND h.id_dependencia = p_id_dependencia
    INNER JOIN informix.tramites t ON t.id_tramite = v.id_tramite
    WHERE v.fecha BETWEEN p_fechaini AND p_fechafin;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 3/3: fn_dialetra
-- Descripción: Devuelve el nombre del día de la semana en español
-- ============================================

CREATE OR REPLACE FUNCTION informix.fn_dialetra(p_dia INTEGER)
RETURNS VARCHAR AS $$
DECLARE
    dias TEXT[] := ARRAY['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
BEGIN
    IF p_dia IS NULL OR p_dia < 0 OR p_dia > 6 THEN
        RETURN '';
    END IF;
    RETURN dias[p_dia+1];
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================
-- COMENTARIOS DE USO
-- ============================================
-- 1. Ejecutar: SELECT * FROM informix.sp_get_dependencias();
-- 2. Ejecutar: SELECT * FROM informix.sp_get_agenda_visitas(1, '2025-01-01', '2025-12-31');
-- 3. Ejecutar: SELECT informix.fn_dialetra(1); -- Retorna 'Lunes'