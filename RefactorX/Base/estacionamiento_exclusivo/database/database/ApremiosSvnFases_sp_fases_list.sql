-- =====================================================
-- SP: sp_fases_list
-- Descripción: Lista historial de fases de expedientes de apremios
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-10
-- Base: estacionamiento_exclusivo
-- Esquema: public
-- =====================================================

CREATE OR REPLACE FUNCTION sp_fases_list()
RETURNS TABLE (
  id_control INTEGER,
  expediente VARCHAR(50),
  folio VARCHAR(50),
  fase_actual VARCHAR(50),
  fecha_fase DATE,
  fase_anterior VARCHAR(50),
  usuario VARCHAR(50),
  observaciones TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    a.id_control,
    a.expediente::VARCHAR(50),
    a.folio::VARCHAR(50),
    a.fase::VARCHAR(50) AS fase_actual,
    a.fecha_fase,
    a.fase_anterior::VARCHAR(50),
    a.usuario_modificacion::VARCHAR(50) AS usuario,
    a.observaciones
  FROM ta_15_apremios a
  WHERE a.fase IS NOT NULL
  ORDER BY a.fecha_fase DESC NULLS LAST, a.id_control DESC;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Notas:
-- - Lista todas las fases de expedientes
-- - Ordenado por fecha de fase descendente
-- - Muestra fase actual y anterior para tracking
-- =====================================================

-- Ejemplo de uso:
-- SELECT * FROM sp_fases_list();
