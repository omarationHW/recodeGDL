-- Stored Procedure: sp_cve_cuota_update
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de una clave de cuota
-- Generado para formulario: CveCuotaMntto
-- Fecha: 2025-08-26 23:38:43

CREATE OR REPLACE PROCEDURE sp_cve_cuota_update(
    p_clave_cuota INTEGER,
    p_descripcion VARCHAR(60)
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE ta_11_cve_cuota
    SET descripcion = p_descripcion
    WHERE clave_cuota = p_clave_cuota;
END;
$$;