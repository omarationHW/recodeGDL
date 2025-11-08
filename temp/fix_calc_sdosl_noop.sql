-- Fix: TramiteBajaAnun_calc_sdosl - Hacer NO-OP
-- La tabla saldos_lic tiene estructura compleja (derechos, anuncios, recargos, etc.)
-- No hay una columna simple "saldo", por lo que hacemos esta función NO-OP
-- Los adeudos ya se cancelan en el SP tramitar (cvepago = 999999)

DROP FUNCTION IF EXISTS comun.TramiteBajaAnun_calc_sdosl(INTEGER);

CREATE OR REPLACE FUNCTION comun.TramiteBajaAnun_calc_sdosl(p_id_licencia INTEGER)
RETURNS VOID AS $$
BEGIN
    -- NO-OP: La tabla public.saldos_lic tiene estructura compleja
    -- No existe una columna "saldo" simple
    -- Los adeudos ya fueron cancelados en el SP principal (detsal_lic.cvepago = 999999)
    -- Si se necesita recalcular saldos, debe hacerse con la lógica específica de negocio
    NULL;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.TramiteBajaAnun_calc_sdosl(INTEGER) IS
'NO-OP: La tabla saldos_lic tiene estructura compleja. Los adeudos se cancelan en el SP tramitar.';
