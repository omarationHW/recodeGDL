-- Stored Procedure: sp_buscar_convenio_diversos
-- Tipo: Report
-- Descripción: Busca un convenio diversos por tipo, subtipo, letras, folio, año, manzana
-- Generado para formulario: ModifConvDiversos
-- Fecha: 2025-08-27 20:52:39

CREATE OR REPLACE FUNCTION sp_buscar_convenio_diversos(
    p_tipo INTEGER,
    p_subtipo INTEGER,
    p_letras_ofi VARCHAR,
    p_folio_ofi INTEGER,
    p_alo_oficio INTEGER,
    p_manzana VARCHAR DEFAULT NULL
) RETURNS TABLE (
    id_conv_diver INTEGER,
    tipo INTEGER,
    subtipo INTEGER,
    letras_exp VARCHAR,
    numero_exp INTEGER,
    axo_exp INTEGER,
    id_conv_resto INTEGER,
    nombre VARCHAR,
    calle VARCHAR,
    num_exterior INTEGER,
    num_interior INTEGER,
    inciso VARCHAR,
    metros NUMERIC,
    telefono VARCHAR,
    correo VARCHAR,
    oficio VARCHAR,
    fechaoficio DATE,
    nombrefirma VARCHAR,
    observaciones VARCHAR,
    vigencia VARCHAR,
    bloqueo INTEGER,
    modulo INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_conv_diver, a.tipo, a.subtipo, a.letras_exp, a.numero_exp, a.axo_exp,
           b.id_conv_resto, b.nombre, b.calle, b.num_exterior, b.num_interior, b.inciso, b.metros,
           b.telefono, b.correo, b.oficio, b.fechaoficio, b.nombrefirma, b.observaciones, b.vigencia, b.bloqueo, b.modulo
    FROM ta_17_conv_diverso a
    JOIN ta_17_conv_d_resto b ON a.tipo = b.tipo AND a.id_conv_diver = b.id_conv_diver
    WHERE a.tipo = p_tipo AND a.subtipo = p_subtipo
      AND a.letras_exp = COALESCE(p_letras_ofi, a.letras_exp)
      AND a.numero_exp = COALESCE(p_folio_ofi, a.numero_exp)
      AND a.axo_exp = COALESCE(p_alo_oficio, a.axo_exp)
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;