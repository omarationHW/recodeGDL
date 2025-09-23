-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: LISTADIFERENCIAS (EXACTO del archivo original)
-- Archivo: 63_SP_RECAUDADORA_LISTADIFERENCIAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp_lista_diferencias
-- Tipo: Report
-- Descripción: Obtiene el listado de diferencias de transmisiones patrimoniales filtrado por fecha y vigencia.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_lista_diferencias(
    p_fecha1 DATE,
    p_fecha2 DATE,
    p_vigencia VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    id INTEGER,
    foliot INTEGER,
    cvecuenta INTEGER,
    fecha_alta DATE,
    usu_alta VARCHAR,
    vigencia VARCHAR,
    fecha_baja DATE,
    usu_baja VARCHAR,
    cvepago INTEGER,
    fecha_pago DATE,
    fecha_actual DATE,
    usu_act VARCHAR,
    importe_base NUMERIC,
    recargos NUMERIC,
    multas NUMERIC,
    multasext NUMERIC,
    imp_ot NUMERIC,
    gastos NUMERIC,
    total NUMERIC,
    observaciones VARCHAR,
    fecha_rec DATE,
    noperito INTEGER,
    folio_glosa INTEGER,
    avaluo INTEGER,
    quienrep INTEGER,
    recaud SMALLINT,
    urbrus VARCHAR,
    cuenta INTEGER,
    nombredepto VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d.id, d.foliot, d.cvecuenta, d.fecha_alta, d.usu_alta, d.vigencia, d.fecha_baja, d.usu_baja, d.cvepago, d.fecha_pago, d.fecha_actual,
        d.usu_act, d.importe_base, d.recargos, d.multas, d.multasext, d.imp_ot, d.gastos, d.total, d.observaciones, d.fecha_rec,
        d.noperito, d.folio_glosa, d.avaluo, d.quienrep, c.recaud, c.urbrus, c.cuenta, e.nombredepto
    FROM diferencias_glosa d
    JOIN convcta c ON d.cvecuenta = c.cvecuenta
    JOIN deptos e ON d.quienrep = e.cvedepto
    WHERE d.fecha_alta >= p_fecha1
      AND d.fecha_alta <= p_fecha2
      AND (p_vigencia IS NULL OR p_vigencia = '' OR d.vigencia = p_vigencia)
    ORDER BY d.fecha_alta DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

