-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - OTRAS-OBLIG
-- Formulario: RBaja (EXACTO del archivo original)
-- Archivo: 20_SP_OTRASOBLIG_RBAJA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Actualizado: 2025-12-02
-- Total SPs: 5 (ACTUALIZADO)
-- ============================================

-- SP 1/4: sp_rbaja_buscar_local
-- Tipo: Catalog
-- Descripción: Busca un local/concesión por número y letra, retorna todos los datos relevantes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_rbaja_buscar_local(p_numero VARCHAR, p_letra VARCHAR)
RETURNS TABLE (
    id_34_datos INTEGER,
    control VARCHAR,
    concesionario VARCHAR,
    ubicacion VARCHAR,
    superficie NUMERIC,
    fecha_inicio DATE,
    id_recaudadora INTEGER,
    sector VARCHAR,
    id_zona INTEGER,
    licencia INTEGER,
    descrip_unidad VARCHAR,
    cve_stat VARCHAR,
    descrip_stat VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_34_datos, a.control, a.concesionario, a.ubicacion, a.superficie, a.fecha_inicio,
           a.id_recaudadora, a.sector, a.id_zona, a.licencia, b.descripcion AS descrip_unidad, c.cve_stat, c.descripcion AS descrip_stat
    FROM otrasoblig.t34_datos a
    JOIN otrasoblig.t34_unidades b ON b.id_34_unidad = a.id_unidad
    JOIN otrasoblig.t34_status c ON c.id_34_stat = a.id_stat
    WHERE a.cve_tab = 3
      AND a.control = CONCAT(TRIM(p_numero), '-', TRIM(p_letra));
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_rbaja_verificar_adeudos
-- Tipo: CRUD
-- Descripción: Verifica si existen adeudos pasados para el local/concesión antes del periodo dado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_rbaja_verificar_adeudos(p_id_34_datos INTEGER, p_periodo VARCHAR)
RETURNS TABLE (id_34_pagos INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_34_pagos
    FROM otrasoblig.t34_pagos a
    JOIN otrasoblig.t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.id_datos = p_id_34_datos
      AND a.periodo < p_periodo
      AND b.cve_stat = 'V';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_rbaja_verificar_adeudos_post
-- Tipo: CRUD
-- Descripción: Verifica si existen adeudos posteriores o con otro status para el local/concesión en el periodo dado o después.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_rbaja_verificar_adeudos_post(p_id_34_datos INTEGER, p_periodo VARCHAR)
RETURNS TABLE (id_34_pagos INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_34_pagos
    FROM otrasoblig.t34_pagos a
    JOIN otrasoblig.t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.id_datos = p_id_34_datos
      AND a.periodo >= p_periodo
      AND b.cve_stat <> 'V';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_rbaja_cancelar_local
-- Tipo: CRUD
-- Descripción: Cancela (da de baja) un local/concesión si no tiene adeudos vigentes o posteriores.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_rbaja_cancelar_local(p_id_34_datos INTEGER, p_axo_fin INTEGER, p_mes_fin INTEGER)
RETURNS TABLE (codigo INTEGER, mensaje TEXT) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Aquí se debe realizar la lógica de baja, por ejemplo:
    -- 1. Actualizar el status del local a 'C' (cancelado)
    -- 2. Registrar fecha de baja, etc.
    -- 3. Validar que no existan adeudos (esto ya se validó antes)
    UPDATE otrasoblig.t34_datos
    SET id_stat = (SELECT id_34_stat FROM otrasoblig.t34_status WHERE cve_stat = 'C' LIMIT 1),
        fecha_fin = make_date(p_axo_fin, p_mes_fin, 1)
    WHERE id_34_datos = p_id_34_datos;
    IF FOUND THEN
        RETURN QUERY SELECT 0 AS codigo, 'Se ejecutó correctamente la Cancelación del Local/Concesión' AS mensaje;
    ELSE
        RETURN QUERY SELECT 1 AS codigo, 'No se encontró el registro para cancelar' AS mensaje;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_rbaja_listar_adeudos
-- Tipo: Report
-- Descripción: Lista todos los adeudos pendientes de un local/concesión
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_rbaja_listar_adeudos(p_id_34_datos INTEGER)
RETURNS TABLE (
    periodo DATE,
    importe NUMERIC,
    recargo NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.periodo, a.importe, a.recargo
    FROM otrasoblig.t34_pagos a
    JOIN otrasoblig.t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.id_datos = p_id_34_datos
      AND b.cve_stat = 'V'  -- Solo adeudos vigentes
    ORDER BY a.periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================