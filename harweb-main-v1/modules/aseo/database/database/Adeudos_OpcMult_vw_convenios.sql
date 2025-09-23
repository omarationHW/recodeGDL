-- Stored Procedure: vw_convenios
-- Tipo: Catalog
-- Descripción: Vista para obtener convenio de un contrato
-- Generado para formulario: Adeudos_OpcMult
-- Fecha: 2025-08-27 20:39:32

CREATE OR REPLACE VIEW vw_convenios AS
SELECT a.id_referencia as idlc, (trim(d.letras_exp)||'/'||d.numero_exp||'/'||d.axo_exp) as convenio
FROM ta_17_referencia a
JOIN ta_17_conv_d_resto b ON b.id_conv_resto = a.id_conv_resto AND b.vigencia = 'A'
JOIN ta_17_conv_diverso d ON d.tipo = b.tipo AND d.id_conv_diver = b.id_conv_diver;