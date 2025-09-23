-- Stored Procedure: cons14_solicrep_c
-- Tipo: Report
-- Descripción: Obtiene la relación de descuentos otorgados en un rango de fechas.
-- Generado para formulario: Reportes_Folios
-- Fecha: 2025-08-27 13:56:43

CREATE OR REPLACE PROCEDURE cons14_solicrep_c(
    IN parFec_Inicio date,
    IN parFec_Fin date
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Ejemplo: Debe adaptarse a la lógica real de negocio
    SELECT * FROM descuentos_otorgados
    WHERE fecha_otorga BETWEEN parFec_Inicio AND parFec_Fin;
END;
$$;