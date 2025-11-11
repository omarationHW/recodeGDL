-- =====================================================
-- SP: sp_actuaciones_list
-- Descripción: Lista actuaciones procesales de apremios
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-10
-- Base: estacionamiento_exclusivo
-- Esquema: public
-- =====================================================

CREATE OR REPLACE FUNCTION sp_actuaciones_list(
  p_expediente VARCHAR(50) DEFAULT NULL,
  p_desde DATE DEFAULT NULL,
  p_hasta DATE DEFAULT NULL
)
RETURNS TABLE (
  id_actuacion INTEGER,
  expediente VARCHAR(50),
  folio VARCHAR(50),
  fecha DATE,
  tipo_actuacion VARCHAR(100),
  descripcion TEXT,
  funcionario VARCHAR(100),
  observaciones TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    a.id_control AS id_actuacion,
    a.expediente::VARCHAR(50),
    a.folio::VARCHAR(50),
    a.fecha_actuacion AS fecha,
    a.tipo_actuacion::VARCHAR(100),
    a.descripcion_actuacion AS descripcion,
    a.funcionario::VARCHAR(100),
    a.observaciones AS observaciones
  FROM ta_15_apremios a
  WHERE 1=1
    AND (p_expediente IS NULL OR a.expediente ILIKE '%' || p_expediente || '%')
    AND (p_desde IS NULL OR a.fecha_actuacion >= p_desde)
    AND (p_hasta IS NULL OR a.fecha_actuacion <= p_hasta)
    AND a.fecha_actuacion IS NOT NULL
  ORDER BY a.fecha_actuacion DESC, a.id_control DESC;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Notas:
-- - Lista todas las actuaciones procesales registradas
-- - Filtros opcionales por expediente y rango de fechas
-- - Ordenado por fecha descendente
-- =====================================================

-- Ejemplo de uso:
-- SELECT * FROM sp_actuaciones_list(NULL, NULL, NULL);
-- SELECT * FROM sp_actuaciones_list('EXP-001', '2025-01-01', '2025-12-31');
