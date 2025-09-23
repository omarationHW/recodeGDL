-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptServicios
-- Generado: 2025-08-27 15:51:52
-- Total SPs: 2
-- ============================================

-- SP 1/2: rptservicios_get_all
-- Tipo: Report
-- Descripción: Obtiene todos los registros del catálogo de servicios, ordenados por servicio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rptservicios_get_all()
RETURNS TABLE(servicio smallint, descripcion varchar, serv_obra94 smallint)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT servicio, descripcion, serv_obra94
    FROM ta_17_servicios
    ORDER BY servicio;
END;
$$;

-- ============================================

-- SP 2/2: rptservicios_count
-- Tipo: Report
-- Descripción: Devuelve el total de servicios registrados en el catálogo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rptservicios_count()
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    total integer;
BEGIN
    SELECT COUNT(*) INTO total FROM ta_17_servicios;
    RETURN total;
END;
$$;

-- ============================================

