# Documentación: SinLigarFrm

## Análisis Técnico

> ⚠️ Pendiente de documentar

## Casos de Uso

# Casos de Uso - SinLigarFrm

**Categoría:** Form

## Caso de Uso 1: Consulta de pagos sin ligar en el último mes

**Descripción:** El usuario desea obtener todos los pagos de transmisiones sin ligar a cuenta predial realizados en el último mes.

**Precondiciones:**
El usuario tiene acceso al sistema y existen pagos registrados en el último mes.

**Pasos a seguir:**
1. Acceder a la página 'Pagos Transmisiones Sin Ligar'.
2. Seleccionar la fecha desde (hace 30 días) y fecha hasta (hoy).
3. Hacer clic en 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los pagos sin ligar en el rango de fechas seleccionado.

**Datos de prueba:**
{ "fecha1": "2024-05-01", "fecha2": "2024-05-31" }

---

## Caso de Uso 2: Consulta sin resultados

**Descripción:** El usuario consulta un rango de fechas donde no existen pagos sin ligar.

**Precondiciones:**
No existen pagos sin ligar en el rango de fechas consultado.

**Pasos a seguir:**
1. Acceder a la página.
2. Seleccionar un rango de fechas sin registros.
3. Hacer clic en 'Buscar'.

**Resultado esperado:**
Se muestra un mensaje de advertencia indicando que no se encontró información.

**Datos de prueba:**
{ "fecha1": "2023-01-01", "fecha2": "2023-01-02" }

---

## Caso de Uso 3: Error por parámetros faltantes

**Descripción:** El usuario intenta consultar sin seleccionar una de las fechas.

**Precondiciones:**
El usuario deja vacío el campo 'fecha desde' o 'fecha hasta'.

**Pasos a seguir:**
1. Acceder a la página.
2. Dejar vacío uno de los campos de fecha.
3. Hacer clic en 'Buscar'.

**Resultado esperado:**
Se muestra un mensaje de error indicando que los parámetros son requeridos.

**Datos de prueba:**
{ "fecha1": "", "fecha2": "2024-05-31" }

---

## Casos de Prueba

# Casos de Prueba para SinLigarFrm

## Caso 1: Consulta exitosa de pagos sin ligar
- **Input:** fecha1 = '2024-05-01', fecha2 = '2024-05-31'
- **Acción:** POST /api/execute con operation 'getSinLigarPagos'
- **Resultado esperado:** eResponse.success = true, eResponse.data contiene lista de pagos, eResponse.error = null

## Caso 2: Consulta sin resultados
- **Input:** fecha1 = '2023-01-01', fecha2 = '2023-01-02'
- **Acción:** POST /api/execute con operation 'getSinLigarPagos'
- **Resultado esperado:** eResponse.success = true, eResponse.data = [], eResponse.error = null

## Caso 3: Error por parámetros faltantes
- **Input:** fecha1 = '', fecha2 = '2024-05-31'
- **Acción:** POST /api/execute con operation 'getSinLigarPagos'
- **Resultado esperado:** eResponse.success = false, eResponse.data = null, eResponse.error contiene mensaje de parámetros requeridos

## Caso 4: Error por operación no soportada
- **Input:** operation = 'unknownOperation'
- **Acción:** POST /api/execute
- **Resultado esperado:** eResponse.success = false, eResponse.error contiene 'Operación no soportada'

## Caso 5: Validación de formato de fecha
- **Input:** fecha1 = '2024-05-XX', fecha2 = '2024-05-31'
- **Acción:** POST /api/execute
- **Resultado esperado:** eResponse.success = false, eResponse.error contiene mensaje de error de formato de fecha

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

