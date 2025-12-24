# ListadosLocales

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica - ListadosLocales (Migración Delphi a Laravel + Vue.js + PostgreSQL)

## Arquitectura General
- **Backend**: Laravel 10+ (PHP 8+), API RESTful, endpoint único `/api/execute` (eRequest/eResponse)
- **Frontend**: Vue.js 3 SPA, cada formulario es una página independiente
- **Base de Datos**: PostgreSQL, toda la lógica SQL encapsulada en stored procedures
- **Comunicación**: El frontend consume el endpoint `/api/execute` enviando `{ action, params }` y recibe `{ ...data }`

## Flujo de Trabajo
1. El usuario accede a la página de ListadosLocales.
2. Selecciona el tipo de listado (Padrón, Movimientos, Ingreso por Zonas).
3. El frontend solicita los catálogos (recaudadoras, mercados) usando `/api/execute`.
4. Al buscar, el frontend envía la acción y parámetros al backend.
5. El backend ejecuta el stored procedure correspondiente y retorna los datos.
6. El usuario puede exportar a Excel (implementación pendiente).

## Seguridad
- El endpoint `/api/execute` requiere autenticación (token JWT o sesión Laravel).
- Cada acción valida los parámetros y el usuario.
- Los stored procedures sólo exponen la información necesaria.

## Estructura de Carpetas
- `app/Http/Controllers/ListadosLocalesController.php` (controlador principal)
- `resources/js/pages/ListadosLocalesPage.vue` (componente Vue)
- `database/migrations/` y `database/procedures/` (stored procedures)

## API eRequest/eResponse
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**: `{ action: string, params: object }`
- **Response**: `{ ...data }` según la acción

## Acciones soportadas
- `getRecaudadoras`: Catálogo de recaudadoras
- `getMercadosByRecaudadora`: Catálogo de mercados por recaudadora
- `getPadronLocales`: Listado de locales para padrón
- `getMovimientosLocales`: Listado de movimientos
- `getPagosLocales`: Listado de pagos
- `getIngresoZonificado`: Ingreso por zonas
- `exportPadronExcel`: Exportación a Excel (pendiente)

## Stored Procedures
- Todos los reportes y listados usan stored procedures PostgreSQL.
- Los SPs devuelven tablas (RETURNS TABLE) para fácil consumo desde Laravel.

## Validaciones
- El backend valida que los parámetros requeridos estén presentes.
- El frontend valida que los filtros estén completos antes de enviar la petición.

## Exportación a Excel
- La exportación se puede implementar usando Laravel Excel o similar.
- El endpoint `exportPadronExcel` es un placeholder.

## Consideraciones
- No se usan tabs ni componentes tabulares en el frontend.
- Cada formulario es una página independiente y funcional.
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente.

# Casos de Uso


## Casos de Uso

# Casos de Uso - ListadosLocales

**Categoría:** Form

## Caso de Uso 1: Consulta de Padrón de Locales

**Descripción:** El usuario desea obtener el padrón de locales de un mercado específico.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. El usuario accede a la página de Listados de Mercados.
2. Selecciona 'Padrón de Locales'.
3. Selecciona una recaudadora y un mercado.
4. Presiona 'Buscar'.
5. El sistema muestra el listado de locales.

**Resultado esperado:**
Se muestra una tabla con los locales del mercado seleccionado, incluyendo datos de renta y estado.

**Datos de prueba:**
Recaudadora: 1 (Centro), Mercado: 5 (San Juan de Dios)

---

## Caso de Uso 2: Consulta de Movimientos de Locales

**Descripción:** El usuario requiere ver los movimientos de locales en un rango de fechas.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. El usuario accede a la página de Listados de Mercados.
2. Selecciona 'Movimientos Locales'.
3. Selecciona la recaudadora y el rango de fechas.
4. Presiona 'Buscar'.
5. El sistema muestra los movimientos realizados en ese periodo.

**Resultado esperado:**
Se muestra una tabla con los movimientos, tipo, fecha y datos del local.

**Datos de prueba:**
Recaudadora: 2 (Olímpica), Fecha Desde: 2024-01-01, Fecha Hasta: 2024-01-31

---

## Caso de Uso 3: Consulta de Ingreso por Zonas

**Descripción:** El usuario desea ver el ingreso global por zonas en un periodo.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. El usuario accede a la página de Listados de Mercados.
2. Selecciona 'Ingreso por Zonas'.
3. Selecciona el rango de fechas.
4. Presiona 'Buscar'.
5. El sistema muestra el ingreso por zona.

**Resultado esperado:**
Se muestra una tabla con las zonas y el importe pagado en el periodo.

**Datos de prueba:**
Fecha Desde: 2024-01-01, Fecha Hasta: 2024-01-31

---



## Casos de Prueba

# Casos de Prueba - ListadosLocales

## Prueba 1: Consulta de Padrón de Locales
- **Entrada**: recaudadora_id=1, mercado_id=5
- **Acción**: getPadronLocales
- **Esperado**: Respuesta con array de locales, cada uno con campos: id_local, oficina, num_mercado, categoria, seccion, local, letra_local, bloque, nombre, superficie, renta, vigencia

## Prueba 2: Consulta de Movimientos de Locales
- **Entrada**: recaudadora_id=2, fecha_desde='2024-01-01', fecha_hasta='2024-01-31'
- **Acción**: getMovimientosLocales
- **Esperado**: Respuesta con array de movimientos, cada uno con campos: id_movimiento, fecha, oficina, num_mercado, categoria, seccion, local, letra_local, bloque, tipodescripcion, nombre

## Prueba 3: Consulta de Ingreso por Zonas
- **Entrada**: fecha_desde='2024-01-01', fecha_hasta='2024-01-31'
- **Acción**: getIngresoZonificado
- **Esperado**: Respuesta con array de ingresos, cada uno con campos: id_zona, zona, pagado

## Prueba 4: Exportación a Excel (no implementada)
- **Entrada**: recaudadora_id=1, mercado_id=5
- **Acción**: exportPadronExcel
- **Esperado**: Mensaje de éxito o advertencia de implementación pendiente

## Prueba 5: Validación de parámetros faltantes
- **Entrada**: acción sin parámetros requeridos
- **Esperado**: Respuesta HTTP 400 con mensaje de error



