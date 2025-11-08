# Documentación Técnica: Migración de Formulario de Cambio de Firma Electrónica

## 1. Descripción General
Este módulo permite a los usuarios cambiar su firma electrónica para módulos específicos (por ejemplo, Licencias o Ubicación). La migración incluye:
- Un endpoint API unificado en Laravel (`/api/execute`)
- Un componente Vue.js como página independiente
- Un stored procedure en PostgreSQL para la lógica de negocio
- Uso del patrón eRequest/eResponse

## 2. Arquitectura
- **Backend:** Laravel 10+, PostgreSQL
- **Frontend:** Vue.js 3 (Composition API o Options API)
- **API:** Endpoint único `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`
- **Seguridad:** El usuario debe estar autenticado (middleware Laravel Auth)

## 3. Flujo de Datos
1. El usuario accede a la página de cambio de firma electrónica.
2. Ingresa la firma actual, la nueva y la confirmación.
3. El formulario envía un POST a `/api/execute` con el siguiente payload:
   ```json
   {
     "eRequest": {
       "action": "chg_firma",
       "usuario": "usuario",
       "firma_actual": "...",
       "firma_nueva": "...",
       "firma_conf": "...",
       "modulos_id": 1
     }
   }
   ```
4. El controlador Laravel valida y llama al stored procedure `upd_firma`.
5. El stored procedure valida la firma actual, la nueva y la confirmación, y actualiza la base de datos.
6. El resultado se devuelve en `eResponse` con `success` y `message`.

## 4. API Detalle
- **Endpoint:** `POST /api/execute`
- **Entrada:**
  - `eRequest.action`: "chg_firma"
  - `eRequest.usuario`: string
  - `eRequest.firma_actual`: string
  - `eRequest.firma_nueva`: string
  - `eRequest.firma_conf`: string
  - `eRequest.modulos_id`: integer
- **Salida:**
  - `eResponse.success`: boolean
  - `eResponse.message`: string

## 5. Validaciones
- El usuario debe existir
- La firma actual debe coincidir
- La nueva firma debe tener al menos 6 caracteres
- La confirmación debe coincidir
- La nueva firma no puede ser igual a la actual

## 6. Seguridad
- El endpoint debe estar protegido por autenticación JWT o sesión
- El usuario sólo puede cambiar su propia firma

## 7. Consideraciones de UI
- El formulario debe ser una página independiente
- No usar tabs ni componentes tabulares
- Mostrar mensajes claros de éxito o error
- Limpiar los campos tras éxito

## 8. Base de Datos
- Tabla `usuarios` (id, usuario, ...)
- Tabla `usuarios_firma` (usuario_id, modulos_id, firma, fecha_mod)

## 9. Extensibilidad
- El endpoint `/api/execute` puede recibir otras acciones en el futuro
- El stored procedure puede extenderse para más validaciones

## 10. Ejemplo de Respuesta
```json
{
  "eResponse": {
    "success": true,
    "message": "Firma electrónica actualizada correctamente"
  }
}
```
