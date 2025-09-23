-- Stored Procedure: spd_17_limpia_paso
-- Tipo: CRUD
-- Descripción: Limpia la tabla de paso de contratos (ta_17_paso_cont)
-- Generado para formulario: PasoContratos
-- Fecha: 2025-08-27 15:10:36

CREATE OR REPLACE PROCEDURE spd_17_limpia_paso()
LANGUAGE plpgsql
AS $$
BEGIN
    TRUNCATE TABLE ta_17_paso_cont RESTART IDENTITY;
END;
$$;