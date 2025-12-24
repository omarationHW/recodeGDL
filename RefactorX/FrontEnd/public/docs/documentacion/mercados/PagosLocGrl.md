# PagosLocGrl

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: PagosLocGrl (Laravel + Vue.js + PostgreSQL)

## Descripción General
Este módulo permite consultar y exportar los pagos realizados por locales de un mercado específico en un rango de fechas, filtrando por oficina recaudadora y mercado. Incluye integración con stored procedures en PostgreSQL, un endpoint API unificado y una interfaz Vue.js.

## Arquitectura
- **Backend**: Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend**: Componente Vue.js de página completa (sin tabs)
- **Base de Datos**: PostgreSQL con stored procedures para lógica de negocio y reportes

## Flujo de Datos
1. El usuario accede a la página de "Pagos por Mercado".
2. El frontend solicita la lista de recaudadoras (`getRecaudadoras`).
3. Al seleccionar una recaudadora, se cargan los mercados asociados (`getMercadosByRecaudadora`).
4. El usuario selecciona mercado y rango de fechas, y ejecuta la búsqueda (`getPagosLocGrl`).
5. Los resultados se muestran en una tabla. Puede exportar a Excel.

## API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Body**:
  ```json
  {
    "action": "nombreAccion",
    "params": { ... }
  }
  ```
- **Acciones soportadas**:
  - `getRecaudadoras`: Lista recaudadoras
  - `getMercadosByRecaudadora`: Mercados por recaudadora
  - `getPagosLocGrl`: Reporte de pagos
  - `exportPagosLocGrlExcel`: Exportación (simulada)

## Stored Procedures
- **get_recaudadoras**: Devuelve recaudadoras
- **get_mercados_by_recaudadora**: Devuelve mercados de una recaudadora
- **get_pagos_loc_grl**: Devuelve pagos filtrados por recaudadora, mercado y fechas

## Validaciones
- Todos los parámetros requeridos son validados en el frontend y backend.
- El backend retorna mensajes de error claros en caso de parámetros faltantes o errores de ejecución.

## Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación (ej: JWT, session, etc).
- Los stored procedures no permiten SQL injection (uso de parámetros).

## Exportación a Excel
- El endpoint `exportPagosLocGrlExcel` simula la exportación y retorna una URL de descarga.
- En producción, se recomienda usar un job que genere el archivo y lo almacene en storage público.

## Estructura de Carpetas
- `app/Http/Controllers/PagosLocGrlController.php`
- `resources/js/pages/PagosLocGrlPage.vue`
- `database/migrations/` y `database/functions/` para los SP

## Extensibilidad
- Se pueden agregar más acciones al endpoint `/api/execute` siguiendo el mismo patrón.
- Los stored procedures pueden ser extendidos para incluir más filtros o columnas.

## Pruebas
- Incluye casos de uso y escenarios de prueba para asegurar la funcionalidad.

#

## Casos de Uso

# Casos de Uso - PagosLocGrl

**Categoría:** Form

## Caso de Uso 1: Consulta de pagos de un mercado en un rango de fechas

**Descripción:** El usuario desea consultar todos los pagos realizados en el Mercado 5 de la Recaudadora 2 entre el 2024-01-01 y el 2024-03-31.

**Precondiciones:**
El usuario tiene acceso al sistema y existen pagos registrados en ese rango.

**Pasos a seguir:**
1. Accede a la página de Pagos por Mercado.
2. Selecciona la recaudadora '2'.
3. Espera a que se carguen los mercados y selecciona el mercado '5'.
4. Selecciona las fechas desde '2024-01-01' hasta '2024-03-31'.
5. Presiona 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los pagos realizados en el mercado 5 de la recaudadora 2 en el rango de fechas seleccionado.

**Datos de prueba:**
{ "recaudadora_id": 2, "mercado_id": 5, "fecha_desde": "2024-01-01", "fecha_hasta": "2024-03-31" }

---

## Caso de Uso 2: Exportar pagos a Excel

**Descripción:** El usuario desea exportar a Excel los pagos consultados previamente.

**Precondiciones:**
El usuario ya realizó una consulta y hay resultados en pantalla.

**Pasos a seguir:**
1. Después de ver los resultados de la consulta, presiona el botón 'Exportar a Excel'.

**Resultado esperado:**
Se descarga un archivo Excel con los datos mostrados en la tabla.

**Datos de prueba:**
Usar los mismos parámetros de la consulta anterior.

---

## Caso de Uso 3: Validación de parámetros obligatorios

**Descripción:** El usuario intenta buscar pagos sin seleccionar recaudadora o mercado.

**Precondiciones:**
El usuario accede a la página pero no selecciona todos los filtros.

**Pasos a seguir:**
1. Deja vacío el campo recaudadora o mercado.
2. Presiona 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que los campos son obligatorios y no realiza la consulta.

**Datos de prueba:**
{ "recaudadora_id": null, "mercado_id": null, "fecha_desde": "2024-01-01", "fecha_hasta": "2024-03-31" }

---



## Casos de Prueba

## Casos de Prueba: PagosLocGrl

### 1. Consulta exitosa de pagos
- **Entrada:** recaudadora_id=2, mercado_id=5, fecha_desde=2024-01-01, fecha_hasta=2024-03-31
- **Acción:** POST /api/execute { action: 'getPagosLocGrl', params: {...} }
- **Esperado:** Respuesta success=true, data es array con pagos, sin error

### 2. Exportación a Excel
- **Entrada:** recaudadora_id=2, mercado_id=5, fecha_desde=2024-01-01, fecha_hasta=2024-03-31
- **Acción:** POST /api/execute { action: 'exportPagosLocGrlExcel', params: {...} }
- **Esperado:** Respuesta success=true, data.url contiene URL de descarga

### 3. Validación de campos obligatorios
- **Entrada:** recaudadora_id=null, mercado_id=null, fecha_desde=2024-01-01, fecha_hasta=2024-03-31
- **Acción:** POST /api/execute { action: 'getPagosLocGrl', params: {...} }
- **Esperado:** Respuesta success=false, message indica error de parámetros

### 4. Consulta sin resultados
- **Entrada:** recaudadora_id=99, mercado_id=99, fecha_desde=2024-01-01, fecha_hasta=2024-03-31
- **Acción:** POST /api/execute { action: 'getPagosLocGrl', params: {...} }
- **Esperado:** Respuesta success=true, data es array vacío

### 5. Error de base de datos
- **Simulación:** Forzar error en SP (ej: pasar string en vez de int)
- **Esperado:** Respuesta success=false, message contiene mensaje de error SQL



