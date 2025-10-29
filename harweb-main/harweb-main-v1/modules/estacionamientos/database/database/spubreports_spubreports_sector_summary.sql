-- Stored Procedure: spubreports_sector_summary
-- Tipo: Report
-- Descripción: Resumen de estacionamientos públicos por categoría y sector (Juarez, Reforma, Libertad, Hidalgo, Total).
-- Generado para formulario: spubreports
-- Fecha: 2025-08-27 14:52:31

CREATE OR REPLACE FUNCTION spubreports_sector_summary()
RETURNS TABLE (
    categoria varchar(10),
    descripcion varchar(100),
    cant_j integer, capac_j integer,
    cant_r integer, capac_r integer,
    cant_l integer, capac_l integer,
    cant_h integer, capac_h integer,
    cant_t integer, capac_t integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.categoria,
        c.descripcion,
        SUM(CASE WHEN m.sector = 'J' THEN 1 ELSE 0 END) AS cant_j,
        SUM(CASE WHEN m.sector = 'J' THEN m.cupo ELSE 0 END) AS capac_j,
        SUM(CASE WHEN m.sector = 'R' THEN 1 ELSE 0 END) AS cant_r,
        SUM(CASE WHEN m.sector = 'R' THEN m.cupo ELSE 0 END) AS capac_r,
        SUM(CASE WHEN m.sector = 'L' THEN 1 ELSE 0 END) AS cant_l,
        SUM(CASE WHEN m.sector = 'L' THEN m.cupo ELSE 0 END) AS capac_l,
        SUM(CASE WHEN m.sector = 'H' THEN 1 ELSE 0 END) AS cant_h,
        SUM(CASE WHEN m.sector = 'H' THEN m.cupo ELSE 0 END) AS capac_h,
        COUNT(*) AS cant_t,
        SUM(m.cupo) AS capac_t
    FROM pubmain m
    JOIN pubcategoria c ON c.id = m.pubcategoria_id
    WHERE m.movto_cve <> 'C'
    GROUP BY c.categoria, c.descripcion
    ORDER BY c.categoria;
END;
$$ LANGUAGE plpgsql;