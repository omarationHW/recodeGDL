-- Stored Procedure: del34_gen_contrato
-- Tipo: CRUD
-- Descripción: Aplica la baja/cancelación de una concesión
-- Generado para formulario: GBaja
-- Fecha: 2025-08-27 23:42:06

CREATE OR REPLACE FUNCTION del34_gen_contrato(par_tabla integer, par_id_34_datos integer, par_Axo_Fin integer, par_Mes_Fin integer, par_usuario text)
RETURNS TABLE (
  status integer,
  concepto_status text
) AS $$
DECLARE
  v_exists integer;
BEGIN
  -- Validar si existe el registro y está vigente
  SELECT COUNT(*) INTO v_exists FROM t34_datos WHERE id_34_datos = par_id_34_datos AND cve_tab = par_tabla AND id_stat IN (SELECT id_34_stat FROM t34_status WHERE descripcion = 'VIGENTE');
  IF v_exists = 0 THEN
    RETURN QUERY SELECT -1, 'No existe registro vigente para cancelar';
    RETURN;
  END IF;
  -- Validar que no existan adeudos pendientes
  IF EXISTS (
    SELECT 1 FROM t34_conceptos WHERE id_datos = par_id_34_datos AND (axo > par_Axo_Fin OR (axo = par_Axo_Fin AND mes > par_Mes_Fin)) AND importe_pagar > 0
  ) THEN
    RETURN QUERY SELECT -2, 'No es posible dar de baja, existen adeudos posteriores';
    RETURN;
  END IF;
  -- Actualizar registro a cancelado
  UPDATE t34_datos SET id_stat = (SELECT id_34_stat FROM t34_status WHERE descripcion = 'CANCELADO'), fecha_fin = make_date(par_Axo_Fin, par_Mes_Fin, 1), usuario_baja = par_usuario WHERE id_34_datos = par_id_34_datos;
  RETURN QUERY SELECT 1, 'Se ejecutó correctamente la cancelación del Local/Concesión';
END;
$$ LANGUAGE plpgsql;