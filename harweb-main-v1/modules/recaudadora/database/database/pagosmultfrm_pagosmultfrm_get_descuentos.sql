-- Stored Procedure: pagosmultfrm_get_descuentos
-- Tipo: Report
-- Descripción: Obtiene los descuentos aplicados a una multa.
-- Generado para formulario: pagosmultfrm
-- Fecha: 2025-08-27 14:09:11

CREATE OR REPLACE FUNCTION pagosmultfrm_get_descuentos(
    p_id_multa INTEGER
)
RETURNS TABLE (
    id_descuento INTEGER,
    tipo_descto TEXT,
    valor NUMERIC,
    feccap DATE,
    capturista TEXT,
    observacion TEXT,
    autoriza TEXT,
    descripcion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.id_descuento, d.tipo_descto, d.valor, d.feccap, d.capturista, d.observacion, d.autoriza, c.descripcion
    FROM descmultampal d
    LEFT JOIN c_autdescmul c ON d.autoriza = c.cveautoriza
    WHERE d.id_multa = p_id_multa AND d.estado <> 'C';
END;
$$ LANGUAGE plpgsql;