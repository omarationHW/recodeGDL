-- ============================================================================
-- DEPLOY SCRIPT - MÓDULO ASEO CONTRATADO
-- Procedimientos Almacenados ABC (Alta, Baja, Cambio)
-- ============================================================================
-- Fecha de generación: 2025-11-26
-- Sistema: RefactorX - Guadalajara
-- Módulo: Aseo Contratado
--
-- Descripción:
-- Este script contiene todos los stored procedures necesarios para los
-- componentes ABC del módulo de Aseo Contratado.
--
-- Componentes incluidos:
-- 1. ABC_Empresas (7 SPs)
-- 2. ABC_Zonas (3 SPs)
-- 3. ABC_Tipos_Aseo (3 SPs)
-- 4. ABC_Recargos (4 SPs)
-- 5. ABC_Und_Recolec (4 SPs)
-- 6. ABC_Tipos_Emp (5 SPs)
-- 7. ABC_Cves_Operacion (5 SPs)
-- 8. ABC_Gastos (2 SPs)
-- 9. Mannto_Recaudadoras (3 SPs)
-- 10. Cons_Zonas (1 SP)
--
-- Total de SPs: 37
-- ============================================================================

-- ============================================================================
-- 1. ABC_EMPRESAS - 7 STORED PROCEDURES
-- ============================================================================

-- SP 1/7: sp_empresas_list
-- Tipo: Catalog
-- Descripción: Lista todas las empresas con su tipo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_empresas_list() RETURNS SETOF RECORD AS $$
BEGIN
  RETURN QUERY
    SELECT a.num_empresa, b.ctrol_emp, b.tipo_empresa, a.descripcion, a.representante
    FROM ta_16_empresas a
    JOIN ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
    ORDER BY a.descripcion, a.num_empresa, b.ctrol_emp;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/7: sp_empresas_get
-- Tipo: Catalog
-- Descripción: Obtiene una empresa por num_empresa y ctrol_emp
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_empresas_get(p_num_empresa INTEGER, p_ctrol_emp INTEGER) RETURNS TABLE(num_empresa INTEGER, ctrol_emp INTEGER, tipo_empresa VARCHAR, descripcion VARCHAR, representante VARCHAR) AS $$
BEGIN
  RETURN QUERY
    SELECT a.num_empresa, b.ctrol_emp, b.tipo_empresa, a.descripcion, a.representante
    FROM ta_16_empresas a
    JOIN ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
    WHERE a.num_empresa = p_num_empresa AND a.ctrol_emp = p_ctrol_emp;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/7: sp_empresas_create
-- Tipo: CRUD
-- Descripción: Crea una nueva empresa
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_empresas_create(p_ctrol_emp INTEGER, p_descripcion VARCHAR, p_representante VARCHAR) RETURNS TABLE(num_empresa INTEGER, ctrol_emp INTEGER) AS $$
DECLARE
  v_num_empresa INTEGER;
BEGIN
  SELECT COALESCE(MAX(num_empresa),0)+1 INTO v_num_empresa FROM ta_16_empresas WHERE ctrol_emp = p_ctrol_emp;
  INSERT INTO ta_16_empresas (num_empresa, ctrol_emp, descripcion, representante)
    VALUES (v_num_empresa, p_ctrol_emp, p_descripcion, p_representante);
  RETURN QUERY SELECT v_num_empresa, p_ctrol_emp;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/7: sp_empresas_update
-- Tipo: CRUD
-- Descripción: Actualiza una empresa existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_empresas_update(p_num_empresa INTEGER, p_ctrol_emp INTEGER, p_descripcion VARCHAR, p_representante VARCHAR) RETURNS INTEGER AS $$
BEGIN
  UPDATE ta_16_empresas SET descripcion = p_descripcion, representante = p_representante
    WHERE num_empresa = p_num_empresa AND ctrol_emp = p_ctrol_emp;
  RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/7: sp_empresas_delete
-- Tipo: CRUD
-- Descripción: Elimina una empresa si no tiene contratos asociados
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_empresas_delete(p_num_empresa INTEGER, p_ctrol_emp INTEGER) RETURNS INTEGER AS $$
DECLARE
  v_contratos INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_contratos FROM ta_16_contratos WHERE num_empresa = p_num_empresa AND ctrol_emp = p_ctrol_emp;
  IF v_contratos > 0 THEN
    RETURN 0;
  END IF;
  DELETE FROM ta_16_empresas WHERE num_empresa = p_num_empresa AND ctrol_emp = p_ctrol_emp;
  RETURN 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/7: sp_empresas_search
-- Tipo: Catalog
-- Descripción: Busca empresas por nombre y/o tipo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_empresas_search(p_descripcion VARCHAR DEFAULT NULL, p_ctrol_emp INTEGER DEFAULT NULL) RETURNS SETOF RECORD AS $$
BEGIN
  RETURN QUERY
    SELECT a.num_empresa, b.ctrol_emp, b.tipo_empresa, a.descripcion, a.representante
    FROM ta_16_empresas a
    JOIN ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
    WHERE (p_descripcion IS NULL OR a.descripcion ILIKE '%'||p_descripcion||'%')
      AND (p_ctrol_emp IS NULL OR a.ctrol_emp = p_ctrol_emp)
    ORDER BY a.descripcion, a.num_empresa, b.ctrol_emp;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 7/7: sp_tipos_emp_list
-- Tipo: Catalog
-- Descripción: Lista todos los tipos de empresa
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tipos_emp_list() RETURNS TABLE(ctrol_emp INTEGER, tipo_empresa VARCHAR, descripcion VARCHAR) AS $$
BEGIN
  RETURN QUERY SELECT ctrol_emp, tipo_empresa, descripcion FROM ta_16_tipos_emp ORDER BY ctrol_emp;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 2. ABC_ZONAS - 3 STORED PROCEDURES
-- ============================================================================

-- SP 1/3: sp_zonas_create
-- Tipo: CRUD
-- Descripción: Crea una nueva zona en el catálogo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_zonas_create(p_zona integer, p_sub_zona integer, p_descripcion varchar)
RETURNS TABLE(ctrol_zona integer, zona integer, sub_zona integer, descripcion varchar) AS $$
DECLARE
    new_ctrol integer;
BEGIN
    -- Validar existencia
    IF EXISTS (SELECT 1 FROM ta_16_zonas WHERE zona = p_zona AND sub_zona = p_sub_zona) THEN
        RAISE EXCEPTION 'Ya existe una zona con esos datos';
    END IF;
    -- Insertar
    INSERT INTO ta_16_zonas(zona, sub_zona, descripcion)
    VALUES (p_zona, p_sub_zona, p_descripcion)
    RETURNING ctrol_zona, zona, sub_zona, descripcion INTO new_ctrol, p_zona, p_sub_zona, p_descripcion;
    RETURN QUERY SELECT new_ctrol, p_zona, p_sub_zona, p_descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_zonas_update
-- Tipo: CRUD
-- Descripción: Actualiza una zona existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_zonas_update(p_ctrol_zona integer, p_zona integer, p_sub_zona integer, p_descripcion varchar)
RETURNS TABLE(ctrol_zona integer, zona integer, sub_zona integer, descripcion varchar) AS $$
BEGIN
    UPDATE ta_16_zonas
    SET zona = p_zona, sub_zona = p_sub_zona, descripcion = p_descripcion
    WHERE ctrol_zona = p_ctrol_zona
    RETURNING ctrol_zona, zona, sub_zona, descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_zonas_delete
-- Tipo: CRUD
-- Descripción: Elimina una zona si no tiene empresas relacionadas
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_zonas_delete(p_ctrol_zona integer)
RETURNS TABLE(status text, message text) AS $$
DECLARE
    emp_count integer;
BEGIN
    SELECT COUNT(*) INTO emp_count FROM ta_16_empresas WHERE ctrol_zona = p_ctrol_zona;
    IF emp_count > 0 THEN
        RETURN QUERY SELECT 'error', 'No se puede eliminar: existen empresas con esta zona.';
        RETURN;
    END IF;
    DELETE FROM ta_16_zonas WHERE ctrol_zona = p_ctrol_zona;
    RETURN QUERY SELECT 'success', 'Zona eliminada correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 3. ABC_TIPOS_ASEO - 3 STORED PROCEDURES
-- ============================================================================

-- SP 1/3: sp_tipos_aseo_create
-- Tipo: CRUD
-- Descripción: Alta de un nuevo tipo de aseo. Valida unicidad de tipo_aseo y existencia de cta_aplicacion.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tipos_aseo_create(
    p_tipo_aseo VARCHAR(1),
    p_descripcion VARCHAR(80),
    p_cta_aplicacion INTEGER,
    p_usuario INTEGER
) RETURNS TABLE(success boolean, msg text) AS $$
DECLARE
    v_exists INTEGER;
    v_cta_exists INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_16_tipo_aseo WHERE tipo_aseo = p_tipo_aseo;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT false, 'Ya existe el tipo de aseo';
        RETURN;
    END IF;
    SELECT COUNT(*) INTO v_cta_exists FROM ta_16_ctas_aplicacion WHERE cta_aplicacion = p_cta_aplicacion;
    IF v_cta_exists = 0 THEN
        RETURN QUERY SELECT false, 'La cuenta de aplicación no existe';
        RETURN;
    END IF;
    INSERT INTO ta_16_tipo_aseo (tipo_aseo, descripcion, cta_aplicacion, usuario_alta, fecha_alta)
    VALUES (p_tipo_aseo, p_descripcion, p_cta_aplicacion, p_usuario, NOW());
    RETURN QUERY SELECT true, 'Tipo de aseo creado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_tipos_aseo_update
-- Tipo: CRUD
-- Descripción: Actualiza un tipo de aseo existente. Valida existencia y cuenta de aplicación.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tipos_aseo_update(
    p_ctrol_aseo INTEGER,
    p_tipo_aseo VARCHAR(1),
    p_descripcion VARCHAR(80),
    p_cta_aplicacion INTEGER,
    p_usuario INTEGER
) RETURNS TABLE(success boolean, msg text) AS $$
DECLARE
    v_exists INTEGER;
    v_cta_exists INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_16_tipo_aseo WHERE ctrol_aseo = p_ctrol_aseo;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT false, 'No existe el tipo de aseo';
        RETURN;
    END IF;
    SELECT COUNT(*) INTO v_cta_exists FROM ta_16_ctas_aplicacion WHERE cta_aplicacion = p_cta_aplicacion;
    IF v_cta_exists = 0 THEN
        RETURN QUERY SELECT false, 'La cuenta de aplicación no existe';
        RETURN;
    END IF;
    UPDATE ta_16_tipo_aseo
    SET tipo_aseo = p_tipo_aseo,
        descripcion = p_descripcion,
        cta_aplicacion = p_cta_aplicacion,
        usuario_mod = p_usuario,
        fecha_mod = NOW()
    WHERE ctrol_aseo = p_ctrol_aseo;
    RETURN QUERY SELECT true, 'Tipo de aseo actualizado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_tipos_aseo_delete
-- Tipo: CRUD
-- Descripción: Elimina un tipo de aseo si no tiene contratos asociados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tipos_aseo_delete(
    p_ctrol_aseo INTEGER,
    p_usuario INTEGER
) RETURNS TABLE(success boolean, msg text) AS $$
DECLARE
    v_exists INTEGER;
    v_has_contracts INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_16_tipo_aseo WHERE ctrol_aseo = p_ctrol_aseo;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT false, 'No existe el tipo de aseo';
        RETURN;
    END IF;
    SELECT COUNT(*) INTO v_has_contracts FROM ta_16_contratos WHERE ctrol_aseo = p_ctrol_aseo;
    IF v_has_contracts > 0 THEN
        RETURN QUERY SELECT false, 'Existen contratos con este tipo de aseo. No se puede borrar.';
        RETURN;
    END IF;
    DELETE FROM ta_16_tipo_aseo WHERE ctrol_aseo = p_ctrol_aseo;
    RETURN QUERY SELECT true, 'Tipo de aseo eliminado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 4. ABC_RECARGOS - 4 STORED PROCEDURES
-- ============================================================================

-- SP 1/4: sp_recargos_list
-- Tipo: Catalog
-- Descripción: Lista todos los recargos, opcionalmente por año.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_recargos_list(p_year integer DEFAULT NULL)
RETURNS TABLE (
    aso_mes_recargo date,
    porc_recargo float,
    porc_multa float
) AS $$
BEGIN
    RETURN QUERY
    SELECT aso_mes_recargo, porc_recargo, porc_multa
    FROM ta_16_recargos
    WHERE (p_year IS NULL OR EXTRACT(YEAR FROM aso_mes_recargo) = p_year)
    ORDER BY aso_mes_recargo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_recargos_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo registro de recargo si no existe para el periodo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_recargos_create(p_aso_mes_recargo date, p_porc_recargo float, p_porc_multa float)
RETURNS TABLE (success boolean, message text) AS $$
DECLARE
    v_exists integer;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_16_recargos WHERE aso_mes_recargo = p_aso_mes_recargo;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT false, 'Ya existe un recargo para ese periodo.';
        RETURN;
    END IF;
    INSERT INTO ta_16_recargos (aso_mes_recargo, porc_recargo, porc_multa)
    VALUES (p_aso_mes_recargo, p_porc_recargo, p_porc_multa);
    RETURN QUERY SELECT true, 'Recargo creado correctamente.';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_recargos_update
-- Tipo: CRUD
-- Descripción: Actualiza un registro de recargo existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_recargos_update(p_aso_mes_recargo date, p_porc_recargo float, p_porc_multa float)
RETURNS TABLE (success boolean, message text) AS $$
DECLARE
    v_exists integer;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_16_recargos WHERE aso_mes_recargo = p_aso_mes_recargo;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT false, 'No existe el recargo para ese periodo.';
        RETURN;
    END IF;
    UPDATE ta_16_recargos
    SET porc_recargo = p_porc_recargo, porc_multa = p_porc_multa
    WHERE aso_mes_recargo = p_aso_mes_recargo;
    RETURN QUERY SELECT true, 'Recargo actualizado correctamente.';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_recargos_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de recargo por periodo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_recargos_delete(p_aso_mes_recargo date)
RETURNS TABLE (success boolean, message text) AS $$
DECLARE
    v_exists integer;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_16_recargos WHERE aso_mes_recargo = p_aso_mes_recargo;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT false, 'No existe el recargo para ese periodo.';
        RETURN;
    END IF;
    DELETE FROM ta_16_recargos WHERE aso_mes_recargo = p_aso_mes_recargo;
    RETURN QUERY SELECT true, 'Recargo eliminado correctamente.';
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 5. ABC_UND_RECOLEC - 4 STORED PROCEDURES
-- ============================================================================

-- SP 1/4: sp_unidades_recoleccion_list
-- Tipo: Catalog
-- Descripción: Lista todas las unidades de recolección para un ejercicio dado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_unidades_recoleccion_list(p_ejercicio integer)
RETURNS TABLE (
    ctrol_recolec integer,
    ejercicio_recolec smallint,
    cve_recolec varchar(1),
    descripcion varchar(80),
    costo_unidad numeric(12,2),
    costo_exed numeric(12,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT ctrol_recolec, ejercicio_recolec, cve_recolec, descripcion, costo_unidad, costo_exed
    FROM ta_16_unidades
    WHERE ejercicio_recolec = p_ejercicio
    ORDER BY ejercicio_recolec, cve_recolec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_unidades_recoleccion_create
-- Tipo: CRUD
-- Descripción: Crea una nueva unidad de recolección.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_unidades_recoleccion_create(
    p_ejercicio smallint,
    p_cve varchar(1),
    p_descripcion varchar(80),
    p_costo_unidad numeric(12,2),
    p_costo_exed numeric(12,2),
    p_usuario_id integer
) RETURNS TABLE (status text, ctrol_recolec integer) AS $$
DECLARE
    v_ctrol integer;
BEGIN
    -- Validar existencia
    IF EXISTS (SELECT 1 FROM ta_16_unidades WHERE ejercicio_recolec = p_ejercicio AND cve_recolec = p_cve) THEN
        RETURN QUERY SELECT 'error: clave ya existe', NULL;
        RETURN;
    END IF;
    -- Generar nuevo control
    SELECT COALESCE(MAX(ctrol_recolec),0)+1 INTO v_ctrol FROM ta_16_unidades WHERE ejercicio_recolec = p_ejercicio;
    INSERT INTO ta_16_unidades (ctrol_recolec, ejercicio_recolec, cve_recolec, descripcion, costo_unidad, costo_exed)
    VALUES (v_ctrol, p_ejercicio, p_cve, p_descripcion, p_costo_unidad, p_costo_exed);
    RETURN QUERY SELECT 'ok', v_ctrol;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_unidades_recoleccion_update
-- Tipo: CRUD
-- Descripción: Actualiza una unidad de recolección existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_unidades_recoleccion_update(
    p_ctrol integer,
    p_ejercicio smallint,
    p_cve varchar(1),
    p_descripcion varchar(80),
    p_costo_unidad numeric(12,2),
    p_costo_exed numeric(12,2),
    p_usuario_id integer
) RETURNS TABLE (status text) AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ta_16_unidades WHERE ctrol_recolec = p_ctrol) THEN
        RETURN QUERY SELECT 'error: unidad no existe';
        RETURN;
    END IF;
    UPDATE ta_16_unidades
    SET ejercicio_recolec = p_ejercicio,
        cve_recolec = p_cve,
        descripcion = p_descripcion,
        costo_unidad = p_costo_unidad,
        costo_exed = p_costo_exed
    WHERE ctrol_recolec = p_ctrol;
    RETURN QUERY SELECT 'ok';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_unidades_recoleccion_delete
-- Tipo: CRUD
-- Descripción: Elimina una unidad de recolección si no está referenciada en contratos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_unidades_recoleccion_delete(
    p_ctrol integer
) RETURNS TABLE (status text) AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM ta_16_contratos WHERE ctrol_recolec = p_ctrol) THEN
        RETURN QUERY SELECT 'error: existen contratos con esta unidad';
        RETURN;
    END IF;
    DELETE FROM ta_16_unidades WHERE ctrol_recolec = p_ctrol;
    RETURN QUERY SELECT 'ok';
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 6. ABC_TIPOS_EMP - 5 STORED PROCEDURES
-- ============================================================================

-- SP 1/5: sp_tipos_emp_list
-- Tipo: Catalog
-- Descripción: Lista todos los tipos de empresa
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tipos_emp_list()
RETURNS TABLE(ctrol_emp integer, tipo_empresa varchar, descripcion varchar) AS $$
BEGIN
  RETURN QUERY SELECT ctrol_emp, tipo_empresa, descripcion FROM ta_16_tipos_emp ORDER BY ctrol_emp;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_tipos_emp_get
-- Tipo: Catalog
-- Descripción: Obtiene un tipo de empresa por su clave primaria
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tipos_emp_get(p_ctrol_emp integer)
RETURNS TABLE(ctrol_emp integer, tipo_empresa varchar, descripcion varchar) AS $$
BEGIN
  RETURN QUERY SELECT ctrol_emp, tipo_empresa, descripcion FROM ta_16_tipos_emp WHERE ctrol_emp = p_ctrol_emp;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_tipos_emp_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo tipo de empresa
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tipos_emp_create(p_ctrol_emp integer, p_tipo_empresa varchar, p_descripcion varchar)
RETURNS TABLE(success boolean, message text) AS $$
DECLARE
  v_exists integer;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM ta_16_tipos_emp WHERE ctrol_emp = p_ctrol_emp;
  IF v_exists > 0 THEN
    RETURN QUERY SELECT false, 'Ya existe un tipo de empresa con ese control';
    RETURN;
  END IF;
  INSERT INTO ta_16_tipos_emp (ctrol_emp, tipo_empresa, descripcion)
  VALUES (p_ctrol_emp, p_tipo_empresa, p_descripcion);
  RETURN QUERY SELECT true, 'Tipo de empresa creado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_tipos_emp_update
-- Tipo: CRUD
-- Descripción: Actualiza un tipo de empresa existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tipos_emp_update(p_ctrol_emp integer, p_tipo_empresa varchar, p_descripcion varchar)
RETURNS TABLE(success boolean, message text) AS $$
DECLARE
  v_exists integer;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM ta_16_tipos_emp WHERE ctrol_emp = p_ctrol_emp;
  IF v_exists = 0 THEN
    RETURN QUERY SELECT false, 'No existe el tipo de empresa';
    RETURN;
  END IF;
  UPDATE ta_16_tipos_emp SET tipo_empresa = p_tipo_empresa, descripcion = p_descripcion
    WHERE ctrol_emp = p_ctrol_emp;
  RETURN QUERY SELECT true, 'Tipo de empresa actualizado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_tipos_emp_delete
-- Tipo: CRUD
-- Descripción: Elimina un tipo de empresa (solo si no tiene empresas asociadas)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tipos_emp_delete(p_ctrol_emp integer)
RETURNS TABLE(success boolean, message text) AS $$
DECLARE
  v_empresas integer;
BEGIN
  SELECT COUNT(*) INTO v_empresas FROM ta_16_empresas WHERE ctrol_emp = p_ctrol_emp;
  IF v_empresas > 0 THEN
    RETURN QUERY SELECT false, 'No se puede eliminar: existen empresas asociadas a este tipo';
    RETURN;
  END IF;
  DELETE FROM ta_16_tipos_emp WHERE ctrol_emp = p_ctrol_emp;
  RETURN QUERY SELECT true, 'Tipo de empresa eliminado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 7. ABC_CVES_OPERACION - 5 STORED PROCEDURES
-- ============================================================================

-- SP 1/5: sp_cves_operacion_list
-- Tipo: Catalog
-- Descripción: Lista todas las claves de operación
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cves_operacion_list()
RETURNS TABLE (
    ctrol_operacion integer,
    cve_operacion varchar(1),
    descripcion varchar(80)
) AS $$
BEGIN
    RETURN QUERY SELECT ctrol_operacion, cve_operacion, descripcion
    FROM ta_16_operacion
    ORDER BY ctrol_operacion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_cves_operacion_get
-- Tipo: Catalog
-- Descripción: Obtiene una clave de operación por ID
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cves_operacion_get(p_ctrol_operacion integer)
RETURNS TABLE (
    ctrol_operacion integer,
    cve_operacion varchar(1),
    descripcion varchar(80)
) AS $$
BEGIN
    RETURN QUERY SELECT ctrol_operacion, cve_operacion, descripcion
    FROM ta_16_operacion
    WHERE ctrol_operacion = p_ctrol_operacion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_cves_operacion_insert
-- Tipo: CRUD
-- Descripción: Inserta una nueva clave de operación
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cves_operacion_insert(
    p_cve_operacion varchar(1),
    p_descripcion varchar(80)
) RETURNS TABLE (
    ctrol_operacion integer,
    cve_operacion varchar(1),
    descripcion varchar(80)
) AS $$
DECLARE
    new_id integer;
BEGIN
    -- Validar unicidad de clave
    IF EXISTS (SELECT 1 FROM ta_16_operacion WHERE cve_operacion = p_cve_operacion) THEN
        RAISE EXCEPTION 'Ya existe una clave con ese valor';
    END IF;
    INSERT INTO ta_16_operacion (cve_operacion, descripcion)
    VALUES (p_cve_operacion, p_descripcion)
    RETURNING ctrol_operacion, cve_operacion, descripcion INTO new_id, p_cve_operacion, p_descripcion;
    RETURN QUERY SELECT new_id, p_cve_operacion, p_descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_cves_operacion_update
-- Tipo: CRUD
-- Descripción: Actualiza una clave de operación existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cves_operacion_update(
    p_ctrol_operacion integer,
    p_cve_operacion varchar(1),
    p_descripcion varchar(80)
) RETURNS TABLE (
    ctrol_operacion integer,
    cve_operacion varchar(1),
    descripcion varchar(80)
) AS $$
BEGIN
    UPDATE ta_16_operacion
    SET cve_operacion = p_cve_operacion,
        descripcion = p_descripcion
    WHERE ctrol_operacion = p_ctrol_operacion;
    RETURN QUERY SELECT ctrol_operacion, cve_operacion, descripcion
    FROM ta_16_operacion WHERE ctrol_operacion = p_ctrol_operacion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_cves_operacion_delete
-- Tipo: CRUD
-- Descripción: Elimina una clave de operación (solo si no tiene pagos asociados)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cves_operacion_delete(p_ctrol_operacion integer)
RETURNS VOID AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM ta_16_pagos WHERE ctrol_operacion = p_ctrol_operacion) THEN
        RAISE EXCEPTION 'No se puede eliminar: existen pagos asociados a esta clave.';
    END IF;
    DELETE FROM ta_16_operacion WHERE ctrol_operacion = p_ctrol_operacion;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 8. ABC_GASTOS - 2 STORED PROCEDURES
-- ============================================================================

-- SP 1/2: sp_gastos_insert
-- Tipo: Catalog
-- Descripción: Inserta un nuevo registro de gastos (solo debe existir uno)
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_gastos_insert(
    p_sdzmg NUMERIC,
    p_porc1_req NUMERIC,
    p_porc2_embargo NUMERIC,
    p_porc3_secuestro NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO ta_16_gastos (sdzmg, porc1_req, porc2_embargo, porc3_secuestro)
    VALUES (p_sdzmg, p_porc1_req, p_porc2_embargo, p_porc3_secuestro);
END;
$$;

-- ============================================

-- SP 2/2: sp_gastos_delete_all
-- Tipo: Catalog
-- Descripción: Elimina todos los registros de gastos (solo debe haber uno)
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_gastos_delete_all()
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM ta_16_gastos;
END;
$$;

-- ============================================================================
-- 9. MANNTO_RECAUDADORAS - 3 STORED PROCEDURES
-- ============================================================================

-- SP 1/3: sp_recaudadoras_create
-- Tipo: CRUD
-- Descripción: Crea una nueva recaudadora si no existe el número.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_recaudadoras_create(p_num_rec SMALLINT, p_descripcion VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM ta_16_recaudadoras WHERE num_rec = p_num_rec) THEN
        RAISE EXCEPTION 'YA EXISTE o EL CAMPO DE NUMERO ES NULO, INTENTA CON OTRO.';
    END IF;
    INSERT INTO ta_16_recaudadoras (num_rec, descripcion) VALUES (p_num_rec, p_descripcion);
END;
$$;

-- ============================================

-- SP 2/3: sp_recaudadoras_update
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de una recaudadora.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_recaudadoras_update(p_num_rec SMALLINT, p_descripcion VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE ta_16_recaudadoras SET descripcion = p_descripcion WHERE num_rec = p_num_rec;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No existe la recaudadora con ese número.';
    END IF;
END;
$$;

-- ============================================

-- SP 3/3: sp_recaudadoras_delete
-- Tipo: CRUD
-- Descripción: Elimina una recaudadora si no tiene contratos asociados.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_recaudadoras_delete(p_num_rec SMALLINT)
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM ta_16_contratos WHERE num_rec = p_num_rec) THEN
        RAISE EXCEPTION 'EXISTEN CONTRATOS CON ESTA RECAUDADORA. POR LO TANTO NO LO PUEDES BORRAR, INTENTA CON OTRA.';
    END IF;
    DELETE FROM ta_16_recaudadoras WHERE num_rec = p_num_rec;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No existe la recaudadora con ese número.';
    END IF;
END;
$$;

-- ============================================================================
-- 10. CONS_ZONAS - 1 STORED PROCEDURE
-- ============================================================================

-- SP 1/1: sp_cons_zonas_list
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de zonas ordenado según el campo especificado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cons_zonas_list(p_order text DEFAULT 'ctrol_zona')
RETURNS TABLE (
    ctrol_zona integer,
    zona smallint,
    sub_zona smallint,
    descripcion varchar
) AS $$
DECLARE
    sql text;
BEGIN
    sql := 'SELECT ctrol_zona, zona, sub_zona, descripcion FROM ta_16_zonas ORDER BY ' || quote_ident(p_order);
    RETURN QUERY EXECUTE sql;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- FIN DEL DEPLOY SCRIPT
-- ============================================================================
-- Total de funciones creadas: 37
-- - 34 Funciones (RETURNS TABLE/SETOF RECORD)
-- - 3 Procedimientos (sin retorno)
--
-- Para verificar la instalación ejecute:
-- SELECT COUNT(*) FROM pg_proc WHERE proname LIKE 'sp_%' AND prokind IN ('f', 'p');
-- ============================================================================
