-- Stored Procedure: sp_busca_by_licencia
-- Tipo: Report
-- Descripción: Busca convenios por número de licencia de giro
-- Generado para formulario: Busca
-- Fecha: 2025-08-27 13:51:05

CREATE OR REPLACE FUNCTION sp_busca_by_licencia(p_licencia INTEGER)
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
    WHERE v.licencia = p_licencia;
END;
$$ LANGUAGE plpgsql;