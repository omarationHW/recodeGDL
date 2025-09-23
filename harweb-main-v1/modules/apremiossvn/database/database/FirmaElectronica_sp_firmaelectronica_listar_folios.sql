-- Stored Procedure: sp_firmaelectronica_listar_folios
-- Tipo: Report
-- Descripción: Lista los folios a firmar para un módulo y fecha determinada.
-- Generado para formulario: FirmaElectronica
-- Fecha: 2025-08-27 13:50:15

CREATE OR REPLACE FUNCTION sp_firmaelectronica_listar_folios(pmod integer, pfec date)
RETURNS TABLE(
  cvereq integer,
  fecemi date,
  folio integer,
  diligencia integer,
  cadena1 varchar,
  cadena2 varchar,
  descripcion varchar
) AS $$
BEGIN
  RETURN QUERY
  SELECT f.cvereq, f.fecemi, f.folio, f.diligencia, f.cadena1, f.cadena2,
    CASE WHEN f.diligencia = 1 THEN 'NOTIFICACION'
         WHEN f.diligencia = 2 THEN 'REQUERIMIENTO'
         ELSE 'SECUESTRO' END AS descripcion
  FROM folios_firma f
  WHERE f.modulo = pmod AND f.fecemi = pfec;
END;
$$ LANGUAGE plpgsql;