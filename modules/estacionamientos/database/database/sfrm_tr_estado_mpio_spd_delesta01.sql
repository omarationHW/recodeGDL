-- Stored Procedure: spd_delesta01
-- Tipo: CRUD
-- Descripción: Procesa una operación específica sobre ta14_datos_edo (ejemplo: eliminar, actualizar, etc).
-- Generado para formulario: sfrm_tr_estado_mpio
-- Fecha: 2025-08-27 14:39:40

CREATE OR REPLACE FUNCTION spd_delesta01(
  axo SMALLINT,
  folio INTEGER,
  placa TEXT,
  convenio INTEGER,
  fecha DATE,
  reca SMALLINT,
  caja TEXT,
  oper INTEGER,
  usuauto INTEGER,
  opc SMALLINT
)
RETURNS TABLE(result_code SMALLINT, result_msg TEXT)
LANGUAGE plpgsql AS $$
BEGIN
  -- Ejemplo: Eliminar registro por folio y placa
  IF opc = 1 THEN
    DELETE FROM ta14_datos_edo WHERE folio = folio AND placa = placa;
    RETURN QUERY SELECT 0, 'Registro eliminado';
  ELSE
    RETURN QUERY SELECT 1, 'Operación no implementada';
  END IF;
END;
$$;