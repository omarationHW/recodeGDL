# Documentación Técnica: Migración de Formulario 'hastafrm' (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario 'hastafrm' de Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El formulario permite al usuario ingresar un bimestre (1-6) y un año (>=1970 y <= año actual) para realizar una operación de pago hasta ese periodo.

## 2. Arquitectura
- **Frontend:** Vue.js SPA, cada formulario es una página independiente.
- **Backend:** Laravel API, endpoint unificado `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos:** PostgreSQL, lógica de validación crítica en stored procedure.

## 3. Flujo de Datos
1. El usuario accede a la página 'Pagar hasta'.
2. Ingresa bimestre y año.
3. Al hacer clic en 'Aceptar', el frontend valida los datos y envía un eRequest a `/api/execute` con acción `validate_hasta_form`.
4. El backend valida los datos y llama al stored procedure `sp_validate_hasta_form`.
5. El resultado se retorna en eResponse, mostrando mensaje de éxito o error.

## 4. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "action": "validate_hasta_form",
      "params": {
        "bimestre": 2,
        "anio": 2024
      }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": { "bimestre": 2, "anio": 2024 },
      "message": "Validación exitosa."
    }
  }
  ```

## 5. Validaciones
- **Bimestre:** Obligatorio, numérico, entre 1 y 6.
- **Año:** Obligatorio, numérico, >=1970 y <= año actual.
- **Cancelación:** Si el usuario cancela, se envían valores '9' y '9999' (como en Delphi), pero no se procesa la validación.

## 6. Stored Procedure
Toda la lógica de validación crítica reside en `sp_validate_hasta_form` para garantizar reglas de negocio centralizadas y auditables.

## 7. Seguridad
- Validación de datos en frontend y backend.
- El endpoint solo acepta acciones predefinidas.
- No se expone lógica sensible en el frontend.

## 8. Extensibilidad
- El endpoint `/api/execute` permite agregar nuevas acciones y formularios reutilizando el mismo patrón.
- Los stored procedures pueden ampliarse para lógica más compleja.

## 9. Pruebas
- Casos de uso y pruebas detallados en secciones siguientes.
