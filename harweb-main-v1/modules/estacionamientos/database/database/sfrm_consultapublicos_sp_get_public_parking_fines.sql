-- Stored Procedure: sp_get_public_parking_fines
-- Tipo: Report
-- Descripción: Obtiene las multas asociadas a un número de licencia.
-- Generado para formulario: sfrm_consultapublicos
-- Fecha: 2025-08-27 16:04:06

CREATE OR REPLACE FUNCTION sp_get_public_parking_fines(numlicencia integer)
RETURNS TABLE (
    id_multa integer,
    id_dependencia smallint,
    axo_acta smallint,
    num_acta integer,
    fecha_acta date,
    fecha_recepcion date,
    contribuyente varchar(50),
    domicilio varchar(80),
    recaud smallint,
    num_licencia integer,
    giro varchar(80),
    id_ley smallint,
    id_infraccion smallint,
    expediente varchar(50),
    calificacion numeric(12,2),
    multa numeric(12,2),
    gastos numeric(12,2),
    total numeric(12,2),
    fecha_plazo date,
    comentario varchar(255),
    tipo varchar(1),
    noexterior varchar(6),
    interior varchar(5)
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_multa, id_dependencia, axo_acta, num_acta, fecha_acta,
           fecha_recepcion, contribuyente, domicilio, recaud, num_licencia, giro,
           id_ley, id_infraccion, expediente, calificacion, multa, gastos, total,
           fecha_plazo, comentario, tipo, noexterior, interior
    FROM multas
    WHERE num_licencia = numlicencia;
END;
$$ LANGUAGE plpgsql;