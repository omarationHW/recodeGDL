-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Menu
-- Generado: 2025-08-27 14:57:35
-- Total SPs: 12
-- ============================================

-- SP 1/12: sp_cat_unidades_list
-- Tipo: Catalog
-- Descripción: Lista todas las unidades de recolección para un ejercicio dado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cat_unidades_list(p_ejercicio INTEGER)
RETURNS TABLE(
    id SERIAL,
    ejercicio INTEGER,
    clave VARCHAR,
    descripcion VARCHAR,
    costo_unidad NUMERIC,
    costo_exed NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT id, ejercicio_recolec, cve_recolec, descripcion, costo_unidad, costo_exed
    FROM ta_16_unidades
    WHERE ejercicio_recolec = p_ejercicio
    ORDER BY id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/12: sp_cat_unidades_create
-- Tipo: Catalog
-- Descripción: Crea una nueva unidad de recolección.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cat_unidades_create(
    p_ejercicio INTEGER,
    p_clave VARCHAR,
    p_descripcion VARCHAR,
    p_costo_unidad NUMERIC,
    p_costo_exed NUMERIC
) RETURNS TABLE(result TEXT) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_16_unidades WHERE ejercicio_recolec = p_ejercicio AND cve_recolec = p_clave;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT 'ERROR: Ya existe la clave para ese ejercicio';
        RETURN;
    END IF;
    INSERT INTO ta_16_unidades (ejercicio_recolec, cve_recolec, descripcion, costo_unidad, costo_exed)
    VALUES (p_ejercicio, p_clave, p_descripcion, p_costo_unidad, p_costo_exed);
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/12: sp_cat_unidades_update
-- Tipo: Catalog
-- Descripción: Actualiza una unidad de recolección existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cat_unidades_update(
    p_id INTEGER,
    p_descripcion VARCHAR,
    p_costo_unidad NUMERIC,
    p_costo_exed NUMERIC
) RETURNS TABLE(result TEXT) AS $$
BEGIN
    UPDATE ta_16_unidades
    SET descripcion = p_descripcion, costo_unidad = p_costo_unidad, costo_exed = p_costo_exed
    WHERE id = p_id;
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/12: sp_cat_unidades_delete
-- Tipo: Catalog
-- Descripción: Elimina una unidad de recolección si no tiene contratos asociados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cat_unidades_delete(p_id INTEGER)
RETURNS TABLE(result TEXT) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_16_contratos WHERE ctrol_recolec = p_id;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT 'ERROR: Existen contratos asociados, no se puede eliminar';
        RETURN;
    END IF;
    DELETE FROM ta_16_unidades WHERE id = p_id;
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/12: sp_cat_tipos_aseo_list
-- Tipo: Catalog
-- Descripción: Lista todos los tipos de aseo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cat_tipos_aseo_list()
RETURNS TABLE(id SERIAL, tipo_aseo VARCHAR, descripcion VARCHAR, cta_aplicacion INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT id, tipo_aseo, descripcion, cta_aplicacion FROM ta_16_tipo_aseo ORDER BY id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/12: sp_cat_zonas_list
-- Tipo: Catalog
-- Descripción: Lista todas las zonas.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cat_zonas_list()
RETURNS TABLE(id SERIAL, zona INTEGER, sub_zona INTEGER, descripcion VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT id, zona, sub_zona, descripcion FROM ta_16_zonas ORDER BY id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 7/12: sp_cat_empresas_list
-- Tipo: Catalog
-- Descripción: Lista todas las empresas.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cat_empresas_list()
RETURNS TABLE(id SERIAL, num_empresa INTEGER, ctrol_emp INTEGER, descripcion VARCHAR, representante VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT id, num_empresa, ctrol_emp, descripcion, representante FROM ta_16_empresas ORDER BY id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 8/12: sp_cat_tipos_emp_list
-- Tipo: Catalog
-- Descripción: Lista todos los tipos de empresa.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cat_tipos_emp_list()
RETURNS TABLE(id SERIAL, tipo_empresa VARCHAR, descripcion VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT id, tipo_empresa, descripcion FROM ta_16_tipos_emp ORDER BY id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 9/12: sp_cat_recargos_list
-- Tipo: Catalog
-- Descripción: Lista todos los recargos de un ejercicio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cat_recargos_list(p_ejercicio INTEGER)
RETURNS TABLE(id SERIAL, aso_mes_recargo DATE, porc_recargo NUMERIC, porc_multa NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT id, aso_mes_recargo, porc_recargo, porc_multa FROM ta_16_recargos WHERE EXTRACT(YEAR FROM aso_mes_recargo) = p_ejercicio ORDER BY aso_mes_recargo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 10/12: sp_cat_gastos_list
-- Tipo: Catalog
-- Descripción: Lista todos los gastos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cat_gastos_list()
RETURNS TABLE(id SERIAL, sdzmg NUMERIC, porc1_req NUMERIC, porc2_embargo NUMERIC, porc3_secuestro NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT id, sdzmg, porc1_req, porc2_embargo, porc3_secuestro FROM ta_16_gastos ORDER BY id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 11/12: sp_cat_operaciones_list
-- Tipo: Catalog
-- Descripción: Lista todas las claves de operación.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cat_operaciones_list()
RETURNS TABLE(id SERIAL, cve_operacion VARCHAR, descripcion VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT id, cve_operacion, descripcion FROM ta_16_operacion ORDER BY id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 12/12: sp_rep_unidades_export
-- Tipo: Report
-- Descripción: Reporte/exportación de unidades de recolección por ejercicio y orden.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_rep_unidades_export(p_ejercicio INTEGER, p_order_by VARCHAR)
RETURNS TABLE(id SERIAL, ejercicio INTEGER, clave VARCHAR, descripcion VARCHAR, costo_unidad NUMERIC, costo_exed NUMERIC) AS $$
BEGIN
    RETURN QUERY EXECUTE format('SELECT id, ejercicio_recolec, cve_recolec, descripcion, costo_unidad, costo_exed FROM ta_16_unidades WHERE ejercicio_recolec = %L ORDER BY %I', p_ejercicio, p_order_by);
END;
$$ LANGUAGE plpgsql;

-- ============================================

