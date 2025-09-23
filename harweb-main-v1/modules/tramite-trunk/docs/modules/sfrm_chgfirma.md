# Documentación Técnica: Actualización de Firma Electrónica

## Descripción General
Este módulo permite a los usuarios actualizar su firma electrónica (clave/firma para trámites internos) de manera segura. La lógica se implementa en backend (Laravel + PostgreSQL) y frontend (Vue.js), usando un endpoint API unificado `/api/execute` bajo el patrón eRequest/eResponse.

## Arquitectura
- **Backend:** Laravel Controller (API REST), con endpoint único `/api/execute`.
- **Frontend:** Componente Vue.js de página completa, sin tabs, con validaciones y mensajes de usuario.
- **Base de Datos:** PostgreSQL, con stored procedure `upd_firma` para la lógica de actualización.

## Flujo de Proceso
1. El usuario accede a la página de cambio de firma electrónica.
2. Ingresa su firma actual, la nueva firma y la confirmación.
3. El frontend valida que la nueva firma y la confirmación coincidan.
4. Se envía una petición POST a `/api/execute` con el objeto `eRequest`:
   ```json
   {
     "eRequest": {
       "action": "chg_firma",
       "usuario": "usuario",
       "firma_actual": "...",
       "firma_nueva": "...",
       "firma_conf": "...",
       "modulos_id": 3
     }
   }
   ```
5. El backend ejecuta el stored procedure `upd_firma` con los parámetros recibidos.
6. El resultado se retorna en el objeto `eResponse`:
   ```json
   {
     "eResponse": {
       "success": true/false,
       "message": "...",
       "data": { ... }
     }
   }
   ```
7. El frontend muestra el mensaje correspondiente y limpia los campos si fue exitoso.

## Validaciones
- La firma actual debe coincidir con la registrada.
- La nueva firma debe tener al menos 6 caracteres.
- La nueva firma y la confirmación deben coincidir.
- La nueva firma no puede ser igual a la actual.
- El usuario debe existir.

## Seguridad
- Todas las operaciones se realizan autenticadas (el usuario debe estar logueado).
- La firma electrónica se almacena hasheada (recomendado, aunque el ejemplo es texto plano por compatibilidad).
- El endpoint `/api/execute` debe estar protegido por middleware de autenticación.

## API
- **Endpoint:** `POST /api/execute`
- **Entrada:** Objeto `eRequest` con acción y parámetros.
- **Salida:** Objeto `eResponse` con resultado, mensaje y datos.

## Base de Datos
- Tabla `usuarios` debe tener el campo `firma_electronica` (TEXT o VARCHAR(100)).
- El stored procedure `upd_firma` realiza toda la lógica de validación y actualización.

## Extensibilidad
- El endpoint puede manejar otras acciones agregando más casos en el controlador.
- El stored procedure puede ser extendido para auditar cambios, enviar notificaciones, etc.

## Integración
- El componente Vue.js puede ser integrado en cualquier SPA o sistema de rutas.
- El backend puede ser integrado en cualquier API Laravel existente.

## Notas
- El campo `modulos_id` se mantiene para compatibilidad futura (permite restringir cambios por módulo).
- El frontend asume que el usuario autenticado está disponible en el store o contexto global.
