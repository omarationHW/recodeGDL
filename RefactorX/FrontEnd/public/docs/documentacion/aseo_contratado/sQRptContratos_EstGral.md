# Documentación Técnica: sQRptContratos_EstGral

## Análisis

# Documentación Técnica: Migración Formulario sQRptContratos_EstGral

## 1. Arquitectura General
- **Backend:** Laravel (PHP) + PostgreSQL
- **Frontend:** Vue.js (SPA, página independiente)
- **API:** Endpoint único `/api/execute` usando patrón eRequest/eResponse
- **Base de datos:** Procedimientos almacenados en PostgreSQL

## 2. API Unificada
- **Endpoint:** `POST /api/execute`
- **Entrada:**
  ```json
  {
    "eRequest": {
      "procedure": "nombre_del_sp",
      "parameters": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [ ... ]
    }
  }
  ```

## 3. Stored Procedures
- Todos los cálculos y consultas se realizan en SPs.
- Cada SP corresponde a una sección del reporte (contratos, cuota normal, excedencias, contenedores, y sus variantes por estado).
- Los SPs reciben parámetros según corresponda (ej: `ctrol_a` para tipo de aseo).
- Los SPs devuelven tablas con los campos requeridos (registros, importe).

## 4. Controlador Laravel
- Recibe la petición, extrae el nombre del SP y parámetros.
- Ejecuta el SP usando DB::select y retorna el resultado en el formato eResponse.
- Maneja errores y validaciones.

## 5. Componente Vue.js
- Página independiente, no usa tabs.
- Carga los tipos de aseo al iniciar.
- Al seleccionar un tipo de aseo, consulta todos los SPs necesarios y muestra los resultados en tablas.
- Permite actualizar los datos manualmente.
- Usa Bootstrap para estilos y tablas.

## 6. Seguridad
- El endpoint debe estar protegido por autenticación (ej: Sanctum, JWT) en producción.
- Validar que sólo se puedan ejecutar SPs permitidos (agregar whitelist en producción).

## 7. Suposiciones de Tablas
- `ta_16_tipo_aseo`: catálogo de tipos de aseo.
- `contratos`: contratos por tipo de aseo (campos: ctrol_aseo, estado).
- `pagos`: pagos asociados (campos: ctrol_aseo, tipo [CN, EXE, CON], estado, importe).

## 8. Extensibilidad
- Para agregar nuevos reportes, crear un nuevo SP y llamarlo desde el frontend usando el mismo endpoint.

## 9. Pruebas
- Se recomienda usar Postman para pruebas manuales del endpoint.
- El frontend puede ser probado con datos reales o mockeados.

## 10. Despliegue
- Los SPs deben ser creados en la base de datos PostgreSQL destino.
- El controlador debe estar registrado en routes/api.php:
  ```php
  Route::post('/execute', [\App\Http\Controllers\Api\ExecuteController::class, 'execute']);
  ```
- El componente Vue debe estar registrado en el router como página independiente.


## Casos de Uso

# Casos de Uso - sQRptContratos_EstGral

**Categoría:** Form

## Caso de Uso 1: Visualización del reporte para un tipo de aseo específico

**Descripción:** El usuario accede a la página de Estadístico General de Contratos y selecciona un tipo de aseo para ver el reporte completo.

**Precondiciones:**
El usuario tiene acceso a la aplicación y existen datos en las tablas de contratos y pagos.

**Pasos a seguir:**
1. El usuario navega a la página 'Estadístico General de Contratos'.
2. El sistema carga y muestra la lista de tipos de aseo.
3. El usuario selecciona un tipo de aseo del combo.
4. El sistema consulta todos los SPs relacionados y muestra los datos en las tablas correspondientes.

**Resultado esperado:**
Se muestran correctamente los totales de contratos, cuotas normales, excedencias y contenedores, segmentados por estado.

**Datos de prueba:**
Tipo de aseo: ctrol_aseo=1 (ejemplo: 'DOMICILIARIO')

---

## Caso de Uso 2: Cambio de tipo de aseo y actualización de reporte

**Descripción:** El usuario cambia el tipo de aseo seleccionado y el reporte se actualiza automáticamente.

**Precondiciones:**
El usuario está en la página y ya visualizó un reporte.

**Pasos a seguir:**
1. El usuario selecciona otro tipo de aseo en el combo.
2. El sistema vuelve a consultar todos los SPs y actualiza los datos mostrados.

**Resultado esperado:**
Los datos del reporte cambian y corresponden al nuevo tipo de aseo seleccionado.

**Datos de prueba:**
Tipo de aseo: ctrol_aseo=2 (ejemplo: 'COMERCIAL')

---

## Caso de Uso 3: Manejo de error al ejecutar un SP inexistente

**Descripción:** El sistema maneja correctamente el error cuando se intenta ejecutar un SP que no existe.

**Precondiciones:**
El usuario o el frontend envía un nombre de SP incorrecto.

**Pasos a seguir:**
1. El frontend envía una petición con 'procedure': 'sp_inexistente'.
2. El backend intenta ejecutar el SP y falla.

**Resultado esperado:**
El sistema retorna un mensaje de error claro en eResponse indicando que el SP no existe.

**Datos de prueba:**
procedure: 'sp_inexistente', parameters: {}

---



## Casos de Prueba

## Casos de Prueba

### Caso 1: Visualización de reporte para tipo de aseo válido
- **Entrada:**
  - procedure: sp_get_cn
  - parameters: { ctrol_a: 1 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data contiene registros numéricos y suma de importes

### Caso 2: Cambio de tipo de aseo
- **Acción:**
  - Seleccionar tipo de aseo ctrol_aseo=2 en el frontend
- **Esperado:**
  - Todos los datos de las tablas cambian y corresponden al nuevo tipo

### Caso 3: Error por SP inexistente
- **Entrada:**
  - procedure: sp_inexistente
  - parameters: {}
- **Esperado:**
  - eResponse.success = false
  - eResponse.message contiene texto 'does not exist' o similar

### Caso 4: Sin datos para tipo de aseo
- **Entrada:**
  - procedure: sp_get_cn
  - parameters: { ctrol_a: 9999 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data = [ { registros: 0, importe: 0 } ]

### Caso 5: Seguridad (no autenticado)
- **Acción:**
  - Llamar /api/execute sin token (si aplica autenticación)
- **Esperado:**
  - HTTP 401 Unauthorized o mensaje de error de autenticación


