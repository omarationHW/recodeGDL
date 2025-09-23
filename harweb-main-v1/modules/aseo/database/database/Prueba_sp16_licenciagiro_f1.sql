-- Stored Procedure: sp16_licenciagiro_f1
-- Tipo: CRUD
-- Descripción: Obtiene información de licencia de giro para un tipo y número de contrato.
-- Generado para formulario: Prueba
-- Fecha: 2025-08-27 15:03:39

-- PostgreSQL version of sp16_LicenciaGiro_F1
CREATE OR REPLACE FUNCTION sp16_licenciagiro_f1(p_tipo VARCHAR, p_numero INTEGER)
RETURNS TABLE(status_licencias INTEGER, concepto_licencias VARCHAR)
LANGUAGE plpgsql AS $$
BEGIN
  -- Simulación: Buscar si existe relación de licencia para el contrato
  IF EXISTS (
    SELECT 1 FROM ta_16_rel_licgiro rl
    JOIN ta_16_contratos c ON c.control_contrato = rl.control_contrato
    WHERE c.tipo_aseo = p_tipo AND c.num_contrato = p_numero
  ) THEN
    RETURN QUERY
      SELECT 0 AS status_licencias, 'Licencia relacionada encontrada' AS concepto_licencias;
  ELSE
    RETURN QUERY
      SELECT 1 AS status_licencias, 'No existe relación de licencia para este contrato' AS concepto_licencias;
  END IF;
END;
$$;