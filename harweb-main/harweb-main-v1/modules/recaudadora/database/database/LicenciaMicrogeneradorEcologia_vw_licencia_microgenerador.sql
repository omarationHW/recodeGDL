-- Stored Procedure: vw_licencia_microgenerador
-- Tipo: Catalog
-- Descripción: Vista para consulta de datos de licencia para microgenerador.
-- Generado para formulario: LicenciaMicrogeneradorEcologia
-- Fecha: 2025-08-27 12:38:05

-- Vista para consulta de licencia
CREATE OR REPLACE VIEW vw_licencia_microgenerador AS
SELECT id_licencia, licencia, trim(coalesce(propietario, '')) || ' ' || trim(coalesce(primer_ap, '')) || ' ' || trim(coalesce(segundo_ap, '')) AS nombre,
       trim(coalesce(ubicacion, '')) || ' ' || trim(coalesce(numext_ubic, '')) || ' ' || trim(coalesce(letraext_ubic, '')) || ' ' || trim(coalesce(numint_ubic, '')) || ' ' || trim(coalesce(letraint_ubic, '')) AS ubicacion,
       actividad
FROM licencias WHERE vigente = 'V';
