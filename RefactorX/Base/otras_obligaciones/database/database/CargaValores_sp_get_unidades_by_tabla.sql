-- Stored Procedure: sp_get_unidades_by_tabla
-- Tipo: Catalog
-- Descripción: Obtiene las unidades de una tabla para el ejercicio máximo registrado.
--              Equivalente Delphi: Busca último ejercicio y luego carga QryUnidades
-- Generado para formulario: CargaValores
-- Fecha: 2025-08-27 23:13:46
-- Actualizado: 2025-12-02 - Cambio a ejercicio máximo (no año actual)

CREATE OR REPLACE FUNCTION sp_get_unidades_by_tabla(p_cve_tab varchar)
RETURNS TABLE(ejercicio integer, cve_unidad varchar, cve_operatividad varchar, descripcion varchar, costo numeric) AS $$
DECLARE
  v_max_ejercicio integer;
BEGIN
  -- Obtener el ejercicio máximo para esta tabla
  SELECT MAX(ejercicio) INTO v_max_ejercicio FROM t34_unidades WHERE cve_tab = p_cve_tab;

  -- Si no hay ejercicios, retornar vacío
  IF v_max_ejercicio IS NULL THEN
    RETURN;
  END IF;

  -- Retornar las unidades del ejercicio máximo
  RETURN QUERY
  SELECT u.ejercicio, u.cve_unidad, u.cve_operatividad, u.descripcion, u.costo
  FROM t34_unidades u
  WHERE u.cve_tab = p_cve_tab
    AND u.ejercicio = v_max_ejercicio
  ORDER BY u.cve_unidad, u.cve_operatividad;
END;
$$ LANGUAGE plpgsql;