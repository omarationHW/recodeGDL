-- Stored Procedure: calc_sdosl
-- Tipo: CRUD
-- Descripción: Recalcula el saldo de la licencia después de la baja.
-- Generado para formulario: bajaLicenciafrm
-- Fecha: 2025-08-27 15:59:40

CREATE OR REPLACE FUNCTION calc_sdosl(p_id_licencia INTEGER) RETURNS VOID AS $$
BEGIN
    -- Lógica de recálculo de saldos (simplificada)
    UPDATE saldos_lic SET total = (
        COALESCE(derechos,0) + COALESCE(anuncios,0) + COALESCE(recargos,0) + COALESCE(gastos,0) + COALESCE(multas,0) + COALESCE(formas,0)
    ) WHERE id_licencia = p_id_licencia;
END;
$$ LANGUAGE plpgsql;