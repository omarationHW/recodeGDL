-- Stored Procedure: sp_get_calificacion_qr
-- Tipo: Report
-- Descripción: Obtiene los datos principales de la multa para impresión QR
-- Generado para formulario: sfrm_calificacionQR
-- Fecha: 2025-08-27 15:42:11

CREATE OR REPLACE FUNCTION sp_get_calificacion_qr(p_id_multa integer)
RETURNS TABLE (
    id_multa integer,
    id_dependencia smallint,
    axo_acta smallint,
    num_acta integer,
    fecha_acta date,
    fecha_cancelacion date,
    contribuyente varchar,
    domicilio varchar,
    recaud smallint,
    num_licencia integer,
    giro varchar,
    calificacion numeric,
    multa numeric,
    gastos numeric,
    total numeric,
    cvepago integer,
    capturista varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_multa, id_dependencia, axo_acta, num_acta, fecha_acta, fecha_cancelacion, contribuyente, domicilio, recaud, num_licencia, giro, calificacion, multa, gastos, total, cvepago, capturista
    FROM multas
    WHERE id_multa = p_id_multa;
END;
$$ LANGUAGE plpgsql;