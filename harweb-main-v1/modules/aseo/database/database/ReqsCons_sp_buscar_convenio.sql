-- Stored Procedure: sp_buscar_convenio
-- Tipo: CRUD
-- Descripción: Busca el convenio relacionado a un contrato.
-- Generado para formulario: ReqsCons
-- Fecha: 2025-08-27 20:45:14

CREATE OR REPLACE FUNCTION sp_buscar_convenio(p_idlc INTEGER)
RETURNS TABLE(convenio VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT (trim(d.letras_exp)||'/'||d.numero_exp||'/'||d.axo_exp) convenio FROM ta_17_referencia a, ta_17_conv_d_resto b, ta_17_conv_diverso d WHERE a.id_referencia = p_idlc AND a.modulo = 16 AND b.id_conv_resto = a.id_conv_resto AND b.vigencia = 'A' AND d.tipo = b.tipo AND d.id_conv_diver = b.id_conv_diver;
END;
$$ LANGUAGE plpgsql;