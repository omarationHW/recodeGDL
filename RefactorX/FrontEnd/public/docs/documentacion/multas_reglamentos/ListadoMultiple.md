# Documentación: ListadoMultiple

## Análisis Técnico

# Documentación Técnica - Migración ListadoMultiple Delphi a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend**: Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend**: Vue.js 3 (Composition API), componente de página independiente.
- **Base de Datos**: PostgreSQL 13+, lógica de negocio en stored procedures.
- **Patrón API**: eRequest/eResponse, todas las acciones se resuelven por un único endpoint y un parámetro `action`.

## 2. Endpoints API
- **POST /api/execute**
  - **action**: Nombre de la acción a ejecutar (ej: `getConveniosEmpresas`)
  - **params**: Objeto con parámetros específicos de la acción
  - **Respuesta**: JSON con `success`, `data` y/o `message`

## 3. Stored Procedures
- Toda la lógica SQL se encapsula en funciones PostgreSQL (tipo `RETURNS TABLE`), por ejemplo:
  - `conveniosempresas(paxo, pfecha)`
  - `pagos_convenios_empresas(pejec, pftrab, pfpagod, pfpagoh)`
  - `get_ejecutores_empresas(ftrabajo)`
- Las vistas como `conveniosempresas_view` y `pagos_convenios_empresas_view` deben existir y contener la lógica de joins/filters.

## 4. Controlador Laravel
- Un solo método `execute(Request $request)` que despacha según el parámetro `action`.
- Cada acción llama a un stored procedure o consulta SQL.
- Validación básica de parámetros.
- Soporta exportación a Excel (puede ser implementado en backend o frontend).

## 5. Componente Vue.js
- Página independiente, sin tabs.
- Formulario para búsqueda de convenios por año y fecha.
- Tabla de resultados de convenios.
- Formulario para búsqueda de pagos por ejecutor y rango de fechas.
- Tabla de resultados de pagos.
- Botones para exportar a Excel (placeholder, requiere implementación real).
- Uso de Composition API y axios para llamadas API.

## 6. Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación (ej: Sanctum, JWT) si es necesario.
- Validar que los parámetros sean correctos y que el usuario tenga permisos.

## 7. Consideraciones de Migración
- Los stored procedures Delphi/Informix deben ser reescritos en PostgreSQL.
- Los nombres de tablas y campos pueden requerir ajuste según el modelo relacional.
- Las vistas deben ser creadas para encapsular la lógica de joins y filtros complejos.
- El frontend debe ser SPA, cada formulario es una página independiente.

## 8. Exportación a Excel
- Puede implementarse en backend (Laravel Excel) o frontend (js-xlsx, SheetJS).
- El endpoint puede devolver un archivo o un link temporal.

## 9. Pruebas y Validación
- Se deben crear casos de uso y pruebas unitarias/integración para cada escenario.

## 10. Ejemplo de eRequest/eResponse
```json
{
  "action": "getConveniosEmpresas",
  "params": { "year": 2024, "fecha": "2024-06-01" }
}
```

## 11. Extensibilidad
- Para agregar nuevas acciones, solo se requiere agregar un case en el controlador y el stored procedure correspondiente.

## Casos de Uso

# Casos de Uso - ListadoMultiple

**Categoría:** Form

## Caso de Uso 1: Consulta de Convenios de Empresas por Año

**Descripción:** El usuario consulta todos los convenios de empresas emitidos en un año específico y a partir de una fecha dada.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. El usuario accede a la página Listado Múltiple.
2. Ingresa el año (ej: 2024) y la fecha de emisión (ej: 2024-06-01).
3. Presiona el botón 'Buscar Convenios'.
4. El sistema envía un eRequest con action 'getConveniosEmpresas' y los parámetros.
5. El backend ejecuta el stored procedure y devuelve los resultados.

**Resultado esperado:**
Se muestra una tabla con los convenios de empresas emitidos en el año y fecha seleccionados.

**Datos de prueba:**
{ "year": 2024, "fecha": "2024-06-01" }

---

## Caso de Uso 2: Consulta de Pagos de Convenios por Empresa y Rango de Fechas

**Descripción:** El usuario consulta los pagos realizados por una empresa ejecutora en un rango de fechas de trabajo y pago.

**Precondiciones:**
El usuario está autenticado y existen ejecutores y pagos registrados.

**Pasos a seguir:**
1. El usuario accede a la sección de pagos de convenios.
2. Selecciona un ejecutor de la lista.
3. Ingresa la fecha de trabajo y el rango de fechas de pago.
4. Presiona el botón 'Buscar Pagos'.
5. El sistema envía un eRequest con action 'getPagosConveniosEmpresas' y los parámetros.
6. El backend ejecuta el stored procedure y devuelve los resultados.

**Resultado esperado:**
Se muestra una tabla con los pagos realizados por el ejecutor en el rango de fechas especificado.

**Datos de prueba:**
{ "ejecutor": 123, "ftrab": "2024-06-01", "fpagod": "2024-06-01", "fpagoh": "2024-06-30" }

---

## Caso de Uso 3: Exportación de Convenios a Excel

**Descripción:** El usuario exporta el listado de convenios de empresas a un archivo Excel.

**Precondiciones:**
El usuario ya realizó una búsqueda de convenios y hay resultados en pantalla.

**Pasos a seguir:**
1. El usuario presiona el botón 'Exportar a Excel' en la tabla de convenios.
2. El sistema genera el archivo Excel y lo descarga o muestra un enlace de descarga.

**Resultado esperado:**
El usuario obtiene un archivo Excel con los datos de los convenios mostrados.

**Datos de prueba:**
Resultados de la búsqueda de convenios (ver caso 1).

---

## Casos de Prueba

# Casos de Prueba ListadoMultiple

## Caso 1: Consulta de Convenios de Empresas por Año
- **Entrada**: year=2024, fecha=2024-06-01
- **Acción**: POST /api/execute { action: 'getConveniosEmpresas', params: { year: 2024, fecha: '2024-06-01' } }
- **Resultado esperado**: HTTP 200, JSON con lista de convenios (campos: cvecuenta, cuenta, folioreq, ...)

## Caso 2: Consulta de Pagos de Convenios por Empresa y Rango de Fechas
- **Entrada**: ejecutor=123, ftrab=2024-06-01, fpagod=2024-06-01, fpagoh=2024-06-30
- **Acción**: POST /api/execute { action: 'getPagosConveniosEmpresas', params: { ejecutor: 123, ftrab: '2024-06-01', fpagod: '2024-06-01', fpagoh: '2024-06-30' } }
- **Resultado esperado**: HTTP 200, JSON con lista de pagos (campos: cvecuenta, cuenta, foliorecibo, ...)

## Caso 3: Exportación de Convenios a Excel
- **Precondición**: Hay resultados en la tabla de convenios
- **Acción**: Click en 'Exportar a Excel'
- **Resultado esperado**: Descarga de archivo Excel con los datos mostrados

## Caso 4: Validación de Parámetros Faltantes
- **Entrada**: POST /api/execute { action: 'getPagosConveniosEmpresas', params: { ejecutor: null } }
- **Resultado esperado**: HTTP 400, JSON { success: false, message: 'Acción no soportada' }

## Caso 5: Seguridad - Usuario no autenticado
- **Entrada**: Sin token de autenticación
- **Resultado esperado**: HTTP 401 Unauthorized

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

