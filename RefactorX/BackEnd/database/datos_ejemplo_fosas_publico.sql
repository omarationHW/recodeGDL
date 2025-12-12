-- Datos de ejemplo para probar el formulario DrecgoFosa
-- Base de datos: multas_reglamentos
-- Esquema: publico (sin 'c' al final)

-- Limpiar datos de ejemplo anteriores (opcional)
-- DELETE FROM publico.fosas WHERE id_control IN (2, 7, 12);

-- Ejemplo 1: Fosa en Panteón de Mezquitán
INSERT INTO publico.fosas (
    id_control,
    cementerio,
    clase,
    seccion,
    linea,
    fosa,
    nombre_titular,
    anio_minimo,
    anio_maximo
) VALUES (
    2,
    'PANTEÓN DE MEZQUITÁN',
    'PERPETUA',
    'A',
    '3',
    '45',
    'MARÍA GUADALUPE PÉREZ GARCÍA',
    2010,
    2030
);

-- Ejemplo 2: Fosa en Panteón Municipal de San Pedro Tlaquepaque
INSERT INTO publico.fosas (
    id_control,
    cementerio,
    clase,
    seccion,
    linea,
    fosa,
    nombre_titular,
    anio_minimo,
    anio_maximo
) VALUES (
    7,
    'PANTEÓN MUNICIPAL SAN PEDRO TLAQUEPAQUE',
    'TEMPORAL',
    'B',
    '5',
    '128',
    'JOSÉ LUIS HERNÁNDEZ RODRÍGUEZ',
    2015,
    2025
);

-- Ejemplo 3: Fosa en Panteón de Santa Paula
INSERT INTO publico.fosas (
    id_control,
    cementerio,
    clase,
    seccion,
    linea,
    fosa,
    nombre_titular,
    anio_minimo,
    anio_maximo
) VALUES (
    12,
    'PANTEÓN DE SANTA PAULA',
    'PERPETUA',
    'C',
    '2',
    '89',
    'ROBERTO CARLOS MARTÍNEZ LÓPEZ',
    2008,
    2050
);

-- Verificar que se insertaron correctamente
SELECT
    id_control,
    cementerio,
    clase,
    nombre_titular,
    anio_minimo || ' - ' || anio_maximo as periodo
FROM publico.fosas
WHERE id_control IN (2, 7, 12)
ORDER BY id_control;

-- Probar el stored procedure con los ejemplos
SELECT '=== PRUEBA 1: Folio 2 (Mezquitán) ===' as prueba;
SELECT * FROM publico.recaudadora_drecgo_fosa(2);

SELECT '=== PRUEBA 2: Folio 7 (Tlaquepaque) ===' as prueba;
SELECT * FROM publico.recaudadora_drecgo_fosa(7);

SELECT '=== PRUEBA 3: Folio 12 (Santa Paula) ===' as prueba;
SELECT * FROM publico.recaudadora_drecgo_fosa(12);

SELECT '=== PRUEBA 4: Folio 0 (Todas las fosas) ===' as prueba;
SELECT * FROM publico.recaudadora_drecgo_fosa(0);
