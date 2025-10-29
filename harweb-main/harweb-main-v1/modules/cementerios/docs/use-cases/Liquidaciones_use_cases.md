# Casos de Uso - Liquidaciones

**Categoría:** Form

## Caso de Uso 1: Cálculo de Liquidación para Fosa Existente

**Descripción:** El usuario desea calcular la liquidación de mantenimiento y recargos para una fosa existente en el cementerio 'G', para los años 2018 a 2023, con 3.125 metros.

**Precondiciones:**
El usuario tiene acceso al sistema y existen cuotas y recargos configurados para los años y cementerio seleccionados.

**Pasos a seguir:**
1. El usuario ingresa a la página de Liquidaciones.
2. Selecciona cementerio 'G'.
3. Ingresa año desde 2018 y año hasta 2023.
4. Ingresa metros: 3.125.
5. Selecciona tipo: Fosa.
6. Marca 'Nuevo' como falso.
7. Selecciona mes actual.
8. Presiona 'Calcular'.

**Resultado esperado:**
Se muestra una tabla con los años 2018 a 2023, el mantenimiento y recargos calculados por año, y los totales.

**Datos de prueba:**
{ "cementerio": "G", "anio_desde": 2018, "anio_hasta": 2023, "metros": 3.125, "tipo": "F", "nuevo": false, "mes": 6 }

---

## Caso de Uso 2: Liquidación para Nueva Urna

**Descripción:** El usuario calcula la liquidación para una urna nueva en cementerio 'A', solo para el año actual.

**Precondiciones:**
El usuario tiene acceso y existen cuotas para urnas en el año actual.

**Pasos a seguir:**
1. Ingresa a la página de Liquidaciones.
2. Selecciona cementerio 'A'.
3. Año desde y hasta: 2024.
4. Metros: 1.0.
5. Tipo: Urna.
6. Marca 'Nuevo' como verdadero.
7. Mes: 6.
8. Presiona 'Calcular'.

**Resultado esperado:**
Se muestra solo el año 2024, mantenimiento calculado y recargos en cero.

**Datos de prueba:**
{ "cementerio": "A", "anio_desde": 2024, "anio_hasta": 2024, "metros": 1.0, "tipo": "U", "nuevo": true, "mes": 6 }

---

## Caso de Uso 3: Error por Metros Vacíos

**Descripción:** El usuario intenta calcular la liquidación sin ingresar los metros.

**Precondiciones:**
El usuario tiene acceso.

**Pasos a seguir:**
1. Ingresa a la página de Liquidaciones.
2. Selecciona cementerio 'G'.
3. Año desde: 2020, año hasta: 2022.
4. Deja metros vacío o en cero.
5. Presiona 'Calcular'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que los metros deben tener información.

**Datos de prueba:**
{ "cementerio": "G", "anio_desde": 2020, "anio_hasta": 2022, "metros": 0, "tipo": "F", "nuevo": false, "mes": 6 }

---

