-- Stored Procedure: sp_get_remesas_estado_mpio
-- Tipo: Report
-- Descripción: Devuelve las últimas 5 remesas distintas con sus fechas.
-- Generado para formulario: sfrm_tr_estado_mpio
-- Fecha: 2025-08-27 14:39:40

CREATE OR REPLACE FUNCTION sp_get_remesas_estado_mpio()
RETURNS TABLE(remesa TEXT, fecharemesa DATE, aplicadoteso DATE)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY
    SELECT DISTINCT ON (remesa)
      remesa, fecharemesa, fecha_aplica_teso AS aplicadoteso
    FROM ta14_datos_edo
    ORDER BY remesa DESC, fecharemesa
    LIMIT 5;
END;
$$;