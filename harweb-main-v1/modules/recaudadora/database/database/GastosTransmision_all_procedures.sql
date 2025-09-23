-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: GastosTransmision
-- Generado: 2025-08-27 12:18:50
-- Total SPs: 2
-- ============================================

-- SP 1/2: consulta_foliotransm
-- Tipo: CRUD
-- Descripción: Consulta los importes y estado de un folio de transmisión patrimonial o diferencia.
-- --------------------------------------------

-- PostgreSQL stored procedure for consulta_foliotransm
CREATE OR REPLACE FUNCTION consulta_foliotransm(pfolio integer, popc varchar)
RETURNS TABLE (
    impuesto numeric,
    recargos numeric,
    multaext numeric,
    multaimp numeric,
    gastos numeric,
    actualizacion numeric,
    total numeric,
    folioglosa integer,
    estatus integer,
    mensaje varchar
) AS $$
DECLARE
    v_folio RECORD;
BEGIN
    -- Buscar el folio en la tabla correspondiente
    IF popc = 'T' THEN
        SELECT f.*, d.folioglosa INTO v_folio
        FROM transmision_patrimonial f
        LEFT JOIN transmision_glosa d ON d.folio = f.folio
        WHERE f.folio = pfolio;
    ELSIF popc = 'D' THEN
        SELECT f.*, d.folioglosa INTO v_folio
        FROM diferencia_transmision f
        LEFT JOIN transmision_glosa d ON d.folio = f.folio
        WHERE f.folio = pfolio;
    ELSE
        RETURN QUERY SELECT 0,0,0,0,0,0,0,NULL,1,'Tipo de módulo inválido';
        RETURN;
    END IF;
    IF v_folio IS NULL THEN
        RETURN QUERY SELECT 0,0,0,0,0,0,0,NULL,1,'Folio no encontrado';
        RETURN;
    END IF;
    RETURN QUERY SELECT
        v_folio.impuesto,
        v_folio.recargos,
        v_folio.multaext,
        v_folio.multaimp,
        v_folio.gastos,
        v_folio.actualizacion,
        v_folio.total,
        v_folio.folioglosa,
        0,
        'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: afecta_gastostransm
-- Tipo: CRUD
-- Descripción: Aplica el gasto capturado al folio de transmisión patrimonial o diferencia.
-- --------------------------------------------

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

-- ============================================

