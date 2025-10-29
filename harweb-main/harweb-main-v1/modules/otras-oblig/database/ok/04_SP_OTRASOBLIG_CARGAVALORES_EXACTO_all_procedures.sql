-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - OTRAS-OBLIG
-- Formulario: CargaValores (EXACTO del archivo original)
-- Archivo: 04_SP_OTRASOBLIG_CARGAVALORES_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp_insert_t34_unidades
-- Tipo: CRUD
-- Descripción: Inserta un nuevo registro en t34_unidades con los parámetros dados.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_insert_t34_unidades(
    p_id_34_unidad integer,
    p_ejercicio integer,
    p_cve_unidad varchar(10),
    p_cve_operatividad varchar(10),
    p_descripcion varchar(100),
    p_costo numeric(12,2),
    p_cve_tab varchar(1)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO otrasoblig.t34_unidades (
        id_34_unidad, ejercicio, cve_unidad, cve_operatividad, descripcion, costo, cve_tab
    ) VALUES (
        p_id_34_unidad, p_ejercicio, p_cve_unidad, p_cve_operatividad, p_descripcion, p_costo, p_cve_tab
    );
END;
$$;

-- ============================================