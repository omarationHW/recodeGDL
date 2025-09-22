# Documentación Técnica: Migración Formulario consreq400 (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario consreq400 de Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). El formulario permite consultar requerimientos realizados en el AS-400 filtrando por recaudadora, UR y cuenta.

## 2. Arquitectura
- **Frontend**: Componente Vue.js independiente, página completa, sin tabs.
- **Backend**: Laravel Controller con endpoint unificado `/api/execute` bajo el patrón eRequest/eResponse.
- **Base de Datos**: PostgreSQL, lógica encapsulada en stored procedure `sp_consreq400_search`.

## 3. Flujo de Datos
1. El usuario ingresa los parámetros (Recaudadora, UR, Cuenta) y presiona Buscar.
2. El componente Vue.js formatea los parámetros según la lógica original Delphi (relleno de ceros a la izquierda).
3. Se envía una petición POST a `/api/execute` con el objeto `eRequest`:
   ```json
   {
     "eRequest": {
       "operation": "consreq400_search",
       "params": {
         "ofnar": "00XXXX",
         "tpr": "X",
         "ctarfc": "XXXXXX"
       }
     }
   }
   ```
4. El controlador Laravel recibe la petición, identifica la operación y llama al stored procedure correspondiente.
5. El resultado se retorna en el objeto `eResponse`.
6. Vue.js muestra los resultados en una tabla o un mensaje si no hay datos.

## 4. Detalles Técnicos
### 4.1. Formateo de Parámetros
- **Recaudadora**: Se antepone '00' al valor numérico.
- **Cuenta**: Se rellena a la izquierda con ceros hasta 6 dígitos.
- **UR**: Se pasa como string.

### 4.2. Stored Procedure
- `sp_consreq400_search` encapsula la consulta SQL y retorna todos los campos de la tabla `req_400` filtrando por los parámetros.

### 4.3. API Unificada
- Todas las operaciones se canalizan por `/api/execute`.
- El campo `operation` en `eRequest` determina la acción.
- El resultado siempre se retorna en `eResponse` con los campos: `success`, `data`, `message`.

### 4.4. Seguridad
- Se recomienda proteger el endpoint con autenticación (ej. Sanctum, JWT) en producción.

## 5. Estructura de Archivos
- **Laravel**: `app/Http/Controllers/Api/ExecuteController.php`
- **Vue.js**: `src/pages/ConsReq400Page.vue` (o similar)
- **PostgreSQL**: Stored procedure en el esquema de la base de datos destino.

## 6. Consideraciones
- El frontend es completamente independiente y puede ser enlazado desde cualquier menú o ruta.
- El backend puede ser extendido para más operaciones siguiendo el mismo patrón.
- El stored procedure puede ser optimizado para paginación si la tabla crece mucho.
