# DocumentaciÃ³n TÃ©cnica: AdeudosEst

## AnÃ¡lisis TÃ©cnico

# Estadístico de Pagos (AdeudosEst)

## Descripción General
Este módulo permite consultar y visualizar un reporte estadístico de pagos realizados por periodo (año-mes), discriminando entre Cuota Normal, Excedente y Contenedores, en el sistema de gestión de adeudos. El usuario puede seleccionar un rango de periodos (año y mes inicial/final) y obtener el total de pagos realizados por cada tipo en cada periodo.

## Arquitectura
- **Backend (Laravel):**
  - Un único endpoint `/api/execute` que recibe peticiones eRequest/eResponse.
  - El controlador `AdeudosEstController` procesa la acción `get_estadistico_pagos` y llama al stored procedure de PostgreSQL.
- **Frontend (Vue.js):**
  - Página independiente `EstadisticoPagos.vue` que permite seleccionar el rango de periodos y muestra el resultado en una tabla.
- **Base de Datos (PostgreSQL):**
  - Stored procedure `sp_estadistico_pagos` que realiza la consulta agregada por periodo.

## Flujo de Datos
1. El usuario ingresa el periodo inicial y final (año y mes).
2. El frontend envía una petición POST a `/api/execute` con la acción `get_estadistico_pagos` y los parámetros.
3. El backend valida los parámetros y ejecuta el stored procedure `sp_estadistico_pagos`.
4. El resultado se retorna al frontend, que lo muestra en una tabla.

## Validaciones
- Los años deben ser numéricos y de 4 dígitos.
- El periodo final no puede ser anterior al inicial.
- Los meses deben estar entre 1 y 12.

## Seguridad
- El endpoint requiere autenticación (middleware Laravel estándar).
- Los parámetros son validados en el backend.

## API
- **POST /api/execute**
  - **action:** `get_estadistico_pagos`
  - **params:** `{ aso_in, mes_in, aso_fin, mes_fin }`
  - **Respuesta:**
    - `success: true|false`
    - `data: [ { periodo, cuota_normal, excedente, contenedores } ]`
    - `message: string`

## SQL
- La función `sp_estadistico_pagos` utiliza la tabla `ta_16_recargos` para obtener los periodos y suma los importes de pagos por tipo de operación y periodo.

## Extensibilidad
- El endpoint y el stored procedure pueden ser extendidos para incluir otros tipos de operaciones o filtros adicionales.

## Pruebas
- Incluye casos de uso y pruebas para rangos válidos, sin resultados y validación de errores.


## Casos de Prueba

## Casos de Prueba para Estadístico de Pagos

### Caso 1: Consulta año completo
- **Entrada:** aso_in=2023, mes_in=1, aso_fin=2023, mes_fin=12
- **Esperado:** 12 filas, cada una con totales de cuota normal, excedente y contenedores. Suma de totales igual a la suma de pagos en la base de datos para ese año.

### Caso 2: Consulta un solo mes
- **Entrada:** aso_in=2024, mes_in=3, aso_fin=2024, mes_fin=3
- **Esperado:** 1 fila, totales correctos para marzo 2024.

### Caso 3: Periodo inválido
- **Entrada:** aso_in=2024, mes_in=5, aso_fin=2023, mes_fin=12
- **Esperado:** Error de validación, no se ejecuta consulta, mensaje de error visible.

### Caso 4: Sin resultados
- **Entrada:** aso_in=2050, mes_in=1, aso_fin=2050, mes_fin=12
- **Esperado:** Tabla vacía o mensaje 'No hay datos para el periodo seleccionado'.

### Caso 5: Validación de campos obligatorios
- **Entrada:** aso_in vacío, mes_in vacío
- **Esperado:** Error de validación, mensaje 'El campo año/mes es obligatorio'.


## Casos de Uso

# Casos de Uso - AdeudosEst

**Categoría:** Form

## Caso de Uso 1: Consulta de estadístico de pagos para un año completo

**Descripción:** El usuario desea obtener el reporte de pagos realizados (cuota normal, excedente, contenedores) para todos los meses del año 2023.

**Precondiciones:**
El usuario tiene acceso al sistema y existen datos de pagos en 2023.

**Pasos a seguir:**
1. Ingresar año inicial: 2023, mes inicial: 1
2. Ingresar año final: 2023, mes final: 12
3. Hacer clic en 'Ejecutar'

**Resultado esperado:**
Se muestra una tabla con 12 filas (una por mes), mostrando los totales de cada tipo de pago por periodo.

**Datos de prueba:**
{ "aso_in": 2023, "mes_in": 1, "aso_fin": 2023, "mes_fin": 12 }

---

## Caso de Uso 2: Consulta de estadístico de pagos para un solo mes

**Descripción:** El usuario desea ver los pagos realizados únicamente en marzo de 2024.

**Precondiciones:**
El usuario tiene acceso y existen pagos en marzo 2024.

**Pasos a seguir:**
1. Ingresar año inicial: 2024, mes inicial: 3
2. Ingresar año final: 2024, mes final: 3
3. Hacer clic en 'Ejecutar'

**Resultado esperado:**
Se muestra una sola fila con los totales de cada tipo de pago para marzo 2024.

**Datos de prueba:**
{ "aso_in": 2024, "mes_in": 3, "aso_fin": 2024, "mes_fin": 3 }

---

## Caso de Uso 3: Validación de error por periodo inválido

**Descripción:** El usuario intenta consultar un periodo donde el año final es menor que el inicial.

**Precondiciones:**
El usuario tiene acceso.

**Pasos a seguir:**
1. Ingresar año inicial: 2024, mes inicial: 5
2. Ingresar año final: 2023, mes final: 12
3. Hacer clic en 'Ejecutar'

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el periodo es inválido.

**Datos de prueba:**
{ "aso_in": 2024, "mes_in": 5, "aso_fin": 2023, "mes_fin": 12 }

---



---
**Componente:** `AdeudosEst.vue`
**MÃ³dulo:** `aseo_contratado`

