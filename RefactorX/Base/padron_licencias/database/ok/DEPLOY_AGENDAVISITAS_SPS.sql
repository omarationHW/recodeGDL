-- ====================================
-- STORED PROCEDURES: AGENDA DE VISITAS
-- ====================================
-- Componente: Agendavisitasfrm.vue
-- Fecha: 2025-11-07
-- Base: padron_licencias
-- Esquema: comun
--
-- TABLAS UTILIZADAS:
-- - comun.tramites_visitas (visitas agendadas)
-- - comun.c_dep_horario (horarios de dependencias)
-- - comun.c_dependencias (catálogo de dependencias)
-- - comun.tramites (trámites)
-- ====================================

-- ====================================
-- 1/3: FN_DIALETRA
-- ====================================
-- Descripción: Convierte número de día (0-6) a nombre en español
-- Parámetros: p_dia INTEGER (0=Domingo, 1=Lunes, ..., 6=Sábado)
-- Retorna: VARCHAR (nombre del día)

CREATE OR REPLACE FUNCTION fn_dialetra(p_dia INTEGER)
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

-- ====================================
-- 2/3: SP_GET_DEPENDENCIAS
-- ====================================
-- Descripción: Obtiene catálogo de dependencias que tienen horarios configurados
-- Parámetros: Ninguno
-- Retorna: TABLE(id_dependencia INTEGER, descripcion TEXT)

CREATE OR REPLACE FUNCTION sp_get_dependencias()
RETURNS TABLE (
    id_dependencia INTEGER,
    descripcion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.id_dependencia, d.descripcion::TEXT
    FROM comun.c_dep_horario c
    INNER JOIN comun.c_dependencias d ON c.id_dependencia = d.id_dependencia
    GROUP BY d.id_dependencia, d.descripcion
    ORDER BY d.descripcion;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error en sp_get_dependencias: %', SQLERRM;
        RETURN;
END;
$$ LANGUAGE plpgsql;

-- ====================================
-- 3/3: SP_GET_AGENDA_VISITAS
-- ====================================
-- Descripción: Obtiene visitas agendadas por dependencia y rango de fechas
-- Parámetros: p_id_dependencia INTEGER, p_fechaini DATE, p_fechafin DATE
-- Retorna: TABLE con información completa de visitas

CREATE OR REPLACE FUNCTION sp_get_agenda_visitas(
    p_id_dependencia INTEGER,
    p_fechaini DATE,
    p_fechafin DATE
)
RETURNS TABLE (
    fecha DATE,
    dia_letras TEXT,
    turno TEXT,
    hora TEXT,
    zona SMALLINT,
    subzona SMALLINT,
    id_tramite INTEGER,
    feccap DATE,
    propietario TEXT,
    domcompleto TEXT,
    actividad TEXT,
    propietarionvo TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        v.fecha,
        fn_dialetra(EXTRACT(DOW FROM v.fecha)::INTEGER)::TEXT AS dia_letras,
        v.turno::TEXT,
        v.hora::TEXT,
        v.zona,
        v.subzona,
        v.id_tramite,
        t.feccap,
        t.propietario::TEXT,
        (TRIM(COALESCE(v.ubicacion::TEXT, '')) || ' No. ext.:' || COALESCE(v.numext_ubic::TEXT, '') || ' Letra ext. ' || COALESCE(v.letraext_ubic::TEXT, '') || ' No. int.' || COALESCE(v.numint_ubic::TEXT, '') || ' Letra int. ' || COALESCE(v.letraint_ubic::TEXT, ''))::TEXT AS domcompleto,
        v.actividad::TEXT,
        TRIM(COALESCE(t.primer_ap, '') || ' ' || COALESCE(t.segundo_ap, '') || ' ' || COALESCE(t.propietario, ''))::TEXT AS propietarionvo
    FROM comun.tramites_visitas v
    INNER JOIN comun.c_dep_horario h ON h.id = v.c_dep_horario_id AND h.id_dependencia = p_id_dependencia
    INNER JOIN comun.tramites t ON t.id_tramite = v.id_tramite
    WHERE v.fecha BETWEEN p_fechaini AND p_fechafin
    ORDER BY v.fecha, v.hora;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error en sp_get_agenda_visitas: %', SQLERRM;
        RETURN;
END;
$$ LANGUAGE plpgsql;

-- ====================================
-- FIN DE STORED PROCEDURES
-- ====================================
-- Total: 3 SPs/funciones creados
-- Esquema: comun (tablas)
-- Base: padron_licencias
-- Servidor: 192.168.6.146
--
-- Para desplegar estos SPs, ejecuta este archivo SQL
-- directamente en PostgreSQL con el usuario 'refact'
-- ====================================
