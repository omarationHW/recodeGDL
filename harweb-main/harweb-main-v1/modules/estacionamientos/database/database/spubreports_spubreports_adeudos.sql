-- Stored Procedure: spubreports_adeudos
-- Tipo: Report
-- Descripción: Devuelve la relación de adeudos y pagos de todos los estacionamientos públicos.
-- Generado para formulario: spubreports
-- Fecha: 2025-08-27 14:52:31

CREATE OR REPLACE FUNCTION spubreports_adeudos()
RETURNS TABLE (
    id integer,
    pubcategoria_id integer,
    categoria varchar(10),
    descripcion varchar(100),
    numesta integer,
    sector varchar(10),
    nomsector varchar(20),
    nombre varchar(100),
    calle varchar(100),
    numext varchar(10),
    cupo integer,
    axo_adeudo smallint,
    mes_ini_adeudo smallint,
    adeudos_ant numeric,
    adeudos_act numeric,
    axo_ult_pago smallint,
    mes_ult_pago smallint,
    proyectado numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id, a.pubcategoria_id, b.categoria, b.descripcion, a.numesta, a.sector,
        CASE a.sector
            WHEN 'J' THEN 'JUAREZ'
            WHEN 'H' THEN 'HIDALGO'
            WHEN 'L' THEN 'LIBERTAD'
            WHEN 'R' THEN 'REFORMA'
            ELSE 'S/N'
        END AS nomsector,
        a.nombre, a.calle, a.numext, a.cupo,
        (
            SELECT min(d.axo) FROM pubadeudo d WHERE d.pubmain_id = a.id AND tipo = 10
        ) AS axo_adeudo,
        (
            SELECT min(d.mes) FROM pubadeudo d WHERE d.pubmain_id = a.id AND tipo = 10
                AND axo = (
                    SELECT min(d2.axo) FROM pubadeudo d2 WHERE d2.pubmain_id = a.id AND tipo = 10
                )
        ) AS mes_ini_adeudo,
        (
            SELECT sum(c.ade_importe) FROM pubadeudo c WHERE c.pubmain_id = a.id AND c.axo < EXTRACT(YEAR FROM CURRENT_DATE)
        ) AS adeudos_ant,
        (
            SELECT sum(c.ade_importe) FROM pubadeudo c WHERE c.pubmain_id = a.id AND c.axo = EXTRACT(YEAR FROM CURRENT_DATE) AND (c.axo * 100) + c.mes <= (EXTRACT(YEAR FROM CURRENT_DATE) * 100) + EXTRACT(MONTH FROM CURRENT_DATE)
        ) AS adeudos_act,
        (
            SELECT sum(c.ade_importe) FROM pubadeudo c WHERE c.pubmain_id = a.id AND c.axo = EXTRACT(YEAR FROM CURRENT_DATE) AND (c.axo * 100) + c.mes > (EXTRACT(YEAR FROM CURRENT_DATE) * 100) + EXTRACT(MONTH FROM CURRENT_DATE)
        ) AS proyectado,
        (
            SELECT max(d.axo) FROM pubadeudo_histo d WHERE d.pubmain_id = a.id AND motivo = 'Pago En Reca'
        ) AS axo_ult_pago,
        (
            SELECT max(d.mes) FROM pubadeudo_histo d WHERE d.pubmain_id = a.id AND motivo = 'Pago En Reca' AND axo = (
                SELECT max(d2.axo) FROM pubadeudo_histo d2 WHERE d2.pubmain_id = a.id AND motivo = 'Pago En Reca'
            )
        ) AS mes_ult_pago
    FROM pubmain a
    JOIN pubcategoria b ON b.id = a.pubcategoria_id
    WHERE a.movto_cve <> 'C'
    ORDER BY a.numesta;
END;
$$ LANGUAGE plpgsql;