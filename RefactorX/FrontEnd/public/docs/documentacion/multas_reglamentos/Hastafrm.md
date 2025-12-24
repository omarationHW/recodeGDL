# Documentación: Hastafrm

## Análisis Técnico

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

## Casos de Uso

# Casos de Uso - Hastafrm

**Categoría:** Form

## Caso de Uso 1: Validación exitosa de formulario 'Pagar hasta'

**Descripción:** El usuario ingresa un bimestre y año válidos y el sistema valida correctamente.

**Precondiciones:**
El usuario accede a la página 'Pagar hasta'.

**Pasos a seguir:**
1. El usuario ingresa '2' en el campo Bimestre.
2. El usuario ingresa '2024' en el campo Año.
3. El usuario presiona 'Aceptar'.

**Resultado esperado:**
El sistema muestra mensaje de éxito: 'Formulario validado correctamente.' y los datos son aceptados.

**Datos de prueba:**
{ "bimestre": 2, "anio": 2024 }

---

## Caso de Uso 2: Error por bimestre fuera de rango

**Descripción:** El usuario ingresa un bimestre inválido (por ejemplo, 7) y el sistema rechaza la entrada.

**Precondiciones:**
El usuario accede a la página 'Pagar hasta'.

**Pasos a seguir:**
1. El usuario ingresa '7' en el campo Bimestre.
2. El usuario ingresa '2024' en el campo Año.
3. El usuario presiona 'Aceptar'.

**Resultado esperado:**
El sistema muestra mensaje de error: 'El bimestre solo puede ser de 1 a 6.' y no acepta los datos.

**Datos de prueba:**
{ "bimestre": 7, "anio": 2024 }

---

## Caso de Uso 3: Cancelación del formulario

**Descripción:** El usuario decide cancelar la operación y el sistema pone los valores de salida y muestra mensaje de cancelación.

**Precondiciones:**
El usuario accede a la página 'Pagar hasta'.

**Pasos a seguir:**
1. El usuario presiona el botón 'Cancelar'.

**Resultado esperado:**
El sistema pone bimestre=9, año=9999 y muestra mensaje 'Operación cancelada.'

**Datos de prueba:**
N/A (acción de UI)

---

## Casos de Prueba

## Casos de Prueba: Formulario 'Pagar hasta'

| # | Descripción | Entrada | Acción | Resultado Esperado |
|---|-------------|---------|--------|-------------------|
| 1 | Validación exitosa | bimestre=3, anio=2023 | Aceptar | Mensaje de éxito, datos aceptados |
| 2 | Bimestre fuera de rango | bimestre=0, anio=2023 | Aceptar | Error: 'El bimestre solo puede ser de 1 a 6.' |
| 3 | Año menor a 1970 | bimestre=2, anio=1969 | Aceptar | Error: 'El año debe estar entre 1970 y [año actual]' |
| 4 | Año mayor al actual | bimestre=2, anio=2100 | Aceptar | Error: 'El año debe estar entre 1970 y [año actual]' |
| 5 | Campos vacíos | bimestre='', anio='' | Aceptar | Error de campos obligatorios |
| 6 | Cancelar operación | N/A | Cancelar | bimestre=9, anio=9999, mensaje de cancelación |
| 7 | Bimestre no numérico | bimestre='a', anio=2023 | Aceptar | Error de validación |
| 8 | Año no numérico | bimestre=2, anio='abcd' | Aceptar | Error de validación |

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

