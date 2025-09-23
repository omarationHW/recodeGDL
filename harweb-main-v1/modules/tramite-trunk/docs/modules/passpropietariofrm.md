# Documentación Técnica: Migración Formulario passpropietariofrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al formulario de autorización de propietario (passpropietariofrm) utilizado para validar la firma electrónica de un usuario antes de permitir operaciones sensibles en el sistema catastral. La migración implementa:
- Un endpoint API único `/api/execute` bajo el patrón eRequest/eResponse.
- Un controlador Laravel que centraliza la lógica de autenticación y validación.
- Un componente Vue.js como página independiente, sin tabs.
- Stored Procedures en PostgreSQL para la lógica de validación.

## 2. API Unificada (eRequest/eResponse)
- **Endpoint:** `POST /api/execute`
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "login|validate|clear|show|close",
      "usuario": "usuario",
      "password": "password"
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": { ... }
    }
  }
  ```

## 3. Controlador Laravel
- Centraliza todas las acciones del formulario:
  - `login`: Valida usuario y firma electrónica (llama SP `sp_passpropietario_login`).
  - `validate`: Solo valida la firma electrónica (llama SP `sp_passpropietario_validate`).
  - `clear`: Limpia el campo password (no requiere SP).
  - `show`: Devuelve el usuario actual (simula FormShow).
  - `close`: Simula cierre del formulario.
- Todas las respuestas siguen el patrón eResponse.

## 4. Componente Vue.js
- Página independiente, sin tabs.
- Campos:
  - Usuario (readonly)
  - Firma electrónica (password)
- Botones:
  - Aceptar (valida y autoriza)
  - Limpiar (limpia password)
  - Cancelar (cierra formulario)
- Mensajes de error y éxito.
- Llama a la API `/api/execute` usando Axios.

## 5. Stored Procedures PostgreSQL
- `sp_passpropietario_login`: Valida usuario y firma electrónica.
- `sp_passpropietario_validate`: Solo valida la firma electrónica.
- Ambas devuelven success y message.

## 6. Seguridad
- Las contraseñas/firma electrónica deben almacenarse con hash seguro en producción (aquí es texto plano por compatibilidad con el sistema legado).
- El endpoint debe protegerse con autenticación JWT o similar en producción.

## 7. Flujo de Uso
1. El usuario accede a la página de autorización.
2. Ingresa su firma electrónica y presiona "Aceptar".
3. El sistema valida vía API y SP en base de datos.
4. Si es correcto, se autoriza la operación; si no, muestra error.

## 8. Extensibilidad
- El endpoint y los SP pueden ampliarse para soportar más acciones o validaciones.
- El componente Vue puede integrarse en cualquier flujo de la aplicación.

## 9. Pruebas
- Se proveen casos de uso y escenarios de prueba para QA y desarrollo.

