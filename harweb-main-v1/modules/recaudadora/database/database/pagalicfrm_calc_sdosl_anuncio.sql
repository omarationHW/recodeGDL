-- Stored Procedure: calc_sdosl_anuncio
-- Tipo: CRUD
-- Descripción: Recalcula los saldos de un anuncio después de marcar como pagado.
-- Generado para formulario: pagalicfrm
-- Fecha: 2025-08-27 14:01:39

CREATE OR REPLACE PROCEDURE calc_sdosl_anuncio(IN id_anuncio_in integer)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Lógica de recálculo de saldos para el anuncio
    UPDATE detsal_lic
    SET saldo = 0
    WHERE id_anuncio = id_anuncio_in AND cvepago = 999999999;
    -- Otras actualizaciones necesarias...
END;
$$;