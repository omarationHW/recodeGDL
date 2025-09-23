-- Stored Procedure: sp_sol_sdosfavor_inconformidades_catalog
-- Tipo: Catalog
-- Descripción: Catálogo de inconformidades
-- Generado para formulario: SolSdosFavor
-- Fecha: 2025-08-27 15:52:47

CREATE TABLE IF NOT EXISTS inconformidades_catalog (
    id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL
);

INSERT INTO inconformidades_catalog (nombre) VALUES
('PAGO ERRONEO'),
('PAGO DOBLE'),
('PAGO EN DEMASIA'),
('PAGO INDEBIDO'),
('PRESCRIPCIÓN'),
('SOLIC. DESCTOS.'),
('COND. MULTAS Y GASTOS'),
('OTROS')
ON CONFLICT DO NOTHING;