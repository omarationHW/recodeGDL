-- Stored Procedure: sp_busca_convenio
-- Tipo: CRUD
-- Descripción: Busca convenio relacionado a un contrato
-- Generado para formulario: Contratos_Upd_01
-- Fecha: 2025-08-27 14:24:09

CREATE OR REPLACE FUNCTION sp_busca_convenio(idlc integer) RETURNS TABLE (convenio varchar, id_conv_resto integer) AS $$
BEGIN
  RETURN QUERY
    SELECT (trim(d.letras_exp)||'/'||d.numero_exp||'/'||d.axo_exp) convenio, b.id_conv_resto
    FROM ta_17_referencia a, ta_17_conv_d_resto b, ta_17_conv_diverso d
    WHERE a.id_referencia = idlc AND a.modulo = 16
      AND b.id_conv_resto = a.id_conv_resto AND b.vigencia = 'A'
      AND d.tipo = b.tipo AND d.id_conv_diver = b.id_conv_diver;
END; $$ LANGUAGE plpgsql;