-- =====================================================================================
-- SISTEMA MUNICIPAL DIGITAL - GOBIERNO DE GUADALAJARA
-- =====================================================================================
-- Descripción: Stored Procedures para Agenda de Visitas de Inspección
-- Autor: Sistema de Refactorización Vue.js
-- Fecha: 2025-09-29
-- Versión: 1.0
-- =====================================================================================

-- =====================================================================================
-- CREACIÓN DE ESQUEMA Y TABLA AGENDA_VISITAS
-- =====================================================================================

-- Crear esquema informix si no existe
CREATE SCHEMA IF NOT EXISTS informix;

-- Crear tabla agenda_visitas
DROP TABLE IF EXISTS informix.agenda_visitas CASCADE;

CREATE TABLE informix.agenda_visitas (
    id SERIAL PRIMARY KEY,
    fecha_visita DATE NOT NULL,
    hora_visita TIME,
    turno VARCHAR(20) DEFAULT 'MATUTINO' CHECK (turno IN ('MATUTINO', 'VESPERTINO', 'NOCTURNO')),
    dia_letras VARCHAR(20),

    -- Datos del trámite
    id_tramite VARCHAR(20) NOT NULL,
    fecha_tramite TIMESTAMP,
    tipo_tramite VARCHAR(50),
    estado_visita VARCHAR(20) DEFAULT 'PROGRAMADA' CHECK (estado_visita IN ('PROGRAMADA', 'REALIZADA', 'CANCELADA', 'REPROGRAMADA')),

    -- Ubicación
    zona VARCHAR(10),
    subzona VARCHAR(10),
    domicilio_completo TEXT,
    coordenadas_lat DECIMAL(10,8),
    coordenadas_lng DECIMAL(11,8),

    -- Propietario/Solicitante
    propietario VARCHAR(255),
    propietario_nuevo VARCHAR(255),
    rfc_propietario VARCHAR(13),
    telefono_contacto VARCHAR(20),

    -- Actividad/Giro
    actividad VARCHAR(100),
    giro VARCHAR(100),
    superficie_m2 DECIMAL(10,2),

    -- Inspector y Dependencia
    id_dependencia INTEGER NOT NULL,
    id_inspector INTEGER,
    nombre_inspector VARCHAR(255),
    observaciones_inspector TEXT,

    -- Resultado de la visita
    resultado_visita VARCHAR(50),
    dictamen VARCHAR(20) CHECK (dictamen IN ('PROCEDENTE', 'NO_PROCEDENTE', 'CONDICIONADO', 'PENDIENTE')),
    observaciones_dictamen TEXT,
    requiere_segunda_visita BOOLEAN DEFAULT FALSE,

    -- Control
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_creacion VARCHAR(50) DEFAULT 'sistema',
    usuario_modificacion VARCHAR(50) DEFAULT 'sistema'
);

-- Crear índices
CREATE INDEX idx_agenda_fecha_visita ON informix.agenda_visitas(fecha_visita);
CREATE INDEX idx_agenda_id_tramite ON informix.agenda_visitas(id_tramite);
CREATE INDEX idx_agenda_id_dependencia ON informix.agenda_visitas(id_dependencia);
CREATE INDEX idx_agenda_estado ON informix.agenda_visitas(estado_visita);
CREATE INDEX idx_agenda_zona ON informix.agenda_visitas(zona, subzona);

-- Crear tabla de dependencias si no existe
DROP TABLE IF EXISTS informix.dependencias CASCADE;

CREATE TABLE IF NOT EXISTS informix.dependencias (
    id_dependencia SERIAL PRIMARY KEY,
    descripcion VARCHAR(255) NOT NULL,
    siglas VARCHAR(20),
    tipo_dependencia VARCHAR(50),
    responsable VARCHAR(255),
    telefono VARCHAR(20),
    email VARCHAR(100),
    activa BOOLEAN DEFAULT TRUE
);

-- Trigger para actualizar fecha_modificacion
CREATE OR REPLACE FUNCTION informix.update_agenda_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fecha_modificacion = CURRENT_TIMESTAMP;
    -- Actualizar día en letras automáticamente
    NEW.dia_letras = CASE EXTRACT(DOW FROM NEW.fecha_visita)
        WHEN 0 THEN 'DOMINGO'
        WHEN 1 THEN 'LUNES'
        WHEN 2 THEN 'MARTES'
        WHEN 3 THEN 'MIÉRCOLES'
        WHEN 4 THEN 'JUEVES'
        WHEN 5 THEN 'VIERNES'
        WHEN 6 THEN 'SÁBADO'
    END;
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS tr_agenda_update_timestamp ON informix.agenda_visitas;
CREATE TRIGGER tr_agenda_update_timestamp
    BEFORE INSERT OR UPDATE ON informix.agenda_visitas
    FOR EACH ROW
    EXECUTE FUNCTION informix.update_agenda_timestamp();

-- =====================================================================================
-- 1. SP_AGENDA_VISITAS_LIST - Listar visitas con filtros
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_agenda_visitas_list(
    p_fecha_inicio DATE,
    p_fecha_fin DATE,
    p_id_dependencia INTEGER DEFAULT NULL,
    p_zona VARCHAR(10) DEFAULT NULL,
    p_estado_visita VARCHAR(20) DEFAULT NULL,
    p_id_inspector INTEGER DEFAULT NULL
)
RETURNS TABLE(
    id INTEGER,
    fecha_visita DATE,
    hora_visita TIME,
    turno VARCHAR(20),
    dia_letras VARCHAR(20),
    id_tramite VARCHAR(20),
    fecha_tramite TIMESTAMP,
    zona VARCHAR(10),
    subzona VARCHAR(10),
    domicilio_completo TEXT,
    propietario VARCHAR(255),
    propietario_nuevo VARCHAR(255),
    actividad VARCHAR(100),
    giro VARCHAR(100),
    id_dependencia INTEGER,
    nombre_dependencia VARCHAR(255),
    nombre_inspector VARCHAR(255),
    estado_visita VARCHAR(20),
    resultado_visita VARCHAR(50),
    dictamen VARCHAR(20)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        av.id,
        av.fecha_visita,
        av.hora_visita,
        av.turno,
        av.dia_letras,
        av.id_tramite,
        av.fecha_tramite,
        av.zona,
        av.subzona,
        av.domicilio_completo,
        av.propietario,
        av.propietario_nuevo,
        av.actividad,
        av.giro,
        av.id_dependencia,
        d.descripcion as nombre_dependencia,
        av.nombre_inspector,
        av.estado_visita,
        av.resultado_visita,
        av.dictamen
    FROM informix.agenda_visitas av
    LEFT JOIN informix.dependencias d ON av.id_dependencia = d.id_dependencia
    WHERE av.fecha_visita >= p_fecha_inicio
      AND av.fecha_visita <= p_fecha_fin
      AND (p_id_dependencia IS NULL OR av.id_dependencia = p_id_dependencia)
      AND (p_zona IS NULL OR av.zona = p_zona)
      AND (p_estado_visita IS NULL OR av.estado_visita = p_estado_visita)
      AND (p_id_inspector IS NULL OR av.id_inspector = p_id_inspector)
    ORDER BY av.fecha_visita, av.hora_visita;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 2. SP_AGENDA_VISITAS_CREATE - Crear nueva visita
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_agenda_visitas_create(
    p_fecha_visita DATE,
    p_id_tramite VARCHAR(20),
    p_id_dependencia INTEGER,
    p_hora_visita TIME DEFAULT NULL,
    p_turno VARCHAR(20) DEFAULT 'MATUTINO',
    p_zona VARCHAR(10) DEFAULT NULL,
    p_subzona VARCHAR(10) DEFAULT NULL,
    p_domicilio_completo TEXT DEFAULT NULL,
    p_propietario VARCHAR(255) DEFAULT NULL,
    p_actividad VARCHAR(100) DEFAULT NULL,
    p_giro VARCHAR(100) DEFAULT NULL,
    p_id_inspector INTEGER DEFAULT NULL,
    p_nombre_inspector VARCHAR(255) DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    id INTEGER
) AS $$
DECLARE
    nuevo_id INTEGER;
    visita_existe BOOLEAN;
BEGIN
    -- Validar datos requeridos
    IF p_fecha_visita IS NULL THEN
        RETURN QUERY SELECT FALSE, 'La fecha de visita es requerida'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    IF p_id_tramite IS NULL OR p_id_tramite = '' THEN
        RETURN QUERY SELECT FALSE, 'El ID del trámite es requerido'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    IF p_id_dependencia IS NULL THEN
        RETURN QUERY SELECT FALSE, 'La dependencia es requerida'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    -- Verificar si ya existe una visita para ese trámite en esa fecha
    SELECT EXISTS(
        SELECT 1 FROM informix.agenda_visitas
        WHERE id_tramite = p_id_tramite
          AND fecha_visita = p_fecha_visita
          AND estado_visita = 'PROGRAMADA'
    ) INTO visita_existe;

    IF visita_existe THEN
        RETURN QUERY SELECT FALSE, 'Ya existe una visita programada para este trámite en la fecha indicada'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    -- Insertar nueva visita
    INSERT INTO informix.agenda_visitas (
        fecha_visita,
        hora_visita,
        turno,
        id_tramite,
        fecha_tramite,
        id_dependencia,
        zona,
        subzona,
        domicilio_completo,
        propietario,
        actividad,
        giro,
        id_inspector,
        nombre_inspector,
        estado_visita,
        usuario_creacion
    ) VALUES (
        p_fecha_visita,
        p_hora_visita,
        p_turno,
        p_id_tramite,
        CURRENT_TIMESTAMP,
        p_id_dependencia,
        p_zona,
        p_subzona,
        p_domicilio_completo,
        p_propietario,
        p_actividad,
        p_giro,
        p_id_inspector,
        p_nombre_inspector,
        'PROGRAMADA',
        'sistema'
    ) RETURNING id INTO nuevo_id;

    RETURN QUERY SELECT TRUE, 'Visita programada exitosamente'::TEXT, nuevo_id;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, ('Error al programar visita: ' || SQLERRM)::TEXT, NULL::INTEGER;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 3. SP_AGENDA_VISITAS_UPDATE - Actualizar visita existente
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_agenda_visitas_update(
    p_id INTEGER,
    p_fecha_visita DATE DEFAULT NULL,
    p_hora_visita TIME DEFAULT NULL,
    p_turno VARCHAR(20) DEFAULT NULL,
    p_id_inspector INTEGER DEFAULT NULL,
    p_nombre_inspector VARCHAR(255) DEFAULT NULL,
    p_estado_visita VARCHAR(20) DEFAULT NULL,
    p_resultado_visita VARCHAR(50) DEFAULT NULL,
    p_dictamen VARCHAR(20) DEFAULT NULL,
    p_observaciones_dictamen TEXT DEFAULT NULL,
    p_requiere_segunda_visita BOOLEAN DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    visita_existe BOOLEAN;
BEGIN
    -- Verificar si existe la visita
    SELECT EXISTS(
        SELECT 1 FROM informix.agenda_visitas
        WHERE id = p_id
    ) INTO visita_existe;

    IF NOT visita_existe THEN
        RETURN QUERY SELECT FALSE, 'La visita no existe'::TEXT;
        RETURN;
    END IF;

    -- Actualizar visita
    UPDATE informix.agenda_visitas SET
        fecha_visita = COALESCE(p_fecha_visita, fecha_visita),
        hora_visita = COALESCE(p_hora_visita, hora_visita),
        turno = COALESCE(p_turno, turno),
        id_inspector = COALESCE(p_id_inspector, id_inspector),
        nombre_inspector = COALESCE(p_nombre_inspector, nombre_inspector),
        estado_visita = COALESCE(p_estado_visita, estado_visita),
        resultado_visita = COALESCE(p_resultado_visita, resultado_visita),
        dictamen = COALESCE(p_dictamen, dictamen),
        observaciones_dictamen = COALESCE(p_observaciones_dictamen, observaciones_dictamen),
        requiere_segunda_visita = COALESCE(p_requiere_segunda_visita, requiere_segunda_visita),
        usuario_modificacion = 'sistema'
    WHERE id = p_id;

    RETURN QUERY SELECT TRUE, 'Visita actualizada exitosamente'::TEXT;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, ('Error al actualizar visita: ' || SQLERRM)::TEXT;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 4. SP_AGENDA_VISITAS_CANCELAR - Cancelar visita
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_agenda_visitas_cancelar(
    p_id INTEGER,
    p_motivo_cancelacion TEXT DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    estado_actual VARCHAR(20);
BEGIN
    -- Verificar estado actual
    SELECT estado_visita INTO estado_actual
    FROM informix.agenda_visitas
    WHERE id = p_id;

    IF estado_actual IS NULL THEN
        RETURN QUERY SELECT FALSE, 'La visita no existe'::TEXT;
        RETURN;
    END IF;

    IF estado_actual = 'CANCELADA' THEN
        RETURN QUERY SELECT FALSE, 'La visita ya está cancelada'::TEXT;
        RETURN;
    END IF;

    IF estado_actual = 'REALIZADA' THEN
        RETURN QUERY SELECT FALSE, 'No se puede cancelar una visita ya realizada'::TEXT;
        RETURN;
    END IF;

    -- Cancelar visita
    UPDATE informix.agenda_visitas SET
        estado_visita = 'CANCELADA',
        observaciones_inspector = COALESCE(p_motivo_cancelacion, 'Cancelada por el usuario'),
        usuario_modificacion = 'sistema'
    WHERE id = p_id;

    RETURN QUERY SELECT TRUE, 'Visita cancelada exitosamente'::TEXT;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, ('Error al cancelar visita: ' || SQLERRM)::TEXT;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 5. SP_DEPENDENCIAS_LIST - Listar dependencias activas
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_dependencias_list()
RETURNS TABLE(
    id_dependencia INTEGER,
    descripcion VARCHAR(255),
    siglas VARCHAR(20),
    tipo_dependencia VARCHAR(50),
    responsable VARCHAR(255)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.id_dependencia,
        d.descripcion,
        d.siglas,
        d.tipo_dependencia,
        d.responsable
    FROM informix.dependencias d
    WHERE d.activa = TRUE
    ORDER BY d.descripcion;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 6. SP_AGENDA_VISITAS_ESTADISTICAS - Estadísticas de visitas
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_agenda_visitas_estadisticas(
    p_fecha_inicio DATE,
    p_fecha_fin DATE,
    p_id_dependencia INTEGER DEFAULT NULL
)
RETURNS TABLE(
    total_visitas BIGINT,
    visitas_programadas BIGINT,
    visitas_realizadas BIGINT,
    visitas_canceladas BIGINT,
    visitas_reprogramadas BIGINT,
    dictamenes_procedentes BIGINT,
    dictamenes_no_procedentes BIGINT,
    requieren_segunda_visita BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(*) as total_visitas,
        COUNT(*) FILTER (WHERE estado_visita = 'PROGRAMADA') as visitas_programadas,
        COUNT(*) FILTER (WHERE estado_visita = 'REALIZADA') as visitas_realizadas,
        COUNT(*) FILTER (WHERE estado_visita = 'CANCELADA') as visitas_canceladas,
        COUNT(*) FILTER (WHERE estado_visita = 'REPROGRAMADA') as visitas_reprogramadas,
        COUNT(*) FILTER (WHERE dictamen = 'PROCEDENTE') as dictamenes_procedentes,
        COUNT(*) FILTER (WHERE dictamen = 'NO_PROCEDENTE') as dictamenes_no_procedentes,
        COUNT(*) FILTER (WHERE requiere_segunda_visita = TRUE) as requieren_segunda_visita
    FROM informix.agenda_visitas
    WHERE fecha_visita >= p_fecha_inicio
      AND fecha_visita <= p_fecha_fin
      AND (p_id_dependencia IS NULL OR id_dependencia = p_id_dependencia);
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- DATOS DE PRUEBA
-- =====================================================================================

-- Insertar dependencias de prueba
INSERT INTO informix.dependencias (descripcion, siglas, tipo_dependencia, responsable)
VALUES
    ('Dirección de Padrón y Licencias', 'DPL', 'OPERATIVA', 'Juan Pérez López'),
    ('Dirección de Inspección y Vigilancia', 'DIV', 'OPERATIVA', 'María González'),
    ('Unidad de Protección Civil', 'UPC', 'SEGURIDAD', 'Carlos Martínez'),
    ('Dirección de Medio Ambiente', 'DMA', 'REGULATORIA', 'Ana López'),
    ('Dirección de Obras Públicas', 'DOP', 'INFRAESTRUCTURA', 'Roberto Sánchez');

-- Insertar visitas de prueba
INSERT INTO informix.agenda_visitas (
    fecha_visita, hora_visita, turno, id_tramite, id_dependencia,
    zona, subzona, domicilio_completo, propietario, actividad, estado_visita
) VALUES
    (CURRENT_DATE, '09:00:00', 'MATUTINO', 'TRM-2025-001', 1,
     'A', '01', 'AV. JUÁREZ 123, COL. CENTRO', 'JUAN GARCÍA', 'ABARROTES', 'PROGRAMADA'),

    (CURRENT_DATE + INTERVAL '1 day', '10:30:00', 'MATUTINO', 'TRM-2025-002', 2,
     'B', '02', 'CALLE INDEPENDENCIA 456', 'MARÍA LÓPEZ', 'RESTAURANTE', 'PROGRAMADA'),

    (CURRENT_DATE + INTERVAL '2 days', '15:00:00', 'VESPERTINO', 'TRM-2025-003', 3,
     'C', '03', 'AV. AMÉRICAS 789', 'CARLOS RUIZ', 'FARMACIA', 'PROGRAMADA'),

    (CURRENT_DATE - INTERVAL '1 day', '11:00:00', 'MATUTINO', 'TRM-2025-004', 1,
     'A', '04', 'PLAZA DEL SOL LOCAL 234', 'ANA MARTÍNEZ', 'ROPA', 'REALIZADA'),

    (CURRENT_DATE - INTERVAL '2 days', '16:30:00', 'VESPERTINO', 'TRM-2025-005', 2,
     'B', '05', 'CALLE MORELOS 567', 'PEDRO HERNÁNDEZ', 'SERVICIOS', 'CANCELADA');

-- =====================================================================================
-- PERMISOS Y COMENTARIOS
-- =====================================================================================

-- Comentarios en las tablas y funciones
COMMENT ON TABLE informix.agenda_visitas IS 'Agenda de visitas de inspección municipal';
COMMENT ON TABLE informix.dependencias IS 'Catálogo de dependencias municipales';
COMMENT ON FUNCTION informix.sp_agenda_visitas_list IS 'Lista visitas con filtros';
COMMENT ON FUNCTION informix.sp_agenda_visitas_create IS 'Programa nueva visita';
COMMENT ON FUNCTION informix.sp_agenda_visitas_update IS 'Actualiza visita existente';
COMMENT ON FUNCTION informix.sp_agenda_visitas_cancelar IS 'Cancela visita programada';
COMMENT ON FUNCTION informix.sp_dependencias_list IS 'Lista dependencias activas';
COMMENT ON FUNCTION informix.sp_agenda_visitas_estadisticas IS 'Estadísticas de visitas';

-- =====================================================================================
-- FIN DEL ARCHIVO
-- =====================================================================================