-- Stored Procedure: vw_tramite_microgenerador
-- Tipo: Catalog
-- Descripción: Vista para consulta de datos de trámite para microgenerador.
-- Generado para formulario: LicenciaMicrogeneradorEcologia
-- Fecha: 2025-08-27 12:38:05

-- Vista para consulta de trámite
CREATE OR REPLACE VIEW vw_tramite_microgenerador AS
SELECT id_tramite, folio, id_licencia, licencia_ref,
       trim(coalesce(propietario, '')) || ' ' || trim(coalesce(primer_ap, '')) || ' ' || trim(coalesce(segundo_ap, '')) AS nombre,
       trim(coalesce(ubicacion, '')) || ' ' || trim(coalesce(numext_ubic, '')) || ' ' || trim(coalesce(letraext_ubic, '')) || ' ' || trim(coalesce(numint_ubic, '')) || ' ' || trim(coalesce(letraint_ubic, '')) AS ubicacion,
       actividad
FROM tramites;
