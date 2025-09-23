-- Stored Procedure: sp_repdoc_print_permisos_eventuales
-- Tipo: Report
-- Descripción: Genera el PDF de requisitos para permisos eventuales
-- Generado para formulario: repdoc
-- Fecha: 2025-08-26 17:50:37

CREATE OR REPLACE FUNCTION sp_repdoc_print_permisos_eventuales()
RETURNS TEXT AS $$
BEGIN
  RETURN '/storage/repdoc/permisos_eventuales.pdf';
END;
$$ LANGUAGE plpgsql;