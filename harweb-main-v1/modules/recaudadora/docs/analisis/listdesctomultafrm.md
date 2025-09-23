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
