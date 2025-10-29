-- Stored Procedure: sp_consultar_pagos_tpat400
-- Tipo: Report
-- Descripción: Consulta pagos de transmisiones patrimoniales en pagotransm_400 según filtros.
-- Generado para formulario: ConsTPat400
-- Fecha: 2025-08-26 23:45:50

CREATE OR REPLACE FUNCTION sp_consultar_pagos_tpat400(
    p_fec_pag integer,
    p_rec_pag smallint DEFAULT NULL,
    p_cajpag varchar DEFAULT NULL,
    p_opc_pag smallint DEFAULT NULL
)
RETURNS TABLE (
    recaud smallint,
    mpio smallint,
    cuenta integer,
    cvecatnva varchar,
    notario varchar,
    not_mpio varchar,
    not_num smallint,
    suplente varchar,
    num_esc integer,
    fec_esc integer,
    fec_otorg integer,
    tipo_tran smallint,
    adquiriente varchar,
    sector varchar,
    valor_tran float,
    por_tran smallint,
    imp_tran float,
    tasa_tran smallint,
    rec_tran float,
    mul_tran float,
    gtos_tran float,
    fec_pag integer,
    rec_pag smallint,
    cajpag varchar,
    opc_pag smallint,
    lug_pag varchar,
    tot_pag integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM pagotransm_400
    WHERE fec_pag = p_fec_pag
      AND (p_rec_pag IS NULL OR rec_pag = p_rec_pag)
      AND (p_cajpag IS NULL OR cajpag = p_cajpag)
      AND (p_opc_pag IS NULL OR opc_pag = p_opc_pag);
END;
$$ LANGUAGE plpgsql;