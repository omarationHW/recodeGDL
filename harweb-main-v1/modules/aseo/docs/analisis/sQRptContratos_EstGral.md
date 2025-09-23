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
