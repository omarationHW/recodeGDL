-- Stored Procedure: sp_firmaelectronica_listar_firmas_generadas
-- Tipo: Report
-- Descripción: Lista las firmas generadas para un módulo y fecha.
-- Generado para formulario: FirmaElectronica
-- Fecha: 2025-08-27 13:50:15

CREATE OR REPLACE FUNCTION sp_firmaelectronica_listar_firmas_generadas(pmod integer, pfec date)
RETURNS TABLE(
  secuencia integer,
  digverificador varchar,
  modulo integer,
  id_modulo integer,
  fechagraba timestamp,
  firmante varchar,
  cargo varchar,
  fecha_firmado varchar,
  hash varchar
) AS $$
BEGIN
  RETURN QUERY
  SELECT a.secuencia, a.digverificador, a.modulo, a.id_modulo, a.fechagraba, b.firmante, a.cargo, a.fecha_firmado, a.hash
  FROM tb_fea a
  JOIN tb_firmante b ON b.puesto = a.cargo
  WHERE a.modulo = pmod AND CAST(a.fechagraba AS DATE) = pfec;
END;
$$ LANGUAGE plpgsql;