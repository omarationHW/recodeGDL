-- =====================================================
-- SP: APREMIOSSVN_PAGOS_ESTADISTICAS
-- Descripción: Obtiene estadísticas de pagos (conteo y montos)
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-09
-- =====================================================

CREATE PROCEDURE APREMIOSSVN_PAGOS_ESTADISTICAS()
RETURNING
  VARCHAR(50) AS categoria,
  VARCHAR(100) AS descripcion,
  INTEGER AS total,
  DECIMAL(5,2) AS porcentaje,
  VARCHAR(20) AS clase;

DEFINE v_total_pagos INTEGER;
DEFINE v_total_efectivo INTEGER;
DEFINE v_total_cheque INTEGER;
DEFINE v_total_transferencia INTEGER;
DEFINE v_suma_capital DECIMAL(15,2);
DEFINE v_suma_recargos DECIMAL(15,2);

-- Obtener totales
SELECT COUNT(*) INTO v_total_pagos
FROM pagos
WHERE activo = 1;

SELECT COUNT(*) INTO v_total_efectivo
FROM pagos
WHERE activo = 1 AND forma_pago = 'EFECTIVO';

SELECT COUNT(*) INTO v_total_cheque
FROM pagos
WHERE activo = 1 AND forma_pago = 'CHEQUE';

SELECT COUNT(*) INTO v_total_transferencia
FROM pagos
WHERE activo = 1 AND forma_pago = 'TRANSFERENCIA';

-- Obtener sumas
SELECT COALESCE(SUM(monto_capital), 0) INTO v_suma_capital
FROM pagos
WHERE activo = 1;

SELECT COALESCE(SUM(monto_recargos), 0) INTO v_suma_recargos
FROM pagos
WHERE activo = 1;

-- Evitar división por cero
IF v_total_pagos = 0 THEN
  LET v_total_pagos = 1;
END IF;

-- Retornar estadísticas
RETURN
  'TOTAL',
  'Total de Pagos',
  v_total_pagos,
  100.00,
  'default'
WITH RESUME;

RETURN
  'EFECTIVO',
  'Pagos en Efectivo',
  v_total_efectivo,
  (v_total_efectivo::DECIMAL / v_total_pagos * 100),
  'V'
WITH RESUME;

RETURN
  'CHEQUE',
  'Pagos con Cheque',
  v_total_cheque,
  (v_total_cheque::DECIMAL / v_total_pagos * 100),
  'A'
WITH RESUME;

RETURN
  'TRANSFERENCIA',
  'Pagos por Transferencia',
  v_total_transferencia,
  (v_total_transferencia::DECIMAL / v_total_pagos * 100),
  'P'
WITH RESUME;

RETURN
  'CAPITAL',
  'Total Capital Recuperado',
  v_suma_capital::INTEGER,
  (v_suma_capital / (v_suma_capital + v_suma_recargos) * 100),
  'E'
WITH RESUME;

RETURN
  'RECARGOS',
  'Total Recargos Cobrados',
  v_suma_recargos::INTEGER,
  (v_suma_recargos / (v_suma_capital + v_suma_recargos) * 100),
  'C';

END PROCEDURE;

-- =====================================================
-- Notas:
-- - Asume que existe tabla pagos con campo activo
-- - Ajustar valores de forma_pago según esquema real
-- - Los totales de capital y recargos se muestran como enteros
-- - Ejecutar con permisos de creación de procedures
-- =====================================================
