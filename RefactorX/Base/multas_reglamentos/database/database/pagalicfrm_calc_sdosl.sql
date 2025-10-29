-- Stored Procedure: calc_sdosl
-- Tipo: CRUD
-- Descripción: Recalcula los saldos de una licencia después de marcar como pagado.
-- Generado para formulario: pagalicfrm
-- Fecha: 2025-08-27 14:01:39

CREATE OR REPLACE PROCEDURE calc_sdosl(IN id_licencia_in integer)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Aquí va la lógica de recálculo de saldos para la licencia
    -- Por ejemplo, actualizar campos de saldo en detsal_lic, licencias, etc.
    -- Esta lógica debe ser adaptada a las reglas de negocio reales
    UPDATE detsal_lic
    SET saldo = 0
    WHERE id_licencia = id_licencia_in AND cvepago = 999999999;
    -- Otras actualizaciones necesarias...
END;
$$;