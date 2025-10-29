-- ================================================
-- Stored Procedures para Búsqueda de Códigos SCIAN
-- Sistema de Clasificación Industrial de América del Norte
-- Base: padron_licencias
-- Fecha: 2024-12-30
-- ================================================

-- ================================================
-- SP_BUSQUEDA_SCIAN_LIST
-- Búsqueda de códigos SCIAN con filtros
-- ================================================
CREATE PROCEDURE SP_BUSQUEDA_SCIAN_LIST(
    p_codigo_scian VARCHAR(10) DEFAULT NULL,
    p_descripcion VARCHAR(255) DEFAULT NULL,
    p_nivel VARCHAR(2) DEFAULT NULL,
    p_sector VARCHAR(3) DEFAULT NULL,
    p_activo CHAR(1) DEFAULT 'S',
    p_limite INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)

RETURNING
    codigo_scian VARCHAR(10),
    descripcion LVARCHAR(500),
    nivel CHAR(2),
    sector VARCHAR(3),
    subsector VARCHAR(4),
    rama VARCHAR(5),
    subrama VARCHAR(6),
    clase VARCHAR(7),
    activo CHAR(1),
    fecha_alta DATE,
    fecha_actualizacion DATE,
    total_empresas INTEGER;

DEFINE v_sql LVARCHAR(2000);
DEFINE v_where LVARCHAR(1000);
DEFINE v_count INTEGER DEFAULT 0;

-- Construir cláusula WHERE dinámicamente
LET v_where = " WHERE 1=1 ";

-- Filtro por código SCIAN
IF p_codigo_scian IS NOT NULL AND LENGTH(TRIM(p_codigo_scian)) > 0 THEN
    LET v_where = v_where || " AND codigo_scian LIKE '%" || TRIM(p_codigo_scian) || "%' ";
END IF;

-- Filtro por descripción
IF p_descripcion IS NOT NULL AND LENGTH(TRIM(p_descripcion)) > 0 THEN
    LET v_where = v_where || " AND UPPER(descripcion) LIKE '%" || UPPER(TRIM(p_descripcion)) || "%' ";
END IF;

-- Filtro por nivel (1=Sector, 2=Subsector, 3=Rama, 4=Subrama, 5=Clase)
IF p_nivel IS NOT NULL AND LENGTH(TRIM(p_nivel)) > 0 THEN
    LET v_where = v_where || " AND nivel = '" || TRIM(p_nivel) || "' ";
END IF;

-- Filtro por sector
IF p_sector IS NOT NULL AND LENGTH(TRIM(p_sector)) > 0 THEN
    LET v_where = v_where || " AND sector = '" || TRIM(p_sector) || "' ";
END IF;

-- Filtro por activo
IF p_activo IS NOT NULL THEN
    LET v_where = v_where || " AND activo = '" || p_activo || "' ";
END IF;

-- Construir query completa
LET v_sql = "SELECT " ||
    "s.codigo_scian, " ||
    "s.descripcion, " ||
    "s.nivel, " ||
    "s.sector, " ||
    "s.subsector, " ||
    "s.rama, " ||
    "s.subrama, " ||
    "s.clase, " ||
    "s.activo, " ||
    "s.fecha_alta, " ||
    "s.fecha_actualizacion, " ||
    "COALESCE(COUNT(g.codigo_scian), 0) as total_empresas " ||
    "FROM cat_scian s " ||
    "LEFT JOIN cat_giros g ON s.codigo_scian = g.codigo_scian " ||
    v_where ||
    "GROUP BY s.codigo_scian, s.descripcion, s.nivel, s.sector, s.subsector, " ||
    "s.rama, s.subrama, s.clase, s.activo, s.fecha_alta, s.fecha_actualizacion " ||
    "ORDER BY s.codigo_scian " ||
    "LIMIT " || p_limite || " OFFSET " || p_offset;

-- Ejecutar query dinámico
PREPARE stmt FROM v_sql;
EXECUTE stmt;

END PROCEDURE;

-- ================================================
-- SP_BUSQUEDA_SCIAN_GET
-- Obtener detalle completo de un código SCIAN
-- ================================================
CREATE PROCEDURE SP_BUSQUEDA_SCIAN_GET(
    p_codigo_scian VARCHAR(10)
)

RETURNING
    codigo_scian VARCHAR(10),
    descripcion LVARCHAR(500),
    nivel CHAR(2),
    sector VARCHAR(3),
    subsector VARCHAR(4),
    rama VARCHAR(5),
    subrama VARCHAR(6),
    clase VARCHAR(7),
    activo CHAR(1),
    fecha_alta DATE,
    fecha_actualizacion DATE,
    total_empresas INTEGER,
    total_licencias INTEGER,
    total_tramites INTEGER,
    desc_sector LVARCHAR(200),
    desc_subsector LVARCHAR(200),
    desc_rama LVARCHAR(200);

SELECT
    s.codigo_scian,
    s.descripcion,
    s.nivel,
    s.sector,
    s.subsector,
    s.rama,
    s.subrama,
    s.clase,
    s.activo,
    s.fecha_alta,
    s.fecha_actualizacion,
    COALESCE(emp_count.total, 0) as total_empresas,
    COALESCE(lic_count.total, 0) as total_licencias,
    COALESCE(tram_count.total, 0) as total_tramites,
    sect.descripcion as desc_sector,
    subs.descripcion as desc_subsector,
    rama.descripcion as desc_rama
FROM cat_scian s
LEFT JOIN (
    SELECT codigo_scian, COUNT(*) as total
    FROM cat_giros
    WHERE codigo_scian = p_codigo_scian
    GROUP BY codigo_scian
) emp_count ON s.codigo_scian = emp_count.codigo_scian
LEFT JOIN (
    SELECT g.codigo_scian, COUNT(*) as total
    FROM cat_giros g
    INNER JOIN licencias l ON g.id_giro = l.id_giro
    WHERE g.codigo_scian = p_codigo_scian
    GROUP BY g.codigo_scian
) lic_count ON s.codigo_scian = lic_count.codigo_scian
LEFT JOIN (
    SELECT g.codigo_scian, COUNT(*) as total
    FROM cat_giros g
    INNER JOIN tramites t ON g.id_giro = t.id_giro
    WHERE g.codigo_scian = p_codigo_scian
    GROUP BY g.codigo_scian
) tram_count ON s.codigo_scian = tram_count.codigo_scian
LEFT JOIN cat_scian sect ON s.sector = sect.codigo_scian AND sect.nivel = '1'
LEFT JOIN cat_scian subs ON s.subsector = subs.codigo_scian AND subs.nivel = '2'
LEFT JOIN cat_scian rama ON s.rama = rama.codigo_scian AND rama.nivel = '3'
WHERE s.codigo_scian = p_codigo_scian;

END PROCEDURE;

-- ================================================
-- SP_BUSQUEDA_SCIAN_CREATE
-- Crear nuevo código SCIAN
-- ================================================
CREATE PROCEDURE SP_BUSQUEDA_SCIAN_CREATE(
    p_codigo_scian VARCHAR(10),
    p_descripcion LVARCHAR(500),
    p_nivel CHAR(2),
    p_sector VARCHAR(3) DEFAULT NULL,
    p_subsector VARCHAR(4) DEFAULT NULL,
    p_rama VARCHAR(5) DEFAULT NULL,
    p_subrama VARCHAR(6) DEFAULT NULL,
    p_clase VARCHAR(7) DEFAULT NULL,
    p_activo CHAR(1) DEFAULT 'S'
)

RETURNING
    codigo_scian VARCHAR(10),
    resultado VARCHAR(20),
    mensaje LVARCHAR(255);

DEFINE v_exists INTEGER DEFAULT 0;
DEFINE v_error CHAR(1) DEFAULT 'N';
DEFINE v_mensaje LVARCHAR(255);

-- Validar que no exista el código
SELECT COUNT(*) INTO v_exists
FROM cat_scian
WHERE codigo_scian = p_codigo_scian;

IF v_exists > 0 THEN
    LET v_error = 'S';
    LET v_mensaje = 'El código SCIAN ' || p_codigo_scian || ' ya existe';
ELSE
    -- Insertar nuevo código SCIAN
    INSERT INTO cat_scian (
        codigo_scian,
        descripcion,
        nivel,
        sector,
        subsector,
        rama,
        subrama,
        clase,
        activo,
        fecha_alta,
        fecha_actualizacion
    ) VALUES (
        p_codigo_scian,
        p_descripcion,
        p_nivel,
        p_sector,
        p_subsector,
        p_rama,
        p_subrama,
        p_clase,
        p_activo,
        TODAY,
        TODAY
    );

    LET v_mensaje = 'Código SCIAN creado exitosamente';
END IF;

RETURN
    p_codigo_scian,
    CASE WHEN v_error = 'S' THEN 'ERROR' ELSE 'SUCCESS' END,
    v_mensaje;

END PROCEDURE;

-- ================================================
-- SP_BUSQUEDA_SCIAN_UPDATE
-- Actualizar código SCIAN existente
-- ================================================
CREATE PROCEDURE SP_BUSQUEDA_SCIAN_UPDATE(
    p_codigo_scian VARCHAR(10),
    p_descripcion LVARCHAR(500),
    p_nivel CHAR(2),
    p_sector VARCHAR(3) DEFAULT NULL,
    p_subsector VARCHAR(4) DEFAULT NULL,
    p_rama VARCHAR(5) DEFAULT NULL,
    p_subrama VARCHAR(6) DEFAULT NULL,
    p_clase VARCHAR(7) DEFAULT NULL,
    p_activo CHAR(1) DEFAULT 'S'
)

RETURNING
    codigo_scian VARCHAR(10),
    resultado VARCHAR(20),
    mensaje LVARCHAR(255);

DEFINE v_exists INTEGER DEFAULT 0;
DEFINE v_error CHAR(1) DEFAULT 'N';
DEFINE v_mensaje LVARCHAR(255);

-- Validar que exista el código
SELECT COUNT(*) INTO v_exists
FROM cat_scian
WHERE codigo_scian = p_codigo_scian;

IF v_exists = 0 THEN
    LET v_error = 'S';
    LET v_mensaje = 'El código SCIAN ' || p_codigo_scian || ' no existe';
ELSE
    -- Actualizar código SCIAN
    UPDATE cat_scian SET
        descripcion = p_descripcion,
        nivel = p_nivel,
        sector = p_sector,
        subsector = p_subsector,
        rama = p_rama,
        subrama = p_subrama,
        clase = p_clase,
        activo = p_activo,
        fecha_actualizacion = TODAY
    WHERE codigo_scian = p_codigo_scian;

    LET v_mensaje = 'Código SCIAN actualizado exitosamente';
END IF;

RETURN
    p_codigo_scian,
    CASE WHEN v_error = 'S' THEN 'ERROR' ELSE 'SUCCESS' END,
    v_mensaje;

END PROCEDURE;

-- ================================================
-- SP_BUSQUEDA_SCIAN_DELETE
-- Eliminar (desactivar) código SCIAN
-- ================================================
CREATE PROCEDURE SP_BUSQUEDA_SCIAN_DELETE(
    p_codigo_scian VARCHAR(10)
)

RETURNING
    codigo_scian VARCHAR(10),
    resultado VARCHAR(20),
    mensaje LVARCHAR(255);

DEFINE v_exists INTEGER DEFAULT 0;
DEFINE v_en_uso INTEGER DEFAULT 0;
DEFINE v_error CHAR(1) DEFAULT 'N';
DEFINE v_mensaje LVARCHAR(255);

-- Validar que exista el código
SELECT COUNT(*) INTO v_exists
FROM cat_scian
WHERE codigo_scian = p_codigo_scian;

IF v_exists = 0 THEN
    LET v_error = 'S';
    LET v_mensaje = 'El código SCIAN ' || p_codigo_scian || ' no existe';
ELSE
    -- Verificar si está en uso
    SELECT COUNT(*) INTO v_en_uso
    FROM cat_giros
    WHERE codigo_scian = p_codigo_scian;

    IF v_en_uso > 0 THEN
        -- Solo desactivar si está en uso
        UPDATE cat_scian SET
            activo = 'N',
            fecha_actualizacion = TODAY
        WHERE codigo_scian = p_codigo_scian;

        LET v_mensaje = 'Código SCIAN desactivado (está en uso por ' || v_en_uso || ' giros)';
    ELSE
        -- Eliminar físicamente si no está en uso
        DELETE FROM cat_scian
        WHERE codigo_scian = p_codigo_scian;

        LET v_mensaje = 'Código SCIAN eliminado exitosamente';
    END IF;
END IF;

RETURN
    p_codigo_scian,
    CASE WHEN v_error = 'S' THEN 'ERROR' ELSE 'SUCCESS' END,
    v_mensaje;

END PROCEDURE;

-- ================================================
-- SP_BUSQUEDA_SCIAN_ESTADISTICAS
-- Obtener estadísticas de códigos SCIAN
-- ================================================
CREATE PROCEDURE SP_BUSQUEDA_SCIAN_ESTADISTICAS()

RETURNING
    concepto VARCHAR(50),
    total INTEGER,
    porcentaje DECIMAL(5,2);

-- Total de códigos SCIAN por nivel
SELECT 'Total Sectores' as concepto, COUNT(*) as total,
       ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM cat_scian WHERE activo = 'S')), 2) as porcentaje
FROM cat_scian
WHERE nivel = '1' AND activo = 'S'
UNION ALL
SELECT 'Total Subsectores', COUNT(*),
       ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM cat_scian WHERE activo = 'S')), 2)
FROM cat_scian
WHERE nivel = '2' AND activo = 'S'
UNION ALL
SELECT 'Total Ramas', COUNT(*),
       ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM cat_scian WHERE activo = 'S')), 2)
FROM cat_scian
WHERE nivel = '3' AND activo = 'S'
UNION ALL
SELECT 'Total Subramas', COUNT(*),
       ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM cat_scian WHERE activo = 'S')), 2)
FROM cat_scian
WHERE nivel = '4' AND activo = 'S'
UNION ALL
SELECT 'Total Clases', COUNT(*),
       ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM cat_scian WHERE activo = 'S')), 2)
FROM cat_scian
WHERE nivel = '5' AND activo = 'S'
UNION ALL
SELECT 'Total Activos', COUNT(*), 100.00
FROM cat_scian
WHERE activo = 'S'
UNION ALL
SELECT 'Total Inactivos', COUNT(*),
       ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM cat_scian)), 2)
FROM cat_scian
WHERE activo = 'N'
UNION ALL
SELECT 'Códigos con Giros', COUNT(DISTINCT s.codigo_scian),
       ROUND((COUNT(DISTINCT s.codigo_scian) * 100.0 / (SELECT COUNT(*) FROM cat_scian WHERE activo = 'S')), 2)
FROM cat_scian s
INNER JOIN cat_giros g ON s.codigo_scian = g.codigo_scian
WHERE s.activo = 'S'
ORDER BY concepto;

END PROCEDURE;

-- ================================================
-- Comentarios adicionales:
--
-- Tabla cat_scian esperada:
-- - codigo_scian VARCHAR(10) PRIMARY KEY
-- - descripcion LVARCHAR(500)
-- - nivel CHAR(2) -- '1'=Sector, '2'=Subsector, '3'=Rama, '4'=Subrama, '5'=Clase
-- - sector VARCHAR(3) -- Código del sector (primeros 2 dígitos)
-- - subsector VARCHAR(4) -- Código del subsector (primeros 3 dígitos)
-- - rama VARCHAR(5) -- Código de la rama (primeros 4 dígitos)
-- - subrama VARCHAR(6) -- Código de la subrama (primeros 5 dígitos)
-- - clase VARCHAR(7) -- Código completo de la clase (6 dígitos)
-- - activo CHAR(1) DEFAULT 'S'
-- - fecha_alta DATE
-- - fecha_actualizacion DATE
--
-- Tabla cat_giros relacionada:
-- - id_giro SERIAL PRIMARY KEY
-- - codigo_scian VARCHAR(10) REFERENCES cat_scian
-- - descripcion LVARCHAR(500)
-- - otros_campos...
-- ================================================