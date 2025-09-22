# Documentación Técnica: Migración Formulario ImpOficiofrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al formulario de impresión de oficios para trámites improcedentes. Permite al usuario seleccionar el tipo de oficio a imprimir y registrar la decisión en la base de datos. La migración se realiza a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA), y PostgreSQL (base de datos), siguiendo el patrón eRequest/eResponse con endpoint único.

## 2. Arquitectura
- **Backend:** Laravel 10+, controlador API único (`ImpOficioController`), endpoint `/api/execute`.
- **Frontend:** Vue.js 3, componente de página independiente (`ImpOficioPage.vue`).
- **Base de datos:** PostgreSQL, lógica de negocio en stored procedures.
- **Comunicación:** JSON, patrón eRequest/eResponse.

## 3. API Unificada
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "registerOficioDecision",
    "params": {
      "tramite_id": 123,
      "oficio_type": 1,
      "usuario_id": 45,
      "observaciones": "Texto opcional"
    }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": [{"result": "Oficio registrado: Uno"}],
    "message": "Decisión registrada correctamente."
  }
  ```

## 4. Stored Procedures
- Toda la lógica de registro y consulta se realiza mediante stored procedures (`sp_imp_oficio_register`, `sp_get_tramite_info`).
- La tabla `imp_oficio_bitacora` almacena el historial de decisiones de impresión de oficios.

## 5. Frontend (Vue.js)
- El componente es una página completa, sin tabs, con navegación breadcrumb.
- Permite seleccionar el tipo de oficio, capturar observaciones y enviar la decisión.
- Usa fetch API para comunicarse con `/api/execute`.

## 6. Seguridad
- El backend valida los parámetros y el tipo de oficio.
- El usuario debe estar autenticado (se espera que el `usuario_id` venga del store o JWT).

## 7. Extensibilidad
- Se pueden agregar más tipos de oficios en el futuro modificando el SP y el frontend.
- El endpoint es genérico y puede ser extendido para otros formularios.

## 8. Tabla de Bitácora (Ejemplo)
```sql
CREATE TABLE imp_oficio_bitacora (
    id SERIAL PRIMARY KEY,
    tramite_id INTEGER NOT NULL,
    oficio_type INTEGER NOT NULL,
    oficio_label TEXT NOT NULL,
    usuario_id INTEGER NOT NULL,
    observaciones TEXT,
    fecha TIMESTAMP DEFAULT NOW()
);
```

## 9. Flujo de Trabajo
1. El usuario accede a la página de trámite improcedente.
2. Selecciona el tipo de oficio y opcionalmente escribe observaciones.
3. Al hacer clic en "Aceptar", se envía la petición al backend.
4. El backend registra la decisión y responde con éxito.
5. El frontend muestra el mensaje y puede redirigir o mostrar opciones de impresión.

## 10. Consideraciones
- El componente Vue es autónomo y puede ser usado en cualquier SPA.
- El backend puede ser probado con Postman o curl.
- El SP puede ser extendido para lógica de impresión real (PDF, etc).
