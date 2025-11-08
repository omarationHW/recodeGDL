-- Fix: TramiteBajaAnun_calc_sdosl
-- Corrección: usar public.saldos_lic y public.lic_cancel

DROP FUNCTION IF EXISTS comun.TramiteBajaAnun_calc_sdosl(INTEGER);

CREATE OR REPLACE FUNCTION comun.TramiteBajaAnun_calc_sdosl(p_id_licencia INTEGER)
RETURNS VOID AS $$
BEGIN
    -- Recalcular el saldo de la licencia
    -- La tabla saldos_lic está en public, no en comun
    -- La tabla detsal_lic está en comun

    UPDATE public.saldos_lic sl
    SET saldo = (
        SELECT COALESCE(SUM(ds.saldo), 0)
        FROM comun.detsal_lic ds
        WHERE ds.id_licencia = p_id_licencia
        AND ds.cvepago = 0
    )
    WHERE sl.id_licencia = p_id_licencia;

    -- Si no existe registro en saldos_lic, crear uno
    IF NOT FOUND THEN
        INSERT INTO public.saldos_lic (id_licencia, saldo)
        SELECT p_id_licencia, COALESCE(SUM(ds.saldo), 0)
        FROM comun.detsal_lic ds
        WHERE ds.id_licencia = p_id_licencia
        AND ds.cvepago = 0;
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.TramiteBajaAnun_calc_sdosl(INTEGER) IS
'Recalcula el saldo total de una licencia sumando los detsal_lic pendientes. FIXED: usa public.saldos_lic';
