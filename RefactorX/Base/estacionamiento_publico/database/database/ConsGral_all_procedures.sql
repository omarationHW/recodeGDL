-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ConsGral
-- Generado: 2025-08-27 13:28:56
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp14_afolios
-- Tipo: Report
-- Descripción: Devuelve los folios asociados a una placa desde la fuente principal (equivalente a la consulta de ta14_datos_edo y ta14_folios_histo en Delphi).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp14_afolios(parPlaca VARCHAR)
RETURNS TABLE (
    tipoact VARCHAR(2),
    placa VARCHAR(9),
    axo INTEGER,
    folio INTEGER,
    fechaalta DATE,
    fechapago DATE,
    fechacancelado DATE,
    importe NUMERIC(18,2),
    folioecmpio VARCHAR(50),
    remesa VARCHAR(50),
    fecharemesa DATE,
    concepto VARCHAR(120),
    fecha_in DATE,
    fecha_fin DATE,
    fecha_aplic DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.tipoact,
        a.placa,
        a.axo,
        a.folio,
        a.fechaalta,
        a.fechapago,
        a.fechacancelado,
        a.importe,
        a.folioecmpio,
        a.remesa,
        a.fecharemesa,
        a.concepto,
        NULL::DATE AS fecha_in,
        NULL::DATE AS fecha_fin,
        NULL::DATE AS fecha_aplic
    FROM ta14_datos_edo a
    WHERE a.placa = parPlaca
    UNION ALL
    SELECT 
        'PN' AS tipoact,
        c.placa,
        c.axo,
        c.folio,
        c.fecha_folio AS fechaalta,
        c.fecha_movto AS fechapago,
        CURRENT_DATE AS fechacancelado,
        0 AS importe,
        'Banorte sucursal ' || d.sucursal AS folioecmpio,
        'no proviene de remesa' AS remesa,
        CURRENT_DATE AS fecharemesa,
        'pagos elec.' AS concepto,
        NULL::DATE AS fecha_in,
        NULL::DATE AS fecha_fin,
        NULL::DATE AS fecha_aplic
    FROM ta14_folios_histo c
    JOIN ta14_fol_banorte d ON d.axo = c.axo AND d.folio = c.folio
    WHERE c.placa = parPlaca;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp14_bfolios
-- Tipo: Report
-- Descripción: Devuelve los folios asociados a una placa desde la fuente secundaria (equivalente a la consulta de ta14_datos_mpio en Delphi).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp14_bfolios(parPlaca VARCHAR)
RETURNS TABLE (
    tipoact VARCHAR(2),
    placa VARCHAR(9),
    axo INTEGER,
    folio INTEGER,
    fechaalta DATE,
    fechapago DATE,
    fechacancelado DATE,
    importe NUMERIC(18,2),
    folioecmpio VARCHAR(50),
    remesa VARCHAR(50),
    fecharemesa DATE,
    concepto VARCHAR(120),
    fecha_in DATE,
    fecha_fin DATE,
    fecha_aplic DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b.tipoact,
        b.placa,
        b.axo,
        b.folio,
        b.fechaalta,
        b.fechapago,
        b.fechacancelado,
        b.importe,
        b.folioecmpio,
        b.remesa,
        b.fecharemesa,
        b.concepto,
        b.fecha_in,
        b.fecha_fin,
        b.fecha_aplic
    FROM ta14_datos_mpio b
    WHERE b.placa = parPlaca;
END;
$$ LANGUAGE plpgsql;

-- ============================================

