-- Stored Procedure: sp_cuentas_list
-- Tipo: Catalog
-- Descripción: Lista de cuentas de ingreso
-- Generado para formulario: CatalogoMntto
-- Fecha: 2025-08-26 23:06:58

CREATE OR REPLACE FUNCTION sp_cuentas_list()
RETURNS TABLE (cta_aplicacion INTEGER, descripcion VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT cta_aplicacion, descripcion FROM ta_12_cuentas ORDER BY cta_aplicacion;
END;
$$ LANGUAGE plpgsql;