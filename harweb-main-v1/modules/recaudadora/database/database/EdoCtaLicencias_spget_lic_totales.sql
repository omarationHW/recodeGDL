-- Stored Procedure: spget_lic_totales
-- Tipo: Report
-- Descripción: Obtiene los totales agrupados de una licencia o anuncio.
-- Generado para formulario: EdoCtaLicencias
-- Fecha: 2025-08-27 01:16:30

CREATE OR REPLACE FUNCTION spget_lic_totales(par_id integer, par_tipo varchar, par_no varchar)
RETURNS TABLE (
  grupo integer,
  cuenta integer,
  obliga varchar,
  concepto varchar,
  importe numeric
) AS $$
BEGIN
  IF par_tipo = 'L' THEN
    RETURN QUERY SELECT * FROM v_lic_totales WHERE id_licencia = par_id AND no = par_no;
  ELSE
    RETURN QUERY SELECT * FROM v_anun_totales WHERE id_anuncio = par_id AND no = par_no;
  END IF;
END;
$$ LANGUAGE plpgsql;