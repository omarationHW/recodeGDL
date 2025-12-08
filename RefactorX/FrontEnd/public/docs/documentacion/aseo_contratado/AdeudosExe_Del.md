# DocumentaciÃ³n TÃ©cnica: AdeudosExe_Del

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración Formulario AdeudosExe_Del (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
El formulario "AdeudosExe_Del" permite realizar la baja física (eliminación) o baja lógica (marcar como baja) de registros de pagos de contratos para un periodo y tipo de operación específico. La migración implementa:
- Un endpoint API unificado `/api/execute` que recibe un objeto `eRequest` con la acción y parámetros.
- Un controlador Laravel que enruta la acción y ejecuta la lógica correspondiente, usando transacciones.
- Stored Procedures en PostgreSQL para las operaciones críticas (baja física, baja lógica, consulta de contrato).
- Un componente Vue.js como página independiente, con formulario y resultado.

## 2. API Unificada (eRequest/eResponse)
- **Endpoint:** `POST /api/execute`
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "list|delete|logic_delete",
      "contrato": int,
      "ctrol_aseo": int,
      "aso": int,
      "mes": int,
      "ctrol_operacion": int,
      "oficio": string, // solo para baja lógica
      "usuario_id": int
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
- **AdeudosExeDelController**
  - Método `execute(Request $request)`
  - Rutea según `action` a:
    - `listContrato`: Consulta datos del contrato.
    - `deleteFisica`: Baja física (DELETE).
    - `deleteLogica`: Baja lógica (UPDATE status_vigencia = 'B').
  - Usa transacciones para operaciones críticas.
  - Valida parámetros obligatorios.

## 4. Stored Procedures PostgreSQL
- **sp_adeudos_exe_del_fisica**: Elimina físicamente el registro de pago.
- **sp_adeudos_exe_del_logica**: Realiza baja lógica (status_vigencia = 'B').
- **sp_adeudos_exe_del_list_contrato**: Consulta datos básicos del contrato.

## 5. Componente Vue.js
- Página independiente, sin tabs.
- Formulario con campos:
  - Contrato, Tipo de Aseo, Año, Mes, Tipo de Movimiento, Oficio, Opción de Movimiento (radio: física/lógica).
- Botón Ejecutar y Cancelar.
- Muestra resultado de la operación.
- Carga catálogos de tipos de aseo y operación vía API.

## 6. Seguridad y Validaciones
- Validación de campos obligatorios en frontend y backend.
- Uso de transacciones en operaciones críticas.
- El usuario debe estar autenticado y su ID debe enviarse en la petición.

## 7. Integración
- El endpoint `/api/execute` puede ser compartido por otros formularios, usando el campo `action` para distinguir la operación.
- Los catálogos (`tipos-aseo`, `tipos-operacion`) deben exponerse como endpoints REST o estar cacheados en frontend.

## 8. Consideraciones de Migración
- Los nombres de tablas y campos deben coincidir con la estructura de PostgreSQL.
- Los stored procedures deben ser idempotentes y seguros ante errores.
- El frontend debe manejar correctamente los mensajes de error y éxito.

## 9. Ejemplo de Petición para Baja Física
```json
{
  "eRequest": {
    "action": "delete",
    "contrato": 12345,
    "ctrol_aseo": 9,
    "aso": 2024,
    "mes": 6,
    "ctrol_operacion": 3,
    "usuario_id": 1
  }
}
```

## 10. Ejemplo de Petición para Baja Lógica
```json
{
  "eRequest": {
    "action": "logic_delete",
    "contrato": 12345,
    "ctrol_aseo": 9,
    "aso": 2024,
    "mes": 6,
    "ctrol_operacion": 3,
    "oficio": "OF123456",
    "usuario_id": 1
  }
}
```


## Casos de Prueba

## Casos de Prueba para AdeudosExe_Del

### 1. Baja Física Exitosa
- **Entrada:**
  - contrato: 12345
  - ctrol_aseo: 9
  - aso: 2024
  - mes: 6
  - ctrol_operacion: 3
  - usuario_id: 1
  - action: delete
- **Esperado:**
  - Respuesta success: true
  - Mensaje: "Baja física realizada"
  - El registro es eliminado de ta_16_pagos

### 2. Baja Lógica Exitosa
- **Entrada:**
  - contrato: 12345
  - ctrol_aseo: 9
  - aso: 2024
  - mes: 6
  - ctrol_operacion: 3
  - oficio: "OF123456"
  - usuario_id: 1
  - action: logic_delete
- **Esperado:**
  - Respuesta success: true
  - Mensaje: "Baja lógica realizada"
  - El registro es actualizado con status_vigencia = 'B', usuario y folio_rcbo

### 3. Contrato No Encontrado
- **Entrada:**
  - contrato: 99999
  - ctrol_aseo: 9
  - action: list
- **Esperado:**
  - Respuesta success: false
  - Mensaje: "Contrato no encontrado"

### 4. Baja Física con Registro Inexistente
- **Entrada:**
  - contrato: 12345
  - ctrol_aseo: 9
  - aso: 2024
  - mes: 6
  - ctrol_operacion: 99
  - usuario_id: 1
  - action: delete
- **Esperado:**
  - Respuesta success: true
  - data.deleted = 0
  - Mensaje: "Baja física realizada"

### 5. Validación de Campos Obligatorios
- **Entrada:**
  - contrato: null
  - ctrol_aseo: null
  - action: delete
- **Esperado:**
  - Respuesta success: false
  - Mensaje de error de validación


## Casos de Uso

# Casos de Uso - AdeudosExe_Del

**Categoría:** Form

## Caso de Uso 1: Baja Física de Adeudo (Eliminación Definitiva)

**Descripción:** El usuario desea eliminar definitivamente el registro de pago de un contrato para un periodo y tipo de operación específico.

**Precondiciones:**
El contrato y el registro de pago existen y están vigentes (status_vigencia = 'V'). El usuario tiene permisos.

**Pasos a seguir:**
1. El usuario ingresa al formulario de Baja de Adeudos.
2. Selecciona el contrato, tipo de aseo, año, mes y tipo de operación.
3. Selecciona 'Baja Física'.
4. Da clic en 'Ejecutar'.
5. El sistema envía la petición al endpoint /api/execute con action=delete.
6. El backend ejecuta el stored procedure de baja física.
7. El sistema muestra mensaje de éxito o error.

**Resultado esperado:**
El registro de pago es eliminado de la base de datos. El usuario ve un mensaje de éxito.

**Datos de prueba:**
{ "contrato": 12345, "ctrol_aseo": 9, "aso": 2024, "mes": 6, "ctrol_operacion": 3, "usuario_id": 1 }

---

## Caso de Uso 2: Baja Lógica de Adeudo (Marcar como Baja)

**Descripción:** El usuario desea marcar como baja (status_vigencia = 'B') el registro de pago de un contrato para un periodo y tipo de operación específico.

**Precondiciones:**
El contrato y el registro de pago existen y están vigentes. El usuario tiene permisos.

**Pasos a seguir:**
1. El usuario ingresa al formulario de Baja de Adeudos.
2. Selecciona el contrato, tipo de aseo, año, mes y tipo de operación.
3. Ingresa el número de oficio.
4. Selecciona 'Baja Lógica'.
5. Da clic en 'Ejecutar'.
6. El sistema envía la petición al endpoint /api/execute con action=logic_delete.
7. El backend ejecuta el stored procedure de baja lógica.
8. El sistema muestra mensaje de éxito o error.

**Resultado esperado:**
El registro de pago es actualizado con status_vigencia = 'B', usuario y folio_rcbo. El usuario ve un mensaje de éxito.

**Datos de prueba:**
{ "contrato": 12345, "ctrol_aseo": 9, "aso": 2024, "mes": 6, "ctrol_operacion": 3, "oficio": "OF123456", "usuario_id": 1 }

---

## Caso de Uso 3: Consulta de Contrato para Baja de Adeudo

**Descripción:** El usuario desea consultar los datos básicos del contrato antes de realizar la baja.

**Precondiciones:**
El contrato existe.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato y tipo de aseo.
2. El sistema consulta los datos del contrato vía /api/execute con action=list.
3. El sistema muestra los datos del contrato.

**Resultado esperado:**
Se muestran los datos básicos del contrato y unidad de recolección.

**Datos de prueba:**
{ "contrato": 12345, "ctrol_aseo": 9 }

---



---
**Componente:** `AdeudosExe_Del.vue`
**MÃ³dulo:** `aseo_contratado`

