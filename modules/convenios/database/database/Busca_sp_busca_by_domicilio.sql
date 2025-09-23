-- Stored Procedure: sp_busca_by_domicilio
-- Tipo: Report
-- Descripción: Busca convenios por domicilio (calle y número exterior)
-- Generado para formulario: Busca
-- Fecha: 2025-08-27 13:51:05

CREATE OR REPLACE FUNCTION sp_busca_by_domicilio(p_calle TEXT, p_num_exterior INTEGER)
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
    WHERE d.calle ILIKE '%' || p_calle || '%'
      AND (p_num_exterior IS NULL OR d.num_exterior = p_num_exterior);
END;
$$ LANGUAGE plpgsql;