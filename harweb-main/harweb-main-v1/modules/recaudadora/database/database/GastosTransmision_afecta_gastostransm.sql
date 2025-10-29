-- Stored Procedure: afecta_gastostransm
-- Tipo: CRUD
-- Descripción: Aplica el gasto capturado al folio de transmisión patrimonial o diferencia.
-- Generado para formulario: GastosTransmision
-- Fecha: 2025-08-27 12:18:50

-- PostgreSQL stored procedure for afecta_gastostransm
CREATE OR REPLACE FUNCTION afecta_gastostransm(pfolio integer, pgastos numeric, popc varchar, pusuario varchar)
RETURNS TABLE (
    estado integer,
    msg varchar
) AS $$
DECLARE
    v_folio RECORD;
    v_updated integer;
BEGIN
    IF popc = 'T' THEN
        SELECT * INTO v_folio FROM transmision_patrimonial WHERE folio = pfolio;
        IF v_folio IS NULL THEN
            RETURN QUERY SELECT 0, 'Folio no encontrado';
            RETURN;
        END IF;
        UPDATE transmision_patrimonial SET gastos = pgastos, usuario_gastos = pusuario, fecha_gastos = now()
        WHERE folio = pfolio;
        v_updated := FOUND;
    ELSIF popc = 'D' THEN
        SELECT * INTO v_folio FROM diferencia_transmision WHERE folio = pfolio;
        IF v_folio IS NULL THEN
            RETURN QUERY SELECT 0, 'Folio no encontrado';
            RETURN;
        END IF;
        UPDATE diferencia_transmision SET gastos = pgastos, usuario_gastos = pusuario, fecha_gastos = now()
        WHERE folio = pfolio;
        v_updated := FOUND;
    ELSE
        RETURN QUERY SELECT 0, 'Tipo de módulo inválido';
        RETURN;
    END IF;
    IF v_updated THEN
        RETURN QUERY SELECT 1, 'Gastos aplicados correctamente';
    ELSE
        RETURN QUERY SELECT 0, 'No se pudo aplicar el gasto';
    END IF;
END;
$$ LANGUAGE plpgsql;