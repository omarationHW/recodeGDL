-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - OTRAS-OBLIG
-- Formulario: Rubros (EXACTO del archivo original)
-- Archivo: 26_SP_OTRASOBLIG_RUBROS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: ins34_rubro_01
-- Tipo: Catalog
-- Descripción: Crea un nuevo rubro (tabla) en t34_tablas y retorna el id y mensaje de status.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION ins34_rubro_01(par_nombre VARCHAR)
RETURNS TABLE(status INTEGER, concepto_status VARCHAR) AS $$
DECLARE
    new_id INTEGER;
BEGIN
    IF par_nombre IS NULL OR trim(par_nombre) = '' THEN
        status := -1;
        concepto_status := 'El nombre del rubro es obligatorio.';
        RETURN NEXT;
        RETURN;
    END IF;
    -- Verificar si ya existe un rubro con ese nombre
    IF EXISTS (SELECT 1 FROM otrasoblig.t34_tablas WHERE UPPER(nombre) = UPPER(par_nombre)) THEN
        status := -2;
        concepto_status := 'Ya existe un rubro con ese nombre.';
        RETURN NEXT;
        RETURN;
    END IF;
    -- Insertar el nuevo rubro
    INSERT INTO otrasoblig.t34_tablas (cve_tab, nombre, cajero, auto_tab)
    VALUES (
        (SELECT COALESCE(MAX(CAST(cve_tab AS INTEGER)),0)+1 FROM otrasoblig.t34_tablas),
        par_nombre,
        'N',
        (SELECT COALESCE(MAX(auto_tab),0)+1 FROM otrasoblig.t34_tablas)
    ) RETURNING id_34_tab INTO new_id;
    status := new_id;
    concepto_status := 'Rubro creado correctamente';
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: ins34_status
-- Tipo: Catalog
-- Descripción: Inserta un status para un rubro en t34_status.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE ins34_status(
    par_cve_tab INTEGER,
    par_cve_stat VARCHAR,
    par_descripcion VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO otrasoblig.t34_status (id_34_stat, cve_tab, cve_stat, descripcion, usuario)
    VALUES (
        DEFAULT,
        par_cve_tab,
        par_cve_stat,
        par_descripcion,
        current_user
    );
END;
$$;

-- ============================================