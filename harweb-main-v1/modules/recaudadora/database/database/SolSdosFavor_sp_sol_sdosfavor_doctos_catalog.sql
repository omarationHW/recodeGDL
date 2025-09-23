-- Stored Procedure: sp_sol_sdosfavor_doctos_catalog
-- Tipo: Catalog
-- Descripción: Catálogo de documentos para solicitudes de saldo a favor
-- Generado para formulario: SolSdosFavor
-- Fecha: 2025-08-27 15:52:47

CREATE TABLE IF NOT EXISTS doctos_catalog (
    id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL
);

INSERT INTO doctos_catalog (nombre) VALUES
('Comprobante de domicilio'),
('Acta de matrimonio'),
('Acta de nacimiento'),
('Poder simple'),
('Poder certificado'),
('Identificación'),
('Requerimiento'),
('Poder notarial'),
('Acta de Defunción')
ON CONFLICT DO NOTHING;