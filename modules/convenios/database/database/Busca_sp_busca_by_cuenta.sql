-- Stored Procedure: sp_busca_by_cuenta
-- Tipo: Report
-- Descripción: Busca convenios por cuenta (recaudadora, ur, cuenta)
-- Generado para formulario: Busca
-- Fecha: 2025-08-27 13:51:05

CREATE OR REPLACE FUNCTION sp_busca_by_cuenta(p_rec INTEGER, p_ur TEXT, p_cuenta INTEGER)
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
    WHERE v.recaudadora = p_rec AND v.ur = p_ur AND v.cuenta = p_cuenta;
END;
$$ LANGUAGE plpgsql;