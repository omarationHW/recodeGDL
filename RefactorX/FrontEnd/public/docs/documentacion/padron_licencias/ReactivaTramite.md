# Documentación Técnica: ReactivaTramite

## Análisis Técnico

# Documentación Técnica: Migración de Formulario ReactivaTramite

## 1. Descripción General
Este módulo permite la reactivación de trámites previamente cancelados o rechazados en el sistema. La migración transforma la lógica Delphi a una arquitectura moderna basada en Laravel (API), Vue.js (Frontend) y PostgreSQL (Stored Procedures).

## 2. Arquitectura
- **Frontend:** Vue.js SPA, página independiente para Reactivación de Trámites.
- **Backend:** Laravel API con endpoint unificado `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.

## 3. Flujo de Trabajo
1. El usuario ingresa el número de trámite y consulta los datos.
2. Si el trámite está cancelado ('C') o rechazado ('R'), puede reactivarlo ingresando un motivo.
3. El sistema actualiza el estatus del trámite y de sus revisiones asociadas.

## 4. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "get_tramite" | "reactivar_tramite",
    "params": { ... }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true|false,
    "data": { ... },
    "message": "..."
  }
  ```

## 5. Stored Procedures
- **get_tramite:** Devuelve todos los datos del trámite, incluyendo giro y nombre completo del propietario.
- **reactivar_tramite:** Realiza la reactivación del trámite y actualiza revisiones y seg_revision.

## 6. Seguridad
- Validación de parámetros en backend.
- Solo permite reactivar trámites con estatus 'C' (cancelado) o 'R' (rechazado).

## 7. Consideraciones
- El frontend es una página completa, no usa tabs.
- El motivo de reactivación es obligatorio.
- El proceso es atómico: si falla alguna actualización, no se realiza ningún cambio.

## 8. Integración
- El componente Vue puede integrarse en cualquier SPA con Vue Router.
- El endpoint `/api/execute` debe estar protegido según las políticas de autenticación del sistema.

## 9. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar la estructura del endpoint.

---

## Casos de Prueba

# Casos de Prueba: ReactivaTramite

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|--------------------|
| 1 | Reactivar trámite cancelado | id_tramite=12345 (estatus 'C'), motivo='Motivo de prueba' | Respuesta success=true, mensaje='Trámite reactivado correctamente.', estatus del trámite='T', revisiones='V' |
| 2 | Reactivar trámite rechazado | id_tramite=23456 (estatus 'R'), motivo='Motivo de prueba' | Respuesta success=true, mensaje='Trámite reactivado correctamente.', estatus del trámite='T', revisiones='V' |
| 3 | Intentar reactivar trámite aprobado | id_tramite=54321 (estatus 'A'), motivo='...' | Respuesta success=false, mensaje='El trámite ya se encuentra aprobado. No se puede reactivar.' |
| 4 | Intentar reactivar trámite en estatus inválido | id_tramite=34567 (estatus 'T'), motivo='...' | Respuesta success=false, mensaje='El trámite no se encuentra cancelado o rechazado.' |
| 5 | Buscar trámite inexistente | id_tramite=99999 | Respuesta success=false, mensaje='Trámite no encontrado.' |
| 6 | Reactivar trámite sin motivo | id_tramite=12345 (estatus 'C'), motivo='' | Respuesta success=false, mensaje='Debe ingresar un motivo' (validación frontend) |

## Casos de Uso

# Casos de Uso - ReactivaTramite

**Categoría:** Form

## Caso de Uso 1: Reactivar un trámite cancelado

**Descripción:** Un usuario busca un trámite con estatus 'C' (cancelado) y lo reactiva proporcionando un motivo.

**Precondiciones:**
El trámite existe y su estatus es 'C'.

**Pasos a seguir:**
1. El usuario accede a la página de Reactivación de Trámites.
2. Ingresa el número de trámite (por ejemplo, 12345) y presiona Buscar.
3. El sistema muestra los datos del trámite.
4. El usuario hace clic en 'Reactivar'.
5. Ingresa el motivo de reactivación y confirma.
6. El sistema actualiza el trámite y muestra mensaje de éxito.

**Resultado esperado:**
El trámite cambia su estatus a 'T' y las revisiones asociadas a 'V'. Se muestra mensaje de éxito.

**Datos de prueba:**
id_tramite: 12345 (estatus: 'C')

---

## Caso de Uso 2: Intentar reactivar un trámite aprobado

**Descripción:** El usuario intenta reactivar un trámite que ya está aprobado (estatus 'A').

**Precondiciones:**
El trámite existe y su estatus es 'A'.

**Pasos a seguir:**
1. El usuario ingresa el número de trámite (por ejemplo, 54321) y presiona Buscar.
2. El sistema muestra los datos del trámite.
3. El usuario intenta hacer clic en 'Reactivar'.

**Resultado esperado:**
El botón de reactivar está deshabilitado y se muestra mensaje indicando que no se puede reactivar.

**Datos de prueba:**
id_tramite: 54321 (estatus: 'A')

---

## Caso de Uso 3: Buscar un trámite inexistente

**Descripción:** El usuario busca un trámite que no existe en la base de datos.

**Precondiciones:**
El trámite no existe.

**Pasos a seguir:**
1. El usuario ingresa un número de trámite inexistente (por ejemplo, 99999) y presiona Buscar.

**Resultado esperado:**
El sistema muestra mensaje de error indicando que el trámite no fue encontrado.

**Datos de prueba:**
id_tramite: 99999 (no existe)

---
