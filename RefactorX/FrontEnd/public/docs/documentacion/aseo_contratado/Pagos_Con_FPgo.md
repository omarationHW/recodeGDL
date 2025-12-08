# DocumentaciÃ³n TÃ©cnica: Pagos_Con_FPgo

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración Formulario Pagos_Con_FPgo (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa la consulta de pagos realizados en una fecha específica, permitiendo visualizar el detalle de cada pago y consultar el detalle del contrato relacionado. La migración se realiza desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos).

## 2. Arquitectura
- **Backend**: Laravel Controller expone un endpoint único `/api/execute` que recibe peticiones eRequest/eResponse.
- **Frontend**: Componente Vue.js como página independiente, sin tabs, con navegación breadcrumb y modal para detalle de contrato.
- **Base de Datos**: Toda la lógica SQL se encapsula en stored procedures PostgreSQL.

## 3. API Unificada (eRequest/eResponse)
- **Endpoint**: `POST /api/execute`
- **Request**:
  ```json
  {
    "eRequest": {
      "action": "getPagosByFecha",
      "params": { "fecha": "2024-06-01" }
    }
  }
  ```
- **Response**:
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```
- **Acciones soportadas**:
  - `getPagosByFecha`: Lista pagos por fecha de pago.
  - `getContratoDetalle`: Detalle de contrato por control_contrato.
  - `getTipoAseoCatalog`: Catálogo de tipos de aseo.

## 4. Stored Procedures
- Toda la lógica de consulta se implementa en funciones PostgreSQL (ver sección stored_procedures).
- Se recomienda crear índices en las columnas usadas en WHERE para optimizar rendimiento.

## 5. Frontend (Vue.js)
- Página independiente, sin tabs.
- Permite seleccionar fecha, buscar pagos, ver resultados en tabla y abrir modal con detalle de contrato.
- Filtros y formatos para moneda, fechas y periodos.
- Navegación breadcrumb.

## 6. Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación JWT o session según la política del sistema.
- Validar y sanitizar todos los parámetros recibidos.

## 7. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- Los stored procedures pueden ser extendidos para soportar nuevos filtros o columnas.

## 8. Consideraciones de Migración
- Los nombres de tablas y campos deben mapearse fielmente desde el modelo Delphi.
- Los tipos de datos Delphi (Currency, Smallint, etc.) deben mapearse a los equivalentes PostgreSQL.
- El formato de fechas debe ser consistente (YYYY-MM-DD).

## 9. Pruebas y Validación
- Se recomienda usar los casos de uso y pruebas incluidas para validar la funcionalidad.
- El frontend debe manejar errores de red y mostrar mensajes claros al usuario.

## 10. Dependencias
- Laravel 9+
- Vue.js 3+
- PostgreSQL 12+

---


## Casos de Prueba

# Casos de Prueba: Pagos_Con_FPgo

## Caso 1: Consulta de pagos por fecha válida
- **Entrada:** fecha = '2024-06-01'
- **Acción:** POST /api/execute { eRequest: { action: 'getPagosByFecha', params: { fecha: '2024-06-01' } } }
- **Resultado esperado:** eResponse.success = true, eResponse.data contiene lista de pagos, cada pago tiene control_contrato, aso_mes_pago, descripcion, importe, etc.

## Caso 2: Consulta de pagos por fecha sin resultados
- **Entrada:** fecha = '2023-01-01'
- **Acción:** POST /api/execute { eRequest: { action: 'getPagosByFecha', params: { fecha: '2023-01-01' } } }
- **Resultado esperado:** eResponse.success = true, eResponse.data = []

## Caso 3: Consulta de detalle de contrato existente
- **Entrada:** control_contrato = 1803
- **Acción:** POST /api/execute { eRequest: { action: 'getContratoDetalle', params: { control_contrato: 1803 } } }
- **Resultado esperado:** eResponse.success = true, eResponse.data[0] contiene los campos del contrato (num_contrato, tipo_aseo, descripcion, cantidad_recolec, aso_mes_oblig, etc.)

## Caso 4: Consulta de detalle de contrato inexistente
- **Entrada:** control_contrato = 999999
- **Acción:** POST /api/execute { eRequest: { action: 'getContratoDetalle', params: { control_contrato: 999999 } } }
- **Resultado esperado:** eResponse.success = true, eResponse.data = []

## Caso 5: Error de parámetros
- **Entrada:** POST /api/execute { eRequest: { action: 'getPagosByFecha', params: { } } }
- **Resultado esperado:** eResponse.success = false, eResponse.message contiene 'Fecha requerida'


## Casos de Uso

# Casos de Uso - Pagos_Con_FPgo

**Categoría:** Form

## Caso de Uso 1: Consulta de pagos por fecha de pago

**Descripción:** El usuario desea consultar todos los pagos realizados en una fecha específica y ver el detalle de cada pago.

**Precondiciones:**
El usuario tiene acceso al sistema y existen pagos registrados en la fecha consultada.

**Pasos a seguir:**
1. El usuario accede a la página 'Consulta de Pagos por Fecha de Pago'.
2. Selecciona la fecha deseada en el campo de fecha.
3. Presiona el botón 'Buscar'.
4. El sistema muestra una tabla con todos los pagos realizados en esa fecha.
5. El usuario puede hacer clic en 'Ver' para consultar el detalle del contrato relacionado.

**Resultado esperado:**
Se muestran todos los pagos realizados en la fecha seleccionada, con opción de ver el detalle del contrato.

**Datos de prueba:**
Fecha: 2024-06-01 (debe haber pagos en esa fecha)

---

## Caso de Uso 2: Consulta de pagos sin resultados

**Descripción:** El usuario consulta una fecha en la que no existen pagos registrados.

**Precondiciones:**
El usuario tiene acceso al sistema y la fecha consultada no tiene pagos.

**Pasos a seguir:**
1. El usuario accede a la página.
2. Selecciona una fecha sin pagos (ejemplo: 2023-01-01).
3. Presiona 'Buscar'.

**Resultado esperado:**
El sistema muestra la tabla vacía o un mensaje indicando que no hay pagos para esa fecha.

**Datos de prueba:**
Fecha: 2023-01-01 (sin pagos)

---

## Caso de Uso 3: Consulta de detalle de contrato

**Descripción:** El usuario consulta el detalle de un contrato desde la lista de pagos.

**Precondiciones:**
El usuario ya realizó una búsqueda de pagos y hay resultados.

**Pasos a seguir:**
1. El usuario hace clic en 'Ver' en la fila de un pago.
2. El sistema abre un modal mostrando el detalle del contrato.

**Resultado esperado:**
Se muestra la información detallada del contrato seleccionado.

**Datos de prueba:**
control_contrato: 1803 (debe existir en la base de datos)

---



---
**Componente:** `Pagos_Con_FPgo.vue`
**MÃ³dulo:** `aseo_contratado`

