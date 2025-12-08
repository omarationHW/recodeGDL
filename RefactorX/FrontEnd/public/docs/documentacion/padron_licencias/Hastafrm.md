# Documentación Técnica: Hastafrm

## Análisis Técnico

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

## Casos de Prueba

## Casos de Prueba para Formulario 'Pagar hasta'

| #  | Descripción                                 | Entrada                | Acción         | Resultado Esperado                         |
|----|---------------------------------------------|------------------------|----------------|--------------------------------------------|
| 1  | Bimestre y año válidos                      | bimestre=3, año=2022   | Aceptar        | Validación exitosa, mensaje de éxito       |
| 2  | Bimestre fuera de rango (0)                 | bimestre=0, año=2022   | Aceptar        | Error: 'Bimestre inválido'                 |
| 3  | Bimestre fuera de rango (7)                 | bimestre=7, año=2022   | Aceptar        | Error: 'Bimestre inválido'                 |
| 4  | Año menor a 1970                            | bimestre=2, año=1969   | Aceptar        | Error: 'Año inválido'                      |
| 5  | Año mayor al actual                         | bimestre=2, año=2099   | Aceptar        | Error: 'Año inválido'                      |
| 6  | Campos vacíos                               | bimestre= , año=       | Aceptar        | Error: campos obligatorios                 |
| 7  | Cancelación                                 | (cualquier valor)      | Cancelar       | bimestre=9, año=9999, mensaje de cancelación|
| 8  | Bimestre válido, año vacío                  | bimestre=2, año=       | Aceptar        | Error: 'Año es obligatorio'                |
| 9  | Año válido, bimestre vacío                  | bimestre= , año=2022   | Aceptar        | Error: 'Bimestre es obligatorio'           |
| 10 | Bimestre y año en el límite inferior        | bimestre=1, año=1970   | Aceptar        | Validación exitosa                         |
| 11 | Bimestre y año en el límite superior        | bimestre=6, año=(actual)| Aceptar       | Validación exitosa                         |

## Casos de Uso

# Casos de Uso - Hastafrm

**Categoría:** Form

## Caso de Uso 1: Validación exitosa de bimestre y año

**Descripción:** El usuario ingresa un bimestre y año válidos y la operación es aceptada.

**Precondiciones:**
El usuario tiene acceso a la página 'Pagar hasta'.

**Pasos a seguir:**
1. El usuario ingresa '2' en el campo Bimestre.
2. El usuario ingresa '2024' en el campo Año.
3. El usuario hace clic en 'Aceptar'.

**Resultado esperado:**
El sistema valida los datos, muestra mensaje de éxito y permite continuar.

**Datos de prueba:**
{ "bimestre": 2, "anio": 2024 }

---

## Caso de Uso 2: Error por bimestre fuera de rango

**Descripción:** El usuario ingresa un bimestre inválido (por ejemplo, 7) y la operación es rechazada.

**Precondiciones:**
El usuario tiene acceso a la página 'Pagar hasta'.

**Pasos a seguir:**
1. El usuario ingresa '7' en el campo Bimestre.
2. El usuario ingresa '2023' en el campo Año.
3. El usuario hace clic en 'Aceptar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el bimestre es inválido.

**Datos de prueba:**
{ "bimestre": 7, "anio": 2023 }

---

## Caso de Uso 3: Cancelación de la operación

**Descripción:** El usuario decide cancelar la operación y el formulario se resetea con valores especiales.

**Precondiciones:**
El usuario tiene acceso a la página 'Pagar hasta'.

**Pasos a seguir:**
1. El usuario hace clic en 'Cancelar'.

**Resultado esperado:**
El formulario asigna bimestre=9 y año=9999, mostrando mensaje de cancelación.

**Datos de prueba:**
{ "bimestre": 9, "anio": 9999 }

---
