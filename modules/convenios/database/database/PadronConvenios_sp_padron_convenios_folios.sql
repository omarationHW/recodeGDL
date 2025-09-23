-- Stored Procedure: sp_padron_convenios_folios
-- Tipo: Report
-- Descripción: Obtiene los folios (parcialidades) de un convenio dado.
-- Generado para formulario: PadronConvenios
-- Fecha: 2025-08-27 15:06:39

-- PostgreSQL stored procedure
CREATE OR REPLACE FUNCTION sp_padron_convenios_folios(
    p_modulo integer,
    p_id_referencia integer,
    p_fecha_inicio date,
    p_fecha_venc date,
    p_id_conv_resto integer
)
RETURNS TABLE (
    idconvenio integer,
    folio integer,
    fecprac date,
    vigencia varchar,
    axodsd integer,
    mesdsd integer,
    axohst integer,
    meshst integer,
    FPago varchar,
    ejecutor integer
) AS $$
BEGIN
    -- Simula llamada a stored procedure de folios (debe adaptarse a la lógica real)
    RETURN QUERY
    SELECT 
        p_id_conv_resto as idconvenio,
        f.folio,
        f.fecprac,
        CASE f.vigencia WHEN 'V' THEN 'VIGENTE' WHEN 'P' THEN 'PAGADO' ELSE 'CANCELADO' END as vigencia,
        f.axodsd, f.mesdsd, f.axohst, f.meshst,
        COALESCE(TO_CHAR(f.fecpag, 'YYYY-MM-DD'), '') as FPago,
        f.ejecutor
    FROM ta_17_folios f
    WHERE f.modulo = p_modulo
      AND f.id_referencia = p_id_referencia
      AND f.fecprac BETWEEN p_fecha_inicio AND p_fecha_venc
      AND f.id_conv_resto = p_id_conv_resto
    ORDER BY f.folio;
END;
$$ LANGUAGE plpgsql;