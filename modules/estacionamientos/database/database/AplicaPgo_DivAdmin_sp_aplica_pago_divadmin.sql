-- Stored Procedure: sp_aplica_pago_divadmin
-- Tipo: CRUD
-- Descripción: Aplica el pago de diversos admin para un folio específico.
-- Generado para formulario: AplicaPgo_DivAdmin
-- Fecha: 2025-08-27 13:22:25

CREATE OR REPLACE FUNCTION sp_aplica_pago_divadmin(
    parAxo integer,
    parFolio integer,
    parFecha date,
    parReca integer,
    parCaja varchar,
    parOper integer,
    parUsuario varchar
)
RETURNS TABLE (success boolean, message text) AS $$
DECLARE
BEGIN
    -- Aquí va la lógica de aplicación de pago, por ejemplo:
    UPDATE ta14_folios_adeudo
    SET estado = 2, -- ejemplo: 2 = pagado
        fecha_pago = parFecha,
        recaudadora = parReca,
        caja = parCaja,
        operacion = parOper,
        usuario_pago = parUsuario
    WHERE axo = parAxo AND folio = parFolio;

    IF FOUND THEN
        RETURN QUERY SELECT true, 'Pago aplicado correctamente';
    ELSE
        RETURN QUERY SELECT false, 'No se encontró el folio';
    END IF;
END;
$$ LANGUAGE plpgsql;