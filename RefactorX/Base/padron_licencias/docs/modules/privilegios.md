# Documentación Técnica: Migración Formulario Privilegios (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Arquitectura General
- **Backend**: Laravel API con endpoint único `/api/execute`.
- **Frontend**: Vue.js SPA, cada formulario es una página independiente.
- **Base de Datos**: PostgreSQL, toda la lógica SQL encapsulada en stored procedures.
- **Comunicación**: Patrón eRequest/eResponse vía JSON.

## 2. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**:
  ```json
  {
    "eRequest": "nombre_de_la_accion",
    "params": { ... }
  }
  ```
- **Response**:
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [ ... ],
      "error": "mensaje de error si aplica"
    }
  }
  ```

## 3. Stored Procedures
- Toda la lógica de consulta y reporte se implementa como funciones en PostgreSQL.
- Los procedimientos reciben parámetros y retornan tablas (RETURNS TABLE).
- Ejemplo de llamada desde Laravel:
  ```php
  DB::select('SELECT * FROM sp_get_usuarios_privilegios(?, ?, ?, ?)', [$campo, $filtro, $offset, $limit]);
  ```

## 4. Controlador Laravel
- Un solo controlador (`ExecuteController`) maneja todas las acciones.
- Cada acción se identifica por el valor de `eRequest`.
- Se recomienda registrar el endpoint en `routes/api.php`:
  ```php
  Route::post('/execute', [ExecuteController::class, 'execute']);
  ```

## 5. Componente Vue.js
- Cada formulario Delphi se convierte en una página Vue.js independiente.
- No se usan tabs ni componentes tabulares.
- Navegación mediante rutas y breadcrumbs.
- El componente consume el endpoint `/api/execute` usando fetch/AJAX.
- Ejemplo de uso:
  ```js
  fetch('/api/execute', { method: 'POST', body: JSON.stringify({ eRequest: 'getUsuariosPrivilegios', params: { ... } }) })
  ```

## 6. Seguridad
- Se recomienda proteger el endpoint con autenticación JWT o similar.
- Validar y sanear todos los parámetros recibidos.

## 7. Paginación y Ordenamiento
- Los procedimientos soportan paginación y ordenamiento por campo.
- El frontend puede enviar `page`, `perPage`, y `campo` para controlar la consulta.

## 8. Extensibilidad
- Para agregar nuevas acciones, basta con:
  1. Crear el stored procedure correspondiente.
  2. Agregar el case en el controlador.
  3. Consumir desde el frontend.

## 9. Pruebas
- Se recomienda usar Postman para pruebas manuales del endpoint.
- Los casos de uso y prueba incluidos permiten validar la funcionalidad.

## 10. Notas
- Los reportes impresos Delphi se migran a reportes descargables (PDF/Excel) en una segunda fase.
- El frontend muestra los datos en tablas responsivas.
