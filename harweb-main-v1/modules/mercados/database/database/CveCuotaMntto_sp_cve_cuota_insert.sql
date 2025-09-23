-- Stored Procedure: sp_cve_cuota_insert
-- Tipo: CRUD
-- Descripción: Inserta una nueva clave de cuota en ta_11_cve_cuota
-- Generado para formulario: CveCuotaMntto
-- Fecha: 2025-08-26 23:38:43

CREATE OR REPLACE PROCEDURE sp_cve_cuota_insert(
    p_clave_cuota INTEGER,
    p_descripcion VARCHAR(60)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO ta_11_cve_cuota (clave_cuota, descripcion)
    VALUES (p_clave_cuota, p_descripcion);
END;
$$;