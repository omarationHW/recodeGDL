-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: SP_TIPOBLOQUEO (EXACTO del archivo original)
-- Archivo: 30_SP_LICENCIAS_SP_TIPOBLOQUEO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 1/5: SP_TIPOBLOQUEO_LIST
-- Tipo: List/Read
-- Descripción: Lista todos los tipos de bloqueo activos
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_TIPOBLOQUEO_LIST()
RETURNS TABLE(id integer, descripcion varchar, sel_cons char(1))
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT t.id, t.descripcion, t.sel_cons
    FROM c_tipobloqueo t
    WHERE t.sel_cons = 'S'
    ORDER BY t.id;
END;
$$;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: SP_TIPOBLOQUEO (EXACTO del archivo original)
-- Archivo: 30_SP_LICENCIAS_SP_TIPOBLOQUEO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 3/5: SP_TIPOBLOQUEO_CREATE
-- Tipo: Create
-- Descripción: Crea un nuevo tipo de bloqueo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_TIPOBLOQUEO_CREATE(
    p_descripcion varchar,
    p_sel_cons char(1) DEFAULT 'S'
)
RETURNS TABLE(success boolean, message text, id integer)
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_id integer;
    v_exists integer;
BEGIN
    -- Validar que la descripción no esté vacía
    IF p_descripcion IS NULL OR trim(p_descripcion) = '' THEN
        RETURN QUERY SELECT false, 'La descripción es requerida.', null::integer;
        RETURN;
    END IF;
    
    -- Validar que no exista una descripción igual
    SELECT COUNT(*) INTO v_exists 
    FROM c_tipobloqueo 
    WHERE upper(trim(descripcion)) = upper(trim(p_descripcion));
    
    IF v_exists > 0 THEN
        RETURN QUERY SELECT false, 'Ya existe un tipo de bloqueo con esa descripción.', null::integer;
        RETURN;
    END IF;
    
    -- Insertar el nuevo registro
    INSERT INTO c_tipobloqueo (descripcion, sel_cons)
    VALUES (upper(trim(p_descripcion)), COALESCE(p_sel_cons, 'S'))
    RETURNING c_tipobloqueo.id INTO v_new_id;
    
    RETURN QUERY SELECT true, 'Tipo de bloqueo creado correctamente.', v_new_id;
END;
$$;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: SP_TIPOBLOQUEO (EXACTO del archivo original)
-- Archivo: 30_SP_LICENCIAS_SP_TIPOBLOQUEO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 5/5: SP_TIPOBLOQUEO_DELETE
-- Tipo: Delete
-- Descripción: Desactiva un tipo de bloqueo (soft delete)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_TIPOBLOQUEO_DELETE(p_id integer)
RETURNS TABLE(success boolean, message text)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists integer;
    v_in_use integer;
BEGIN
    -- Validar que el ID existe
    SELECT COUNT(*) INTO v_exists 
    FROM c_tipobloqueo 
    WHERE id = p_id;
    
    IF v_exists = 0 THEN
        RETURN QUERY SELECT false, 'El tipo de bloqueo no existe.';
        RETURN;
    END IF;
    
    -- Verificar si está en uso (opcional - descomentar si existe tabla de bloqueos)
    -- SELECT COUNT(*) INTO v_in_use 
    -- FROM bloqueos_licencia 
    -- WHERE tipo_bloqueo_id = p_id;
    
    -- IF v_in_use > 0 THEN
    --     RETURN QUERY SELECT false, 'No se puede eliminar porque está siendo utilizado.';
    --     RETURN;
    -- END IF;
    
    -- Desactivar el registro (soft delete)
    UPDATE c_tipobloqueo 
    SET sel_cons = 'N'
    WHERE id = p_id;
    
    RETURN QUERY SELECT true, 'Tipo de bloqueo desactivado correctamente.';
END;
$$;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: SP_TIPOBLOQUEO (EXACTO del archivo original)
-- Archivo: 30_SP_LICENCIAS_SP_TIPOBLOQUEO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP Auxiliar: SP_TIPOBLOQUEO_REACTIVATE
-- Tipo: Update
-- Descripción: Reactiva un tipo de bloqueo desactivado
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_TIPOBLOQUEO_REACTIVATE(p_id integer)
RETURNS TABLE(success boolean, message text)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists integer;
BEGIN
    -- Validar que el ID existe
    SELECT COUNT(*) INTO v_exists 
    FROM c_tipobloqueo 
    WHERE id = p_id;
    
    IF v_exists = 0 THEN
        RETURN QUERY SELECT false, 'El tipo de bloqueo no existe.';
        RETURN;
    END IF;
    
    -- Reactivar el registro
    UPDATE c_tipobloqueo 
    SET sel_cons = 'S'
    WHERE id = p_id;
    
    RETURN QUERY SELECT true, 'Tipo de bloqueo reactivado correctamente.';
END;
$$;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: SP_TIPOBLOQUEO (EXACTO del archivo original)
-- Archivo: 30_SP_LICENCIAS_SP_TIPOBLOQUEO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

/*
NOTAS PARA LA IMPLEMENTACIÓN:

1. Tabla requerida: c_tipobloqueo
   - id (integer, primary key, autoincrement)
   - descripcion (varchar)
   - sel_cons (char(1), default 'S')

2. Endpoints del controlador Laravel:
   - getTipoBloqueo -> SP_TIPOBLOQUEO_LIST()
   - getTipoBloqueoById -> SP_TIPOBLOQUEO_GET(id)
   - createTipoBloqueo -> SP_TIPOBLOQUEO_CREATE(desc, sel_cons)
   - updateTipoBloqueo -> SP_TIPOBLOQUEO_UPDATE(id, desc, sel_cons)
   - deleteTipoBloqueo -> SP_TIPOBLOQUEO_DELETE(id)

3. Validaciones implementadas:
   - Descripción requerida y no vacía
   - Descripción única (case insensitive)
   - Existencia de registro antes de update/delete
   - Soft delete (sel_cons = 'N' en lugar de DELETE físico)

4. Campos automáticos:
   - Descripción se convierte a mayúsculas automáticamente
   - sel_cons por defecto es 'S' (activo)
*/