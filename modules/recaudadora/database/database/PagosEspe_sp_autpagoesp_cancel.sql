-- Stored Procedure: sp_autpagoesp_cancel
-- Tipo: CRUD
-- Descripción: Cancela un pago especial autorizado
-- Generado para formulario: PagosEspe
-- Fecha: 2025-08-27 14:06:05

CREATE OR REPLACE FUNCTION sp_autpagoesp_cancel(p_cveaut integer, p_autorizo varchar)
RETURNS void AS $$
DECLARE
    v_pago record;
BEGIN
    SELECT * INTO v_pago FROM autpagoesp WHERE cveaut = p_cveaut;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Registro no encontrado';
    END IF;
    IF v_pago.cvepago = 999999 THEN
        RAISE EXCEPTION 'El pago autorizado ya está cancelado...';
    END IF;
    IF v_pago.cvepago IS NOT NULL AND v_pago.cvepago <> 999999 THEN
        RAISE EXCEPTION 'El pago autorizado seleccionado se encuentra pagado, no puedes cancelar...';
    END IF;
    UPDATE autpagoesp SET cvepago = 999999, fecaut = CURRENT_DATE, autorizo = p_autorizo WHERE cveaut = p_cveaut;
END;
$$ LANGUAGE plpgsql;