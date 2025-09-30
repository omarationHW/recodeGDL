-- ============================================
-- STORED PROCEDURES MIGRADOS - INFORMIX
-- Formulario: CONSULTAUSUARIOSFRM
-- Archivo: 11_SP_LICENCIAS_CONSULTAUSUARIOS_INFORMIX.sql
-- Migración desde PostgreSQL a INFORMIX
-- Fecha: 2025-09-24
-- Total SPs: 4
-- ============================================

-- SP 1/4: SP_CONSULTAUSUARIOS_LIST
-- Tipo: Catalog
-- Descripción: Lista usuarios del sistema con paginación y filtros opcionales
-- Parámetros entrada: p_page (INTEGER), p_limit (INTEGER), p_search (LVARCHAR opcional)
-- Parámetros salida: usuario, cvedepto, nombres, clave, nivel, fecalt, fecbaj, feccap, capturo, total_records
-- --------------------------------------------

CREATE PROCEDURE SP_CONSULTAUSUARIOS_LIST(
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 10,
    p_search LVARCHAR(255) DEFAULT ''
)
RETURNING LVARCHAR(8) AS usuario,
          INTEGER AS cvedepto,
          LVARCHAR(30) AS nombres,
          LVARCHAR(8) AS clave,
          INTEGER AS nivel,
          DATETIME YEAR TO SECOND AS fecalt,
          DATETIME YEAR TO SECOND AS fecbaj,
          DATETIME YEAR TO SECOND AS feccap,
          LVARCHAR(8) AS capturo,
          INTEGER AS total_records;

DEFINE v_offset INTEGER;
DEFINE v_total_count INTEGER;

    -- Calcular offset para paginación
    LET v_offset = (p_page - 1) * p_limit;

    -- Obtener total de registros que coinciden con la búsqueda
    IF p_search IS NULL OR p_search = '' THEN
        SELECT COUNT(*) INTO v_total_count FROM usuarios;
    ELSE
        SELECT COUNT(*) INTO v_total_count
        FROM usuarios
        WHERE UPPER(usuario) LIKE '%' || UPPER(p_search) || '%'
           OR UPPER(nombres) LIKE '%' || UPPER(p_search) || '%'
           OR CAST(cvedepto AS LVARCHAR) LIKE '%' || p_search || '%'
           OR CAST(nivel AS LVARCHAR) LIKE '%' || p_search || '%';
    END IF;

    -- Retornar resultados paginados
    IF p_search IS NULL OR p_search = '' THEN
        RETURN
            u.usuario,
            u.cvedepto,
            u.nombres,
            u.clave,
            u.nivel,
            u.fecalt,
            u.fecbaj,
            u.feccap,
            u.capturo,
            v_total_count AS total_records
        FROM usuarios u
        ORDER BY u.usuario
        SKIP v_offset
        FIRST p_limit;
    ELSE
        RETURN
            u.usuario,
            u.cvedepto,
            u.nombres,
            u.clave,
            u.nivel,
            u.fecalt,
            u.fecbaj,
            u.feccap,
            u.capturo,
            v_total_count AS total_records
        FROM usuarios u
        WHERE UPPER(u.usuario) LIKE '%' || UPPER(p_search) || '%'
           OR UPPER(u.nombres) LIKE '%' || UPPER(p_search) || '%'
           OR CAST(u.cvedepto AS LVARCHAR) LIKE '%' || p_search || '%'
           OR CAST(u.nivel AS LVARCHAR) LIKE '%' || p_search || '%'
        ORDER BY u.usuario
        SKIP v_offset
        FIRST p_limit;
    END IF;

END PROCEDURE;

-- SP 2/4: SP_CONSULTAUSUARIOS_CREATE
-- Tipo: CRUD
-- Descripción: Crea un nuevo usuario en el sistema
-- Parámetros entrada: p_usuario (LVARCHAR), p_cvedepto (INTEGER), p_nombres (LVARCHAR), p_clave (LVARCHAR), p_nivel (INTEGER), p_capturo (LVARCHAR)
-- Parámetros salida: success (INTEGER), message (LVARCHAR)
-- --------------------------------------------

CREATE PROCEDURE SP_CONSULTAUSUARIOS_CREATE(
    p_usuario LVARCHAR(8),
    p_cvedepto INTEGER,
    p_nombres LVARCHAR(30),
    p_clave LVARCHAR(8),
    p_nivel INTEGER,
    p_capturo LVARCHAR(8)
)
RETURNING INTEGER AS success,
          LVARCHAR(255) AS message;

DEFINE v_exists INTEGER;

    -- Verificar si el usuario ya existe
    SELECT COUNT(*) INTO v_exists
    FROM usuarios
    WHERE usuario = p_usuario;

    IF v_exists > 0 THEN
        RETURN 0, 'El usuario ya existe';
    END IF;

    -- Validar nivel
    IF p_nivel NOT IN (1, 5, 9, 10) THEN
        RETURN 0, 'Nivel de usuario inválido. Debe ser 1, 5, 9 o 10';
    END IF;

    -- Insertar nuevo usuario
    INSERT INTO usuarios (
        usuario, cvedepto, nombres, clave, nivel,
        fecalt, feccap, capturo
    ) VALUES (
        p_usuario, p_cvedepto, p_nombres, p_clave, p_nivel,
        TODAY, CURRENT YEAR TO SECOND, p_capturo
    );

    RETURN 1, 'Usuario creado exitosamente';

END PROCEDURE;

-- SP 3/4: SP_CONSULTAUSUARIOS_UPDATE
-- Tipo: CRUD
-- Descripción: Actualiza un usuario existente
-- Parámetros entrada: p_usuario (LVARCHAR), p_cvedepto (INTEGER), p_nombres (LVARCHAR), p_clave (LVARCHAR), p_nivel (INTEGER), p_fecbaj (DATE), p_capturo (LVARCHAR)
-- Parámetros salida: success (INTEGER), message (LVARCHAR)
-- --------------------------------------------

CREATE PROCEDURE SP_CONSULTAUSUARIOS_UPDATE(
    p_usuario LVARCHAR(8),
    p_cvedepto INTEGER,
    p_nombres LVARCHAR(30),
    p_clave LVARCHAR(8),
    p_nivel INTEGER,
    p_fecbaj DATE,
    p_capturo LVARCHAR(8)
)
RETURNING INTEGER AS success,
          LVARCHAR(255) AS message;

DEFINE v_exists INTEGER;

    -- Verificar si el usuario existe
    SELECT COUNT(*) INTO v_exists
    FROM usuarios
    WHERE usuario = p_usuario;

    IF v_exists = 0 THEN
        RETURN 0, 'El usuario no existe';
    END IF;

    -- Validar nivel
    IF p_nivel NOT IN (1, 5, 9, 10) THEN
        RETURN 0, 'Nivel de usuario inválido. Debe ser 1, 5, 9 o 10';
    END IF;

    -- Actualizar usuario
    IF p_clave IS NOT NULL AND p_clave != '' THEN
        -- Si se proporciona nueva clave, actualizarla también
        UPDATE usuarios
        SET cvedepto = p_cvedepto,
            nombres = p_nombres,
            clave = p_clave,
            nivel = p_nivel,
            fecbaj = p_fecbaj,
            feccap = CURRENT YEAR TO SECOND,
            capturo = p_capturo
        WHERE usuario = p_usuario;
    ELSE
        -- Si no se proporciona clave, mantener la actual
        UPDATE usuarios
        SET cvedepto = p_cvedepto,
            nombres = p_nombres,
            nivel = p_nivel,
            fecbaj = p_fecbaj,
            feccap = CURRENT YEAR TO SECOND,
            capturo = p_capturo
        WHERE usuario = p_usuario;
    END IF;

    RETURN 1, 'Usuario actualizado exitosamente';

END PROCEDURE;

-- SP 4/4: SP_CONSULTAUSUARIOS_DELETE
-- Tipo: CRUD
-- Descripción: Da de baja un usuario (soft delete)
-- Parámetros entrada: p_usuario (LVARCHAR), p_capturo (LVARCHAR)
-- Parámetros salida: success (INTEGER), message (LVARCHAR)
-- --------------------------------------------

CREATE PROCEDURE SP_CONSULTAUSUARIOS_DELETE(
    p_usuario LVARCHAR(8),
    p_capturo LVARCHAR(8)
)
RETURNING INTEGER AS success,
          LVARCHAR(255) AS message;

DEFINE v_exists INTEGER;
DEFINE v_already_deleted INTEGER;

    -- Verificar si el usuario existe
    SELECT COUNT(*) INTO v_exists
    FROM usuarios
    WHERE usuario = p_usuario;

    IF v_exists = 0 THEN
        RETURN 0, 'El usuario no existe';
    END IF;

    -- Verificar si ya está dado de baja
    SELECT COUNT(*) INTO v_already_deleted
    FROM usuarios
    WHERE usuario = p_usuario AND fecbaj IS NOT NULL;

    IF v_already_deleted > 0 THEN
        RETURN 0, 'El usuario ya está dado de baja';
    END IF;

    -- Dar de baja usuario
    UPDATE usuarios
    SET fecbaj = TODAY,
        feccap = CURRENT YEAR TO SECOND,
        capturo = p_capturo
    WHERE usuario = p_usuario;

    RETURN 1, 'Usuario dado de baja exitosamente';

END PROCEDURE;