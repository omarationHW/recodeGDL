-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Reportes_Folios
-- Generado: 2025-08-27 13:56:43
-- Total SPs: 2
-- ============================================

-- SP 1/2: cons14_solicrep
-- Tipo: Report
-- Descripción: Obtiene el reporte de folios según clave de infracción, tipo de solicitud y rango de fechas.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE cons14_solicrep(
    IN parCveInf integer,
    IN parOpc integer,
    IN parFec_Inicio date,
    IN parFec_Fin date
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Ejemplo: Debe adaptarse a la lógica real de negocio
    -- parOpc: 1=adeudos, 2=pagados, 3=cancelados, 4=condonados, 5=cancelados y condonados
    IF parCveInf = 0 THEN
        -- Todos
        SELECT * FROM folios
        WHERE tipo_solicitud = parOpc
          AND fecha_folio BETWEEN parFec_Inicio AND parFec_Fin;
    ELSE
        SELECT * FROM folios
        WHERE tipo_solicitud = parOpc
          AND cve_infraccion = parCveInf
          AND fecha_folio BETWEEN parFec_Inicio AND parFec_Fin;
    END IF;
END;
$$;

-- ============================================

-- SP 2/2: cons14_solicrep_c
-- Tipo: Report
-- Descripción: Obtiene la relación de descuentos otorgados en un rango de fechas.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE cons14_solicrep_c(
    IN parFec_Inicio date,
    IN parFec_Fin date
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Ejemplo: Debe adaptarse a la lógica real de negocio
    SELECT * FROM descuentos_otorgados
    WHERE fecha_otorga BETWEEN parFec_Inicio AND parFec_Fin;
END;
$$;

-- ============================================

