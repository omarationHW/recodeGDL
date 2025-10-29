-- Stored Procedure: sp_cve_cuota_delete
-- Tipo: CRUD
-- Descripción: Elimina una clave de cuota por clave_cuota
-- Generado para formulario: CveCuotaMntto
-- Fecha: 2025-08-26 23:38:43

CREATE OR REPLACE PROCEDURE sp_cve_cuota_delete(
    p_clave_cuota INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM ta_11_cve_cuota WHERE clave_cuota = p_clave_cuota;
END;
$$;