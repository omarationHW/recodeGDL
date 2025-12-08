# DocumentaciÃ³n TÃ©cnica: Adeudos_Ins

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración Formulario Adeudos_Ins (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend**: Laravel API, endpoint único `/api/execute` (POST), patrón eRequest/eResponse.
- **Frontend**: Vue.js SPA, cada formulario es una página independiente (NO tabs).
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures.
- **Catálogos**: Tablas `cat_tipo_aseo`, `cat_operacion`.
- **Transacciones**: Todas las operaciones de inserción usan transacciones.

## 2. API Unificada
- **Endpoint**: `/api/execute` (POST)
- **Request**:
  ```json
  {
    "action": "adeudos_ins_insert",
    "params": {
      "contrato": 1234,
      "ctrol_aseo": 9,
      "ejercicio": 2024,
      "aso": 2024,
      "mes": "06",
      "ctrol_operacion": 7,
      "exedencias": 2,
      "oficio": "OF-1234"
    }
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "message": "Exedencia registrada correctamente",
    "data": null
  }
  ```

## 3. Lógica de Negocio
- **Validaciones**:
  - El contrato debe existir, estar vigente y el año debe ser válido.
  - La fecha de exedencia no puede ser menor al inicio de obligación.
  - Debe existir cuota normal para el periodo.
  - No debe existir exedencia/contenedor para el mismo periodo y operación.
  - El año debe estar entre 1989 y el año actual.
- **Inserción**:
  - Se calcula el importe: `exedencias * costo_exed`.
  - Se inserta en `ta_16_pagos` con status 'V'.

## 4. Stored Procedures
- Toda la lógica de validación e inserción está en `sp_adeudos_ins_insert`.
- Catálogos y validación de contrato en SPs separados.

## 5. Vue.js Frontend
- Página independiente, sin tabs.
- Formulario reactivo, validación básica en frontend.
- Llama a `/api/execute` para catálogos, validación y registro.
- Mensajes de éxito/error claros.

## 6. Seguridad
- El endpoint requiere autenticación (Laravel Sanctum/JWT recomendado).
- El usuario autenticado se usa como `usuario` en la inserción.

## 7. Extensibilidad
- El endpoint y SPs permiten agregar más acciones y lógica sin modificar el frontend.

## 8. Pruebas
- Casos de uso y pruebas cubren validaciones, inserción correcta y errores de negocio.

---

# Esquema de Tablas Relevantes

- **ta_16_contratos**: Contratos principales.
- **ta_16_pagos**: Pagos, exedencias, contenedores.
- **cat_tipo_aseo**: Catálogo de tipo de aseo.
- **cat_operacion**: Catálogo de operaciones.

---

# Flujo de la Página Adeudos_Ins

1. Al cargar, obtiene catálogos (`adeudos_ins_get_catalogs`).
2. El usuario llena el formulario y envía.
3. Se valida el contrato (`adeudos_ins_validate_contrato`).
4. Si es válido, se ejecuta la inserción (`adeudos_ins_insert`).
5. Se muestra mensaje de éxito o error.

---

# Notas de Migración
- El formulario Delphi usaba queries directas y lógica en el frontend. Ahora toda la lógica crítica está en el backend y SPs.
- El frontend es desacoplado y sólo consume el API.
- El endpoint es extensible para otros formularios/procesos.


## Casos de Prueba

## Casos de Prueba para Adeudos_Ins

### 1. Registro exitoso
- **Input:** Datos válidos de contrato, periodo, tipo de operación, cantidad y oficio.
- **Acción:** POST /api/execute { action: 'adeudos_ins_insert', params: {...} }
- **Resultado esperado:** success: true, message: 'Exedencia registrada correctamente'.

### 2. Contrato inexistente
- **Input:** Contrato no existente.
- **Acción:** POST /api/execute { action: 'adeudos_ins_insert', params: {...} }
- **Resultado esperado:** success: false, message: 'Contrato no encontrado o fuera de rango de ejercicio'.

### 3. Fecha de exedencia menor al inicio de obligación
- **Input:** Fecha de exedencia anterior a aso_mes_oblig del contrato.
- **Acción:** POST /api/execute { action: 'adeudos_ins_insert', params: {...} }
- **Resultado esperado:** success: false, message: 'La fecha de exedencia es menor al inicio de obligación'.

### 4. No existe cuota normal para el periodo
- **Input:** No hay cuota normal para el periodo.
- **Acción:** POST /api/execute { action: 'adeudos_ins_insert', params: {...} }
- **Resultado esperado:** success: false, message: 'No existe cuota normal para el periodo'.

### 5. Exedencia duplicada
- **Input:** Ya existe exedencia/contenedor para el periodo y operación.
- **Acción:** POST /api/execute { action: 'adeudos_ins_insert', params: {...} }
- **Resultado esperado:** success: false, message: 'Ya existe exedencia/contenedor para este periodo'.

### 6. Año fuera de rango
- **Input:** Año menor a 1989 o mayor al actual.
- **Acción:** POST /api/execute { action: 'adeudos_ins_insert', params: {...} }
- **Resultado esperado:** success: false, message: 'Año fuera de rango permitido'.

### 7. Validación de contrato
- **Input:** Contrato válido.
- **Acción:** POST /api/execute { action: 'adeudos_ins_validate_contrato', params: {...} }
- **Resultado esperado:** success: true, contrato_id: ...

### 8. Validación de contrato no existente
- **Input:** Contrato no existente.
- **Acción:** POST /api/execute { action: 'adeudos_ins_validate_contrato', params: {...} }
- **Resultado esperado:** success: false, message: 'Contrato no encontrado o no vigente'.


## Casos de Uso

# Casos de Uso - Adeudos_Ins

**Categoría:** Form

## Caso de Uso 1: Registro exitoso de exedencia para contrato vigente

**Descripción:** El usuario registra una exedencia para un contrato vigente, con todos los datos correctos.

**Precondiciones:**
El contrato existe, está vigente, y tiene cuota normal para el periodo.

**Pasos a seguir:**
1. El usuario accede a la página de Captura de Excedencias.
2. Ingresa el número de contrato, selecciona tipo de aseo, año, mes, tipo de movimiento, cantidad de exedencias y oficio.
3. Presiona 'Ejecutar'.
4. El sistema valida el contrato y las reglas de negocio.
5. El sistema inserta el registro y muestra mensaje de éxito.

**Resultado esperado:**
La exedencia se registra correctamente en la base de datos y se muestra mensaje de éxito.

**Datos de prueba:**
{
  "contrato": 1234,
  "ctrol_aseo": 9,
  "ejercicio": 2024,
  "aso": 2024,
  "mes": "06",
  "ctrol_operacion": 7,
  "exedencias": 2,
  "oficio": "OF-1234"
}

---

## Caso de Uso 2: Intento de registro con contrato inexistente

**Descripción:** El usuario intenta registrar una exedencia para un contrato que no existe.

**Precondiciones:**
El contrato no existe en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de Captura de Excedencias.
2. Ingresa un número de contrato inexistente y completa el resto del formulario.
3. Presiona 'Ejecutar'.
4. El sistema valida y detecta que el contrato no existe.

**Resultado esperado:**
El sistema muestra mensaje de error: 'Contrato no encontrado o no vigente'.

**Datos de prueba:**
{
  "contrato": 999999,
  "ctrol_aseo": 9,
  "ejercicio": 2024,
  "aso": 2024,
  "mes": "06",
  "ctrol_operacion": 7,
  "exedencias": 2,
  "oficio": "OF-9999"
}

---

## Caso de Uso 3: Intento de registro de exedencia duplicada

**Descripción:** El usuario intenta registrar una exedencia para un periodo donde ya existe una exedencia/contenedor.

**Precondiciones:**
Ya existe un registro de exedencia para el mismo contrato, periodo y tipo de operación.

**Pasos a seguir:**
1. El usuario accede a la página de Captura de Excedencias.
2. Ingresa los datos de un contrato y periodo donde ya existe exedencia.
3. Presiona 'Ejecutar'.
4. El sistema valida y detecta duplicidad.

**Resultado esperado:**
El sistema muestra mensaje de error: 'Ya existe exedencia/contenedor para este periodo'.

**Datos de prueba:**
{
  "contrato": 1234,
  "ctrol_aseo": 9,
  "ejercicio": 2024,
  "aso": 2024,
  "mes": "06",
  "ctrol_operacion": 7,
  "exedencias": 2,
  "oficio": "OF-1234"
}

---



---
**Componente:** `Adeudos_Ins.vue`
**MÃ³dulo:** `aseo_contratado`

