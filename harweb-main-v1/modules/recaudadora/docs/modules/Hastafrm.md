# Documentación Técnica: Migración Formulario 'Hastafrm' Delphi a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario 'Hastafrm' de Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El formulario permite al usuario ingresar un bimestre (1-6) y un año (>=1970 y <= año actual) para operaciones de pago.

## 2. Arquitectura
- **Frontend:** Vue.js SPA, cada formulario es una página independiente.
- **Backend:** Laravel API, endpoint unificado `/api/execute` bajo patrón eRequest/eResponse.
- **Base de Datos:** PostgreSQL, lógica de validación encapsulada en stored procedure.

## 3. Flujo de Datos
1. El usuario ingresa bimestre y año en la página Vue.
2. Al enviar, se realiza validación local y luego se envía un eRequest a `/api/execute`.
3. Laravel recibe el eRequest, valida los datos y llama al stored procedure `sp_validate_hasta_form`.
4. El resultado se retorna en eResponse, mostrando mensajes de éxito o error en la UI.

## 4. Detalles de Implementación
### 4.1. Endpoint Unificado
- **Ruta:** POST `/api/execute`
- **Entrada:**
  ```json
  {
    "eRequest": {
      "operation": "validate_hasta_form",
      "params": {
        "bimestre": 2,
        "anio": 2024
      }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [
        {
          "is_valid": true,
          "bimestre": 2,
          "anio": 2024,
          "message": "Datos validados correctamente."
        }
      ],
      "errors": [],
      "message": "Formulario validado correctamente."
    }
  }
  ```

### 4.2. Validaciones
- **Bimestre:** Entero, 1 a 6.
- **Año:** Entero, >=1970 y <= año actual.
- **En caso de error:** Se retorna mensaje y campos con valores de error (como en Delphi).

### 4.3. Stored Procedure
- `sp_validate_hasta_form(bimestre, anio)`
- Devuelve: is_valid (bool), bimestre, anio, message (text)

### 4.4. Frontend
- Página Vue.js independiente.
- Validación en cliente y servidor.
- Botón Cancelar: pone valores de salida (9, 9999) y muestra mensaje.

## 5. Seguridad
- Validación estricta en backend y frontend.
- No se permite acceso a operaciones no definidas.

## 6. Extensibilidad
- El endpoint `/api/execute` permite agregar más operaciones fácilmente.
- El SP puede extenderse para lógica adicional.

## 7. Consideraciones de Migración
- El comportamiento de los botones y validaciones replica el flujo Delphi.
- Los valores de salida (9, 9999) se mantienen para compatibilidad.

## 8. Pruebas
- Casos de uso y pruebas incluidas para asegurar la funcionalidad.
