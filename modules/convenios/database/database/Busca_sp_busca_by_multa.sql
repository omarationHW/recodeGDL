-- Stored Procedure: sp_busca_by_multa
-- Tipo: Report
-- Descripción: Busca convenios por multa (dependencia, año acta, número acta)
-- Generado para formulario: Busca
-- Fecha: 2025-08-27 13:51:05

CREATE OR REPLACE FUNCTION sp_busca_by_multa(p_dependencia TEXT, p_axo_acta INTEGER, p_num_acta INTEGER)
RETURNS TABLE (
    id_conv_diver INTEGER,
    nombre TEXT,
    calle TEXT,
    num_exterior SMALLINT,
    num_interior SMALLINT,
    inciso TEXT,
    tipo SMALLINT,
    subtipo SMALLINT,
    manzana TEXT,
    lote INTEGER,
    letra TEXT,
    aloofi SMALLINT,
    numofi INTEGER,
    letexp TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.id_conv_diver,
        d.nombre,
        d.calle,
        d.num_exterior,
        d.num_interior,
        d.inciso,
        d.tipo,
        v.subtipo,
        v.manzana,
        v.lote,
        v.letra,
        v.aloofi,
        v.numofi,
        v.letexp
    FROM ta_17_conv_d_resto d
    LEFT JOIN vw_conv_complemento v ON d.id_conv_diver = v.id_conv_diver
    WHERE v.dependencia = p_dependencia AND v.axo_acta = p_axo_acta AND v.num_acta = p_num_acta;
END;
$$ LANGUAGE plpgsql;