# PadronLocales

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: PadronLocales (Migración Delphi → Laravel + Vue.js + PostgreSQL)

## Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente (NO tabs)
- **Base de Datos:** PostgreSQL 13+, lógica SQL migrada a stored procedures
- **Comunicación:** JSON, todos los errores y respuestas siguen el patrón `{ success, data, message }`

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Payload:**
  ```json
  {
    "action": "getPadronLocales", // o 'exportPadronLocales', 'getRecaudadoras', etc
    "params": { ... } // parámetros específicos
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true,
    "data": [...],
    "message": ""
  }
  ```

## Controlador Laravel
- Un solo controlador (`PadronLocalesController`) maneja todas las acciones relacionadas con el padrón de locales.
- Métodos principales:
  - `getPadronLocales`: Llama al SP y retorna el padrón filtrado por recaudadora.
  - `exportPadronLocales`: Llama al SP y prepara datos para exportar (Excel/TXT).
  - `getRecaudadoras`: Devuelve lista de recaudadoras para el filtro.
- Todas las acciones se enrutan por el campo `action` del request.

## Componente Vue.js
- Página independiente `/padron-locales`.
- Permite seleccionar recaudadora y mostrar el padrón en tabla.
- Botones para exportar a Excel/TXT (simulado, requiere implementación backend real para descarga).
- Manejo de errores y loading.
- Filtros y navegación breadcrumb.

## Stored Procedure PostgreSQL
- `sp_get_padron_locales(p_recaudadora INTEGER)`
  - Devuelve todos los locales activos de la recaudadora, con cálculo de renta según reglas de negocio.
  - Utiliza JOINs para obtener nombre de mercado y cuota vigente.

## Seguridad
- Validación de parámetros en backend.
- Manejo de errores y mensajes claros.
- (Opcional) Autenticación JWT o session para producción.

## Extensibilidad
- El endpoint `/api/execute` puede crecer para soportar más acciones (CRUD, reportes, procesos).
- Los stored procedures pueden ser versionados y ampliados.

## Notas de Migración
- El cálculo de renta se realiza en el SP, siguiendo la lógica Delphi.
- La exportación a Excel/TXT debe implementarse en backend para descarga real.
- El frontend NO usa tabs ni componentes tabulares: cada formulario es una página.

## Estructura de Carpetas
- `app/Http/Controllers/PadronLocalesController.php`
- `resources/js/pages/PadronLocalesPage.vue`
- `database/migrations/` y `database/functions/sp_get_padron_locales.sql`

## Ejemplo de llamada API
```js
fetch('/api/execute', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    action: 'getPadronLocales',
    params: { recaudadora: 1 }
  })
})
```

## Requerimientos de Infraestructura
- PHP 8+, Laravel 10+, PostgreSQL 13+, Node.js 16+ para frontend.
- Configuración de CORS si frontend y backend están en dominios distintos.



## Casos de Uso

# Casos de Uso - PadronLocales

**Categoría:** Form

## Caso de Uso 1: Consulta de Padrón de Locales por Recaudadora

**Descripción:** El usuario desea visualizar el padrón de locales activos de una recaudadora específica.

**Precondiciones:**
El usuario tiene acceso al sistema y existen recaudadoras y locales activos en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página 'Padron de Locales'.
2. Selecciona una recaudadora del combo.
3. Presiona el botón 'Generar Padron'.
4. El sistema consulta el padrón vía API y muestra la tabla.

**Resultado esperado:**
Se muestra la lista de locales activos de la recaudadora seleccionada, con todos los campos y la renta calculada.

**Datos de prueba:**
Recaudadora: 1 (ZONA CENTRO)

---

## Caso de Uso 2: Exportación del Padrón de Locales a Excel

**Descripción:** El usuario desea exportar el padrón de locales a un archivo Excel.

**Precondiciones:**
El usuario ya visualizó el padrón de una recaudadora.

**Pasos a seguir:**
1. El usuario hace clic en 'Exportar a Excel'.
2. El sistema envía la petición al backend.
3. El backend prepara los datos para exportación (simulado).
4. El usuario recibe confirmación (o descarga el archivo si está implementado).

**Resultado esperado:**
El usuario puede descargar el archivo Excel con los datos del padrón.

**Datos de prueba:**
Recaudadora: 2 (ZONA OLIMPICA)

---

## Caso de Uso 3: Validación de Parámetro Obligatorio

**Descripción:** El usuario intenta generar el padrón sin seleccionar recaudadora.

**Precondiciones:**
El usuario accede a la página pero no selecciona recaudadora.

**Pasos a seguir:**
1. El usuario deja el combo de recaudadora vacío.
2. Presiona 'Generar Padron'.
3. El sistema muestra un mensaje de error.

**Resultado esperado:**
El sistema muestra el mensaje 'Seleccione una recaudadora' y no realiza la consulta.

**Datos de prueba:**
Recaudadora: (vacío)

---



## Casos de Prueba

# Casos de Prueba: PadronLocales

## Caso 1: Consulta exitosa de padrón
- **Entrada:** recaudadora = 1
- **Acción:** POST /api/execute { action: 'getPadronLocales', params: { recaudadora: 1 } }
- **Esperado:** success=true, data es array con locales, cada uno con campo 'renta' calculado

## Caso 2: Exportación a Excel
- **Entrada:** recaudadora = 2, format = 'excel'
- **Acción:** POST /api/execute { action: 'exportPadronLocales', params: { recaudadora: 2, format: 'excel' } }
- **Esperado:** success=true, data.format='excel', data.data es array de locales

## Caso 3: Error por parámetro faltante
- **Entrada:** recaudadora = null
- **Acción:** POST /api/execute { action: 'getPadronLocales', params: { } }
- **Esperado:** success=false, message='Debe especificar la recaudadora'

## Caso 4: Validación de recaudadoras
- **Acción:** POST /api/execute { action: 'getRecaudadoras' }
- **Esperado:** success=true, data es array de recaudadoras

## Caso 5: Exportación a TXT
- **Entrada:** recaudadora = 1, format = 'txt'
- **Acción:** POST /api/execute { action: 'exportPadronLocales', params: { recaudadora: 1, format: 'txt' } }
- **Esperado:** success=true, data.format='txt', data.data es array de locales



