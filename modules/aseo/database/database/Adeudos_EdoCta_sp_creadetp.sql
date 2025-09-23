-- Stored Procedure: sp_creadetp
-- Tipo: CRUD
-- Descripción: Crea el detalle de pagos para todos los contratos (limpia y prepara la tabla det_pagos)
-- Generado para formulario: Adeudos_EdoCta
-- Fecha: 2025-08-27 13:42:14

CREATE OR REPLACE PROCEDURE sp_creadetp()
LANGUAGE plpgsql
AS $$
BEGIN
  -- Limpia la tabla det_pagos (o realiza el proceso de preparación)
  TRUNCATE TABLE det_pagos;
  -- Aquí se puede poblar det_pagos según la lógica de negocio
  -- Por ejemplo, copiar de pagos vigentes, etc.
  -- ...
END;
$$;