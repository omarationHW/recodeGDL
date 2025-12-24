# Documentación: listdesctomultafrm

## Análisis Técnico

# Documentación Técnica: Migración de Formulario listdesctomultafrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al formulario **Listado de Descuentos en Multa** originalmente implementado en Delphi. Permite consultar y listar los descuentos otorgados en multas municipales, filtrando por recaudadora y rango de fechas. El resultado es un reporte tabular con los datos relevantes de cada pago y multa.

La migración implementa:
- **Backend**: Laravel (API RESTful, endpoint unificado `/api/execute`)
- **Frontend**: Vue.js (componente de página independiente)
- **Base de Datos**: PostgreSQL (Stored Procedure para lógica de reporte)

## 2. Arquitectura
- **API Unificada**: Todas las operaciones se realizan mediante un único endpoint `/api/execute` usando el patrón `eRequest`/`eResponse`.
- **Stored Procedure**: Toda la lógica SQL reside en el SP `report_descuentos_multa`.
- **Frontend**: Página Vue.js independiente, sin tabs, con navegación breadcrumb y tabla de resultados.

## 3. Flujo de Datos
1. El usuario ingresa los parámetros (recaudadora, fecha inicio, fecha fin) y presiona "Imprimir".
2. El frontend envía un POST a `/api/execute` con `eRequest`:
   ```json
   {
     "eRequest": {
       "action": "getDescuentosMulta",
       "params": {
         "recaud": 3,
         "fini": "2024-06-01",
         "ffin": "2024-06-30"
       }
     }
   }
   ```
3. El backend ejecuta el SP `report_descuentos_multa` con los parámetros recibidos.
4. El resultado se retorna en `eResponse.data`.
5. El frontend muestra la tabla con los resultados y permite imprimir la página.

## 4. Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación (ej. JWT, Sanctum, etc.) según la política del sistema.
- Validar y sanear los parámetros recibidos antes de ejecutar el SP.

## 5. Detalles Técnicos
### 5.1. Stored Procedure
- El SP implementa la lógica SQL original, incluyendo los joins y el cálculo del campo `descto` (calificación - multa).
- El SP retorna todos los campos requeridos para el reporte.

### 5.2. Laravel Controller
- El controlador recibe el `eRequest`, identifica la acción y ejecuta el SP correspondiente.
- El resultado se retorna en el formato `eResponse`.

### 5.3. Vue.js Component
- Página independiente, sin tabs.
- Formulario para parámetros de consulta.
- Tabla responsive con todos los campos del reporte.
- Botón de impresión (usa `window.print()`).
- Manejo de loading y errores.

## 6. Convenciones
- Fechas en formato `YYYY-MM-DD`.
- Moneda en formato MXN.
- El campo `recaud` es numérico (entero).

## 7. Extensibilidad
- Se pueden agregar nuevas acciones al endpoint `/api/execute` siguiendo el patrón `eRequest`/`eResponse`.
- El SP puede ser extendido para incluir más filtros si es necesario.

## 8. Pruebas
- Ver sección de Casos de Uso y Casos de Prueba.

## Casos de Uso

# Casos de Uso - listdesctomultafrm

**Categoría:** Form

## Caso de Uso 1: Consulta de descuentos de multas para una recaudadora en un rango de fechas

**Descripción:** El usuario desea obtener el listado de descuentos otorgados en multas municipales para la recaudadora 3 entre el 1 y el 30 de junio de 2024.

**Precondiciones:**
El usuario tiene acceso al sistema y existen datos de pagos y descuentos para la recaudadora 3 en el rango de fechas.

**Pasos a seguir:**
1. Ingresar '3' en el campo Recaudadora.
2. Seleccionar '2024-06-01' como fecha Desde.
3. Seleccionar '2024-06-30' como fecha Hasta.
4. Presionar el botón 'Imprimir'.

**Resultado esperado:**
Se muestra una tabla con todos los descuentos otorgados en multas para la recaudadora 3 en el rango de fechas especificado, incluyendo todos los campos del reporte.

**Datos de prueba:**
recaud: 3, fini: 2024-06-01, ffin: 2024-06-30

---

## Caso de Uso 2: Consulta sin resultados (rango de fechas sin datos)

**Descripción:** El usuario consulta un rango de fechas donde no existen descuentos otorgados.

**Precondiciones:**
No existen registros de descuentos para la recaudadora 2 entre el 2023-01-01 y 2023-01-31.

**Pasos a seguir:**
1. Ingresar '2' en el campo Recaudadora.
2. Seleccionar '2023-01-01' como fecha Desde.
3. Seleccionar '2023-01-31' como fecha Hasta.
4. Presionar el botón 'Imprimir'.

**Resultado esperado:**
La tabla de resultados aparece vacía y se muestra 'Total de pagos: 0'.

**Datos de prueba:**
recaud: 2, fini: 2023-01-01, ffin: 2023-01-31

---

## Caso de Uso 3: Error por parámetros inválidos (fecha fin menor a fecha inicio)

**Descripción:** El usuario ingresa una fecha final anterior a la fecha inicial.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. Ingresar '1' en el campo Recaudadora.
2. Seleccionar '2024-07-01' como fecha Desde.
3. Seleccionar '2024-06-01' como fecha Hasta.
4. Presionar el botón 'Imprimir'.

**Resultado esperado:**
Se muestra un mensaje de error indicando que los parámetros de fecha son inválidos.

**Datos de prueba:**
recaud: 1, fini: 2024-07-01, ffin: 2024-06-01

---

## Casos de Prueba

## Casos de Prueba para Listado de Descuentos en Multa

### Caso 1: Consulta exitosa con resultados
- **Entrada:** recaud=3, fini=2024-06-01, ffin=2024-06-30
- **Acción:** Enviar eRequest con estos parámetros
- **Esperado:** Se retorna un array con al menos un registro, todos los campos presentes, y el total de pagos corresponde al número de filas.

### Caso 2: Consulta sin resultados
- **Entrada:** recaud=2, fini=2023-01-01, ffin=2023-01-31
- **Acción:** Enviar eRequest con estos parámetros
- **Esperado:** Se retorna un array vacío, la tabla muestra 'Total de pagos: 0'.

### Caso 3: Parámetros inválidos (fecha fin < fecha inicio)
- **Entrada:** recaud=1, fini=2024-07-01, ffin=2024-06-01
- **Acción:** Enviar eRequest con estos parámetros
- **Esperado:** Se retorna un mensaje de error en eResponse indicando parámetros inválidos.

### Caso 4: Falta parámetro obligatorio
- **Entrada:** recaud=3, fini=2024-06-01 (sin ffin)
- **Acción:** Enviar eRequest sin el parámetro ffin
- **Esperado:** Se retorna un mensaje de error por parámetro faltante.

### Caso 5: SQL Injection attempt
- **Entrada:** recaud="3; DROP TABLE pagos; --", fini=2024-06-01, ffin=2024-06-30
- **Acción:** Enviar eRequest con intento de inyección
- **Esperado:** El backend rechaza la petición y no ejecuta código malicioso.

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

