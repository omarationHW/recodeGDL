# Documentación Técnica: Migración Formulario ConsTP (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo corresponde a la migración del formulario "Consulta de Transmisiones Patrimoniales" (ConsTP) desde Delphi a una arquitectura moderna basada en Laravel (API), Vue.js (Frontend) y PostgreSQL (Base de Datos). El flujo de consulta es unificado mediante un endpoint API único (`/api/execute`) que recibe solicitudes en el patrón `eRequest` y responde en el patrón `eResponse`.

## 2. Arquitectura
- **Frontend:** Vue.js SPA, cada formulario es una página independiente.
- **Backend:** Laravel API, controlador único para todas las operaciones (`ExecuteController`).
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "operation": "constp_query",
      "params": {
        "notaria": 1,
        "municipio": 2,
        "escritura": 123
      }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [
        {
          "notaria": 1,
          "municipio": 2,
          "escritura": 123,
          "otros_datos": "..."
        }
      ],
      "error": null
    }
  }
  ```

## 4. Stored Procedure
- **Nombre:** `sp_constp_query`
- **Parámetros:**
  - `p_notaria` (INTEGER, puede ser NULL)
  - `p_municipio` (INTEGER, puede ser NULL)
  - `p_escritura` (INTEGER, puede ser NULL)
- **Retorna:**
  - `notaria`, `municipio`, `escritura`, `otros_datos`
- **Descripción:** Permite filtrar por cualquiera de los campos. Si un parámetro es NULL, no se filtra por ese campo.

## 5. Frontend (Vue.js)
- Página independiente con ruta propia.
- Formulario con 3 campos numéricos: Notaría, Municipio de Adscripción, Escritura.
- Botón de consulta que llama al endpoint unificado.
- Muestra resultados en tabla o mensaje si no hay resultados.
- Manejo de errores y loading.

## 6. Backend (Laravel)
- Controlador `ExecuteController` con método `execute`.
- Recibe `eRequest`, determina la operación y llama al stored procedure correspondiente.
- Devuelve respuesta estructurada en `eResponse`.

## 7. Seguridad
- Validación básica de parámetros en el backend.
- Uso de parámetros preparados para evitar SQL Injection.

## 8. Suposiciones
- Existe la tabla `transmisiones_patrimoniales` con los campos mencionados.
- El campo `otros_datos` es un ejemplo y puede adaptarse según la estructura real.

## 9. Extensibilidad
- El endpoint y patrón permiten agregar más operaciones y formularios fácilmente.

---
