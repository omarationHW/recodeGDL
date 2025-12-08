-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Componente: TIPOBLOQUEOFRM
-- Archivo: TIPOBLOQUEOFRM_all_procedures_IMPLEMENTED.sql
-- Generado: 2025-11-20
-- Total SPs: 7
-- Descripción: Gestión completa del catálogo de tipos de bloqueo
-- ============================================

-- ============================================
-- SP 1/7: sp_tipobloqueo_list
-- Tipo: List/Read
-- Descripción: Lista todos los tipos de bloqueo activos
-- Parámetros: Ninguno
-- Retorna: TABLE(id, descripcion, sel_cons)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_tipobloqueo_list()
RETURNS TABLE(
    id INTEGER,
    descripcion VARCHAR,
    sel_cons CHAR(1)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Retornar todos los tipos de bloqueo activos
    RETURN QUERY
    SELECT
        t.id,
        t.descripcion,
        t.sel_cons
    FROM public.c_tipobloqueo t
    WHERE t.sel_cons = 'S'
    ORDER BY t.id;
END;
$$;

COMMENT ON FUNCTION public.sp_tipobloqueo_list() IS
'Lista todos los tipos de bloqueo activos (sel_cons = S) ordenados por ID';

-- ============================================
-- SP 2/7: sp_tipobloqueo_get
-- Tipo: Read
-- Descripción: Obtiene un tipo de bloqueo específico por ID
-- Parámetros: p_id (INTEGER)
-- Retorna: TABLE(id, descripcion, sel_cons)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_tipobloqueo_get(
    p_id INTEGER
)
RETURNS TABLE(
    id INTEGER,
    descripcion VARCHAR,
    sel_cons CHAR(1)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar parámetro requerido
    IF p_id IS NULL THEN
        RAISE EXCEPTION 'El parámetro p_id es requerido';
    END IF;

    -- Retornar el tipo de bloqueo solicitado
    RETURN QUERY
    SELECT
        t.id,
        t.descripcion,
        t.sel_cons
    FROM public.c_tipobloqueo t
    WHERE t.id = p_id;
END;
$$;

COMMENT ON FUNCTION public.sp_tipobloqueo_get(INTEGER) IS
'Obtiene un tipo de bloqueo específico por su ID';

-- ============================================
-- SP 3/7: sp_tipobloqueo_catalog
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de tipos de bloqueo para selección en formularios
-- Parámetros: Ninguno
-- Retorna: TABLE(id, descripcion, sel_cons)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_tipobloqueo_catalog()
RETURNS TABLE(
    id INTEGER,
    descripcion VARCHAR,
    sel_cons CHAR(1)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Retornar catálogo de tipos de bloqueo activos
    RETURN QUERY
    SELECT
        t.id,
        t.descripcion,
        t.sel_cons
    FROM public.c_tipobloqueo t
    WHERE t.sel_cons = 'S'
    ORDER BY t.descripcion;
END;
$$;

COMMENT ON FUNCTION public.sp_tipobloqueo_catalog() IS
'Catálogo de tipos de bloqueo activos para selección en formularios, ordenados por descripción';

-- ============================================
-- SP 4/7: sp_tipobloqueo_create
-- Tipo: Create
-- Descripción: Crea un nuevo tipo de bloqueo
-- Parámetros: p_descripcion (VARCHAR), p_sel_cons (CHAR(1))
-- Retorna: TABLE(success, message, id)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_tipobloqueo_create(
    p_descripcion VARCHAR,
    p_sel_cons CHAR(1) DEFAULT 'S'
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    id INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_id INTEGER;
    v_exists INTEGER;
    v_descripcion_clean VARCHAR;
BEGIN
    -- Validar que la descripción no esté vacía
    IF p_descripcion IS NULL OR TRIM(p_descripcion) = '' THEN
        RETURN QUERY SELECT FALSE, 'La descripción es requerida.'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    -- Limpiar y normalizar descripción
    v_descripcion_clean := UPPER(TRIM(p_descripcion));

    -- Validar que no exista una descripción igual
    SELECT COUNT(*) INTO v_exists
    FROM public.c_tipobloqueo
    WHERE UPPER(TRIM(descripcion)) = v_descripcion_clean;

    IF v_exists > 0 THEN
        RETURN QUERY SELECT FALSE, 'Ya existe un tipo de bloqueo con esa descripción.'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar valor de sel_cons
    IF p_sel_cons NOT IN ('S', 'N') THEN
        RETURN QUERY SELECT FALSE, 'El valor de sel_cons debe ser S o N.'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    -- Insertar el nuevo registro
    INSERT INTO public.c_tipobloqueo (descripcion, sel_cons)
    VALUES (v_descripcion_clean, COALESCE(p_sel_cons, 'S'))
    RETURNING c_tipobloqueo.id INTO v_new_id;

    RETURN QUERY SELECT TRUE, 'Tipo de bloqueo creado correctamente.'::TEXT, v_new_id;
END;
$$;

COMMENT ON FUNCTION public.sp_tipobloqueo_create(VARCHAR, CHAR) IS
'Crea un nuevo tipo de bloqueo. Valida descripción única y convierte a mayúsculas';

-- ============================================
-- SP 5/7: sp_tipobloqueo_update
-- Tipo: Update
-- Descripción: Actualiza un tipo de bloqueo existente
-- Parámetros: p_id (INTEGER), p_descripcion (VARCHAR), p_sel_cons (CHAR(1))
-- Retorna: TABLE(success, message)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_tipobloqueo_update(
    p_id INTEGER,
    p_descripcion VARCHAR,
    p_sel_cons CHAR(1) DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
    v_descripcion_clean VARCHAR;
    v_duplicate INTEGER;
BEGIN
    -- Validar que el ID sea proporcionado
    IF p_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El parámetro p_id es requerido.'::TEXT;
        RETURN;
    END IF;

    -- Validar que el ID existe
    SELECT COUNT(*) INTO v_exists
    FROM public.c_tipobloqueo
    WHERE id = p_id;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'El tipo de bloqueo no existe.'::TEXT;
        RETURN;
    END IF;

    -- Si se proporciona descripción, validarla
    IF p_descripcion IS NOT NULL THEN
        -- Validar que no esté vacía
        IF TRIM(p_descripcion) = '' THEN
            RETURN QUERY SELECT FALSE, 'La descripción no puede estar vacía.'::TEXT;
            RETURN;
        END IF;

        -- Limpiar y normalizar descripción
        v_descripcion_clean := UPPER(TRIM(p_descripcion));

        -- Validar que no exista otra descripción igual (excluyendo el registro actual)
        SELECT COUNT(*) INTO v_duplicate
        FROM public.c_tipobloqueo
        WHERE UPPER(TRIM(descripcion)) = v_descripcion_clean
        AND id != p_id;

        IF v_duplicate > 0 THEN
            RETURN QUERY SELECT FALSE, 'Ya existe otro tipo de bloqueo con esa descripción.'::TEXT;
            RETURN;
        END IF;
    END IF;

    -- Validar sel_cons si se proporciona
    IF p_sel_cons IS NOT NULL AND p_sel_cons NOT IN ('S', 'N') THEN
        RETURN QUERY SELECT FALSE, 'El valor de sel_cons debe ser S o N.'::TEXT;
        RETURN;
    END IF;

    -- Actualizar el registro
    UPDATE public.c_tipobloqueo
    SET
        descripcion = COALESCE(v_descripcion_clean, descripcion),
        sel_cons = COALESCE(p_sel_cons, sel_cons)
    WHERE id = p_id;

    RETURN QUERY SELECT TRUE, 'Tipo de bloqueo actualizado correctamente.'::TEXT;
END;
$$;

COMMENT ON FUNCTION public.sp_tipobloqueo_update(INTEGER, VARCHAR, CHAR) IS
'Actualiza un tipo de bloqueo existente. Valida descripción única y valores válidos';

-- ============================================
-- SP 6/7: sp_tipobloqueo_delete
-- Tipo: Delete (Soft Delete)
-- Descripción: Desactiva un tipo de bloqueo (soft delete)
-- Parámetros: p_id (INTEGER)
-- Retorna: TABLE(success, message)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_tipobloqueo_delete(
    p_id INTEGER
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
    v_current_status CHAR(1);
BEGIN
    -- Validar que el ID sea proporcionado
    IF p_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El parámetro p_id es requerido.'::TEXT;
        RETURN;
    END IF;

    -- Validar que el ID existe y obtener estado actual
    SELECT COUNT(*), MAX(sel_cons) INTO v_exists, v_current_status
    FROM public.c_tipobloqueo
    WHERE id = p_id;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'El tipo de bloqueo no existe.'::TEXT;
        RETURN;
    END IF;

    -- Verificar si ya está desactivado
    IF v_current_status = 'N' THEN
        RETURN QUERY SELECT FALSE, 'El tipo de bloqueo ya está desactivado.'::TEXT;
        RETURN;
    END IF;

    -- Desactivar el registro (soft delete)
    UPDATE public.c_tipobloqueo
    SET sel_cons = 'N'
    WHERE id = p_id;

    RETURN QUERY SELECT TRUE, 'Tipo de bloqueo desactivado correctamente.'::TEXT;
END;
$$;

COMMENT ON FUNCTION public.sp_tipobloqueo_delete(INTEGER) IS
'Desactiva (soft delete) un tipo de bloqueo cambiando sel_cons a N';

-- ============================================
-- SP 7/7: sp_tipobloqueo_reactivate
-- Tipo: Update
-- Descripción: Reactiva un tipo de bloqueo desactivado
-- Parámetros: p_id (INTEGER)
-- Retorna: TABLE(success, message)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_tipobloqueo_reactivate(
    p_id INTEGER
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
    v_current_status CHAR(1);
BEGIN
    -- Validar que el ID sea proporcionado
    IF p_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El parámetro p_id es requerido.'::TEXT;
        RETURN;
    END IF;

    -- Validar que el ID existe y obtener estado actual
    SELECT COUNT(*), MAX(sel_cons) INTO v_exists, v_current_status
    FROM public.c_tipobloqueo
    WHERE id = p_id;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'El tipo de bloqueo no existe.'::TEXT;
        RETURN;
    END IF;

    -- Verificar si ya está activo
    IF v_current_status = 'S' THEN
        RETURN QUERY SELECT FALSE, 'El tipo de bloqueo ya está activo.'::TEXT;
        RETURN;
    END IF;

    -- Reactivar el registro
    UPDATE public.c_tipobloqueo
    SET sel_cons = 'S'
    WHERE id = p_id;

    RETURN QUERY SELECT TRUE, 'Tipo de bloqueo reactivado correctamente.'::TEXT;
END;
$$;

COMMENT ON FUNCTION public.sp_tipobloqueo_reactivate(INTEGER) IS
'Reactiva un tipo de bloqueo desactivado cambiando sel_cons a S';

-- ============================================
-- ALIAS PARA COMPATIBILIDAD
-- Creando alias con nombres alternativos para compatibilidad
-- ============================================

-- Alias para sp_tipobloqueo_catalog (nombre usado en el archivo de referencia)
CREATE OR REPLACE FUNCTION public.get_tipo_bloqueo_catalog()
RETURNS TABLE(
    id INTEGER,
    descripcion VARCHAR,
    sel_cons CHAR(1)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT * FROM public.sp_tipobloqueo_catalog();
END;
$$;

COMMENT ON FUNCTION public.get_tipo_bloqueo_catalog() IS
'Alias de sp_tipobloqueo_catalog() para compatibilidad con código legacy';

-- ============================================
-- FUNCIÓN AUXILIAR: sp_tipobloqueo_list_all
-- Lista TODOS los tipos de bloqueo (incluyendo inactivos)
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_tipobloqueo_list_all()
RETURNS TABLE(
    id INTEGER,
    descripcion VARCHAR,
    sel_cons CHAR(1)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Retornar todos los tipos de bloqueo (activos e inactivos)
    RETURN QUERY
    SELECT
        t.id,
        t.descripcion,
        t.sel_cons
    FROM public.c_tipobloqueo t
    ORDER BY t.sel_cons DESC, t.id;
END;
$$;

COMMENT ON FUNCTION public.sp_tipobloqueo_list_all() IS
'Lista TODOS los tipos de bloqueo (activos e inactivos) para administración';

-- ============================================
-- NOTAS PARA LA IMPLEMENTACIÓN
-- ============================================
/*
ESTRUCTURA DE TABLA REQUERIDA:
------------------------------
CREATE TABLE public.c_tipobloqueo (
    id SERIAL PRIMARY KEY,
    descripcion VARCHAR(255) NOT NULL,
    sel_cons CHAR(1) DEFAULT 'S' CHECK (sel_cons IN ('S', 'N'))
);

ÍNDICES RECOMENDADOS:
--------------------
CREATE INDEX idx_c_tipobloqueo_sel_cons ON public.c_tipobloqueo(sel_cons);
CREATE INDEX idx_c_tipobloqueo_descripcion ON public.c_tipobloqueo(descripcion);

ENDPOINTS DEL CONTROLADOR LARAVEL:
----------------------------------
1. GET /api/execute (eRequest: "sp_tipobloqueo_list")
   - Lista tipos de bloqueo activos

2. GET /api/execute (eRequest: "sp_tipobloqueo_get", params: {id: 1})
   - Obtiene un tipo de bloqueo por ID

3. GET /api/execute (eRequest: "sp_tipobloqueo_catalog")
   - Catálogo para selects/combos

4. POST /api/execute (eRequest: "sp_tipobloqueo_create", params: {descripcion, sel_cons})
   - Crear nuevo tipo de bloqueo

5. PUT /api/execute (eRequest: "sp_tipobloqueo_update", params: {id, descripcion, sel_cons})
   - Actualizar tipo de bloqueo

6. DELETE /api/execute (eRequest: "sp_tipobloqueo_delete", params: {id})
   - Desactivar tipo de bloqueo

7. PUT /api/execute (eRequest: "sp_tipobloqueo_reactivate", params: {id})
   - Reactivar tipo de bloqueo

VALIDACIONES IMPLEMENTADAS:
---------------------------
1. Parámetros requeridos (ID, descripción)
2. Descripción única (case insensitive)
3. Valores válidos para sel_cons ('S' o 'N')
4. Existencia de registro antes de update/delete
5. Prevención de operaciones duplicadas (ya activo/inactivo)
6. Normalización automática (UPPER, TRIM)

CARACTERÍSTICAS ESPECIALES:
--------------------------
1. Soft Delete: Usa sel_cons = 'N' en lugar de DELETE físico
2. Normalización: Descripción se convierte a mayúsculas automáticamente
3. Validación de duplicados: Case insensitive con TRIM
4. Compatibilidad: Alias para funciones legacy
5. Auditoría: Ready para agregar campos fecalt, capturo, etc.
6. Transacciones: Implícitas en cada función
7. Comentarios SQL: Documentación integrada

USO DE EJEMPLO:
--------------
-- Listar activos
SELECT * FROM public.sp_tipobloqueo_list();

-- Crear nuevo
SELECT * FROM public.sp_tipobloqueo_create('BLOQUEO TEMPORAL', 'S');

-- Actualizar
SELECT * FROM public.sp_tipobloqueo_update(1, 'BLOQUEO PERMANENTE', 'S');

-- Desactivar
SELECT * FROM public.sp_tipobloqueo_delete(1);

-- Reactivar
SELECT * FROM public.sp_tipobloqueo_reactivate(1);

-- Listar todos (incluyendo inactivos)
SELECT * FROM public.sp_tipobloqueo_list_all();

INTEGRACIÓN CON VUE.JS:
----------------------
El componente Vue debe llamar a través del endpoint /api/execute:

// Listar tipos de bloqueo
axios.post('/api/execute', {
  eRequest: 'sp_tipobloqueo_list'
})

// Crear tipo de bloqueo
axios.post('/api/execute', {
  eRequest: 'sp_tipobloqueo_create',
  params: {
    descripcion: 'NUEVO TIPO',
    sel_cons: 'S'
  }
})

MIGRACION Y DESPLIEGUE:
----------------------
1. Verificar que existe la tabla c_tipobloqueo
2. Ejecutar este archivo completo en la BD padron_licencias
3. Verificar creación de las 7 funciones + alias
4. Poblar con datos iniciales si es necesario
5. Actualizar controlador Laravel para mapear eRequest a SPs
6. Actualizar componente Vue para usar las operaciones disponibles

MANTENIMIENTO:
-------------
- Revisar logs de uso para optimización
- Considerar agregar campos de auditoría (fecalt, capturo, fecmod, modifico)
- Considerar agregar histórico de cambios
- Considerar agregar validación de uso antes de delete (bloqueos asociados)
*/

-- ============================================
-- FIN DE STORED PROCEDURES - TIPOBLOQUEOFRM
-- Total de funciones: 9 (7 principales + 1 alias + 1 auxiliar)
-- Schema: public
-- Tabla principal: c_tipobloqueo
-- ============================================
