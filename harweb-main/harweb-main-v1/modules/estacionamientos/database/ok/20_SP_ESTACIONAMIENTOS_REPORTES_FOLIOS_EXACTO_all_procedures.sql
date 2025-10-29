-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: REPORTES_FOLIOS (EXACTO del archivo original)
-- Archivo: 20_SP_ESTACIONAMIENTOS_REPORTES_FOLIOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: REPORTES_FOLIOS (EXACTO del archivo original)
-- Archivo: 20_SP_ESTACIONAMIENTOS_REPORTES_FOLIOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

