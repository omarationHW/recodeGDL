# Documentación Técnica: Migración de Formulario avisofrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario `avisofrm` de Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El formulario muestra un aviso de error, permite al usuario ver más información y registrar la aceptación del aviso.

## 2. Arquitectura
- **Frontend**: Componente Vue.js como página independiente (`AvisoFormPage.vue`).
- **Backend**: Controlador Laravel unificado (`ExecuteController`) que expone un endpoint `/api/execute` para todas las acciones vía patrón eRequest/eResponse.
- **Base de Datos**: PostgreSQL, con stored procedure para registrar la aceptación del aviso.

## 3. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**: JSON con objeto `eRequest` que incluye `action` y `params`.
- **Response**: JSON con objeto `eResponse` que incluye `success`, `data`, y `message`.

### Ejemplo de Request
```json
{
  "eRequest": {
    "action": "logAvisoAcknowledgement",
    "params": {
      "user_id": 1,
      "show_more": true,
      "memo_text": "Texto del memo si aplica"
    }
  }
}
```

### Ejemplo de Response
```json
{
  "eResponse": {
    "success": true,
    "data": null,
    "message": "Aviso acknowledgement logged."
  }
}
```

## 4. Stored Procedure
- **Nombre**: `log_aviso_acknowledgement`
- **Propósito**: Registrar en la tabla `aviso_acknowledgements` la aceptación del aviso por parte del usuario.
- **Parámetros**:
  - `p_user_id` (INTEGER): ID del usuario.
  - `p_show_more` (BOOLEAN): Si el usuario mostró información adicional.
  - `p_memo_text` (TEXT): Texto del memo mostrado (si aplica).

## 5. Frontend (Vue.js)
- Página independiente con ruta propia.
- Muestra el aviso y permite mostrar/ocultar información adicional.
- Botón "Aceptar" que registra la aceptación vía API.
- Navegación breadcrumb incluida.

## 6. Seguridad
- El endpoint debe protegerse con autenticación (por ejemplo, JWT o session), aunque para la demo se simula un `user_id`.
- Validar los parámetros recibidos en el backend.

## 7. Consideraciones
- El mensaje del aviso y el texto adicional pueden ser estáticos o parametrizables según necesidades futuras.
- El endpoint `/api/execute` puede ser extendido para otras acciones del sistema.

## 8. Tablas de Soporte
```sql
CREATE TABLE aviso_acknowledgements (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL,
  show_more BOOLEAN NOT NULL,
  memo_text TEXT,
  acknowledged_at TIMESTAMP NOT NULL
);
```
