# Documentación Técnica: Migración de Formulario 'Hastafrm' (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario 'Hastafrm' de Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El formulario permite al usuario ingresar un bimestre (1-6) y un año (>=1970 y <= año actual) para determinar hasta qué periodo se realizará un pago. Incluye validaciones y control de flujo para aceptar o cancelar la operación.

## 2. Arquitectura
- **Frontend:** Vue.js SPA, cada formulario es una página independiente.
- **Backend:** Laravel API, endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos:** PostgreSQL, lógica de validación encapsulada en stored procedure.

## 3. Flujo de Datos
1. El usuario accede a la página 'Pagar hasta'.
2. Ingresa bimestre y año.
3. Al hacer clic en 'Aceptar', el frontend valida y envía los datos a `/api/execute` con operación `validate_hasta_form`.
4. El backend valida los datos (puede delegar a SP) y retorna el resultado en eResponse.
5. El frontend muestra mensajes de éxito o error.
6. Si el usuario cancela, los campos se llenan con valores de salida especial (9 y 9999).

## 4. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
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
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": { "bimestre": 2, "anio": 2024 },
      "errors": [],
      "messages": ["Validación exitosa."]
    }
  }
  ```

## 5. Validaciones
- **Bimestre:** Obligatorio, entero, entre 1 y 6.
- **Año:** Obligatorio, entero, >=1970 y <= año actual.
- **Cancelación:** Asigna bimestre=9 y año=9999.

## 6. Stored Procedure
- `sp_validate_hasta_form(p_bimestre integer, p_anio integer)`
  - Valida los parámetros y retorna success/mensaje.

## 7. Seguridad
- Validación de datos en frontend y backend.
- No se permite guardar datos inválidos.

## 8. Extensibilidad
- El endpoint `/api/execute` permite agregar nuevas operaciones fácilmente.

## 9. Pruebas
- Casos de uso y pruebas detalladas en secciones siguientes.
