-- Stored Procedure: sp_cancelacionmasiva_listar
-- Tipo: Report
-- Descripción: Lista los convenios cancelados hoy (vigencia = 'B')
-- Generado para formulario: CancelacionMasiva
-- Fecha: 2025-08-27 14:01:48

CREATE OR REPLACE FUNCTION sp_cancelacionmasiva_listar()
RETURNS TABLE (
    tipo smallint,
    subtipo smallint,
    letras_exp varchar(4),
    numero_exp integer,
    axo_exp smallint,
    id_conv_resto integer,
    fecha_inicio date,
    fecha_venc date,
    modulo smallint,
    referencia varchar(30),
    usuario varchar(20)
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.tipo, d.subtipo, d.letras_exp, d.numero_exp, d.axo_exp,
           a.id_conv_resto, a.fecha_inicio, a.fecha_venc,
           b.modulo, b.referencia, p.usuario
    FROM ta_17_conv_diverso d
    JOIN ta_17_conv_d_resto a ON a.tipo = d.tipo AND a.id_conv_diver = d.id_conv_diver
    JOIN ta_17_referencia b ON b.id_conv_resto = a.id_conv_resto
    JOIN ta_12_passwords p ON p.id_usuario = a.id_usuario
    WHERE a.vigencia = 'B' AND a.fecha_actual::date = CURRENT_DATE
    ORDER BY 1,2,3,4,5;
END;
$$ LANGUAGE plpgsql;