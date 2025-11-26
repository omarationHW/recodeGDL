-- ================================================================
-- Script para insertar multas de prueba en catastro_gdl.reqmultas
-- Esto te permitirá probar el módulo BloqueoMulta.vue
-- ================================================================

-- Ver primero si ya existen datos para 2024
SELECT COUNT(*) as "Multas existentes para 2024"
FROM catastro_gdl.reqmultas
WHERE axoreq = 2024;

-- Si no hay datos, insertar algunos registros de prueba
-- IMPORTANTE: Ajusta estos valores según la estructura real de tu tabla

-- Ejemplo 1: Multa vigente para 2024
INSERT INTO catastro_gdl.reqmultas (
    folioreq, axoreq, vigencia, id_multa, fecemi,
    multas, gastos, total, recaud, obs
) VALUES (
    10001, 2024, 'V', 1001, '2024-01-15',
    5000.00, 500.00, 5500.00, 1, 'Multa de prueba 1 - Vigente'
) ON CONFLICT DO NOTHING;

-- Ejemplo 2: Otra multa vigente para 2024
INSERT INTO catastro_gdl.reqmultas (
    folioreq, axoreq, vigencia, id_multa, fecemi,
    multas, gastos, total, recaud, obs
) VALUES (
    10002, 2024, 'V', 1002, '2024-02-20',
    3000.00, 300.00, 3300.00, 1, 'Multa de prueba 2 - Vigente'
) ON CONFLICT DO NOTHING;

-- Ejemplo 3: Multa bloqueada para 2024
INSERT INTO catastro_gdl.reqmultas (
    folioreq, axoreq, vigencia, id_multa, fecemi,
    multas, gastos, total, recaud, obs
) VALUES (
    10003, 2024, 'B', 1003, '2024-03-10',
    7500.00, 750.00, 8250.00, 1, 'Multa de prueba 3 - Bloqueada por revisión'
) ON CONFLICT DO NOTHING;

-- Ejemplo 4: Multa vigente para 2022
INSERT INTO catastro_gdl.reqmultas (
    folioreq, axoreq, vigencia, id_multa, fecemi,
    multas, gastos, total, recaud, obs
) VALUES (
    20001, 2022, 'V', 2001, '2022-06-15',
    4000.00, 400.00, 4400.00, 1, 'Multa de prueba 2022 - Vigente'
) ON CONFLICT DO NOTHING;

-- Ejemplo 5: Otra multa vigente para 2022
INSERT INTO catastro_gdl.reqmultas (
    folioreq, axoreq, vigencia, id_multa, fecemi,
    multas, gastos, total, recaud, obs
) VALUES (
    20002, 2022, 'V', 2002, '2022-08-20',
    6000.00, 600.00, 6600.00, 1, 'Multa de prueba 2022 - Vigente 2'
) ON CONFLICT DO NOTHING;

-- Verificar que se insertaron correctamente
SELECT
    folioreq as "Folio",
    axoreq as "Año",
    vigencia as "Vigencia",
    multas as "Multa",
    total as "Total",
    obs as "Observaciones"
FROM catastro_gdl.reqmultas
WHERE axoreq IN (2022, 2024)
    AND folioreq >= 10001
ORDER BY axoreq DESC, folioreq;

-- Contar registros por año y vigencia
SELECT
    axoreq as "Año",
    vigencia as "Vigencia",
    COUNT(*) as "Cantidad"
FROM catastro_gdl.reqmultas
WHERE axoreq IN (2022, 2024)
GROUP BY axoreq, vigencia
ORDER BY axoreq DESC, vigencia;
