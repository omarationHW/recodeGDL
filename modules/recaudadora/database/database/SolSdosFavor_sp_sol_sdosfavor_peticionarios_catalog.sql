-- Stored Procedure: sp_sol_sdosfavor_peticionarios_catalog
-- Tipo: Catalog
-- Descripción: Catálogo de peticionarios
-- Generado para formulario: SolSdosFavor
-- Fecha: 2025-08-27 15:52:47

CREATE TABLE IF NOT EXISTS peticionarios_catalog (
    id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL
);

INSERT INTO peticionarios_catalog (nombre) VALUES
('PROPIETARIO'),
('COPROPIETARIO'),
('ALBACEA'),
('APODERADO'),
('SUJETO DEL IMPTO. PREDIAL'),
('FAMILIAR EN 1er GRADO')
ON CONFLICT DO NOTHING;