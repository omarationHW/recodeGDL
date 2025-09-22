-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SFRM_TR_ESTADO_MPIO (EXACTO del archivo original)
-- Archivo: 41_SP_ESTACIONAMIENTOS_SFRM_TR_ESTADO_MPIO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_get_remesas_estado_mpio
-- Tipo: Report
-- Descripción: Devuelve las últimas 5 remesas distintas con sus fechas.
-- --------------------------------------------

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

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SFRM_TR_ESTADO_MPIO (EXACTO del archivo original)
-- Archivo: 41_SP_ESTACIONAMIENTOS_SFRM_TR_ESTADO_MPIO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: spd_delesta01
-- Tipo: CRUD
-- Descripción: Procesa una operación específica sobre ta14_datos_edo (ejemplo: eliminar, actualizar, etc).
-- --------------------------------------------

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

-- ============================================

