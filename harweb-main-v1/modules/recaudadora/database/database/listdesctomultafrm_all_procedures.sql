-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: listdesctomultafrm
-- Generado: 2025-08-27 13:06:04
-- Total SPs: 1
-- ============================================

-- SP 1/1: report_descuentos_multa
-- Tipo: Report
-- Descripción: Obtiene el listado de descuentos otorgados en multas municipales para una recaudadora y rango de fechas.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION report_descuentos_multa(
    p_recaud integer,
    p_fini date,
    p_ffin date
)
RETURNS TABLE (
    recaud smallint,
    fecha date,
    caja varchar,
    folio integer,
    importe numeric,
    axo_acta smallint,
    num_acta integer,
    abrevia varchar,
    calificacion numeric,
    multa numeric,
    gastos numeric,
    total numeric,
    valor float,
    tipo_descto varchar,
    capturista varchar,
    feccap date,
    descripcion varchar,
    descto numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.recaud,
        p.fecha,
        p.caja,
        p.folio,
        p.importe,
        m.axo_acta,
        m.num_acta,
        cd.abrevia,
        m.calificacion,
        m.multa,
        m.gastos,
        m.total,
        d.valor,
        d.tipo_descto,
        d.capturista,
        d.feccap,
        c.descripcion,
        (m.calificacion - m.multa) AS descto
    FROM pagos p
    JOIN multas m ON m.cvepago = p.cvepago
    LEFT JOIN c_dependencias cd ON cd.id_dependencia = m.id_dependencia
    JOIN descmultampal d ON d.id_multa = m.id_multa
    JOIN c_autdescmul c ON c.cveautoriza = d.autoriza
    WHERE p.recaud = p_recaud
      AND p.fecha BETWEEN p_fini AND p_ffin
      AND p.cvecanc IS NULL
      AND p.cveconcepto IN (6,7)
      AND m.calificacion > m.multa
    ORDER BY d.capturista, p.recaud, p.fecha, p.caja, p.folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

