# DocumentaciÃ³n TÃ©cnica: AdeudosMult_Ins

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración de Formulario AdeudosMult_Ins (Delphi) a Laravel + Vue.js + PostgreSQL

## Descripción General
Este módulo permite la carga masiva de excedentes (exedencias) para contratos de recolección de residuos, validando la existencia de contrato, cuota normal y ausencia de excedente previo para el periodo seleccionado. La migración implementa:

- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Componente Vue.js como página independiente
- **Base de Datos:** Lógica de negocio en stored procedure PostgreSQL
- **API:** Comunicación unificada, validación y procesamiento

## Arquitectura
- **API Endpoint:** `/api/execute` (POST)
- **Acciones soportadas:**
  - `getCatalogs`: Devuelve catálogos de tipos de aseo, tipos de operación y meses
  - `getSheetTemplate`: Devuelve la estructura de la hoja de cálculo
  - `validateSheet`: Valida los datos antes de grabar
  - `saveSheet`: Procesa y graba los datos en la base de datos

- **Stored Procedure:** `sp_adeudos_mult_ins_insert` procesa la inserción masiva validando reglas de negocio

## Flujo de Trabajo
1. **Carga de página:**
    - Vue solicita catálogos (`getCatalogs`)
    - Vue inicializa la hoja de cálculo (tabla editable)
2. **Usuario captura datos:**
    - Selecciona tipo de aseo, periodo, tipo de movimiento, oficio
    - Llena filas con número de contrato y cantidad de excedencia
3. **Validación:**
    - Usuario presiona "Validar"
    - Se envía a `/api/execute` con acción `validateSheet`
    - Backend revisa estructura y tipos de datos
4. **Grabado:**
    - Usuario presiona "Grabar"
    - Se envía a `/api/execute` con acción `saveSheet`
    - Backend ejecuta el stored procedure, retorna éxito o errores

## Validaciones
- Contrato debe existir y corresponder al tipo de aseo
- Debe existir cuota normal para el periodo
- No debe existir excedente previo para el periodo y tipo de operación
- Excedencia debe ser numérica y mayor a cero

## Seguridad
- El endpoint requiere autenticación (Laravel middleware)
- El userId se utiliza para auditoría en la inserción

## Manejo de Errores
- Errores de validación se retornan como lista
- Errores de base de datos se retornan como mensaje general
- Si alguna fila falla, no se graba ninguna (transacción)

## Estructura de la Tabla ta_16_pagos (relevante)
- control_contrato (int)
- aso_mes_pago (varchar o date)
- ctrol_operacion (int)
- importe (numeric)
- status_vigencia (char)
- fecha_hora_pago (timestamp)
- id_rec (int)
- caja (varchar)
- consec_operacion (int)
- folio_rcbo (varchar)
- usuario (int)
- exedencias (int)

## API eRequest/eResponse
- Todas las acciones usan el mismo endpoint `/api/execute`
- El parámetro `action` define la operación
- El parámetro `params` contiene los datos específicos

## Ejemplo de Request
```json
{
  "action": "saveSheet",
  "params": {
    "tipoAseo": 9,
    "tipoOper": 7,
    "anio": 2024,
    "mes": "06",
    "oficio": "OF-1234",
    "rows": [
      { "contrato": 12345, "excedencia": 2 },
      { "contrato": 23456, "excedencia": 1 }
    ]
  }
}
```

## Ejemplo de Response
```json
{
  "success": true,
  "message": "Carga de Excedencias exitosa"
}
```

## Notas de Migración
- El componente Vue.js es una página independiente, no usa tabs
- El backend es desacoplado y puede ser reutilizado por otros frontends
- El stored procedure es atómico y seguro para concurrencia


## Casos de Prueba

## Casos de Prueba para AdeudosMult_Ins

### Caso 1: Carga exitosa de excedentes
- **Input:**
  - tipoAseo: 9
  - tipoOper: 7
  - anio: 2024
  - mes: '06'
  - oficio: 'OF-1234'
  - rows: [{contrato: 12345, excedencia: 2}, {contrato: 23456, excedencia: 1}]
- **Acción:** Validar y grabar
- **Esperado:** Respuesta success true, mensaje de éxito

### Caso 2: Contrato inexistente
- **Input:**
  - tipoAseo: 9
  - tipoOper: 7
  - anio: 2024
  - mes: '06'
  - oficio: 'OF-1234'
  - rows: [{contrato: 99999, excedencia: 1}]
- **Acción:** Validar
- **Esperado:** Error en la fila: "Contrato 99999 no existe o no corresponde al tipo de aseo"

### Caso 3: Excedente duplicado
- **Input:**
  - tipoAseo: 9
  - tipoOper: 7
  - anio: 2024
  - mes: '06'
  - oficio: 'OF-1234'
  - rows: [{contrato: 12345, excedencia: 1}] (ya existe ese excedente)
- **Acción:** Validar
- **Esperado:** Error en la fila: "Contrato 12345: Ya existe excedente para el periodo"

### Caso 4: Falta de cuota normal
- **Input:**
  - tipoAseo: 9
  - tipoOper: 7
  - anio: 2024
  - mes: '06'
  - oficio: 'OF-1234'
  - rows: [{contrato: 12345, excedencia: 1}] (no existe cuota normal para ese periodo)
- **Acción:** Validar
- **Esperado:** Error en la fila: "Contrato 12345: No existe cuota normal para el periodo"

### Caso 5: Excedencia no numérica
- **Input:**
  - tipoAseo: 9
  - tipoOper: 7
  - anio: 2024
  - mes: '06'
  - oficio: 'OF-1234'
  - rows: [{contrato: 12345, excedencia: 'abc'}]
- **Acción:** Validar
- **Esperado:** Error en la fila: "Contrato y Excedencia deben ser numéricos"


## Casos de Uso

# Casos de Uso - AdeudosMult_Ins

**Categoría:** Form

## Caso de Uso 1: Carga masiva de excedentes para contratos vigentes

**Descripción:** El usuario desea cargar excedentes para varios contratos en un periodo específico, asegurando que no existan duplicados y que todos los contratos sean válidos.

**Precondiciones:**
El usuario está autenticado y tiene permisos de captura. Los contratos existen y tienen cuota normal vigente para el periodo.

**Pasos a seguir:**
1. El usuario accede a la página de Generación Múltiple de Excedentes.
2. Selecciona el tipo de aseo, periodo (año y mes), tipo de movimiento y captura el oficio.
3. Llena la hoja de cálculo con varios contratos y cantidades de excedencia.
4. Presiona 'Validar' y verifica que no hay errores.
5. Presiona 'Grabar'.
6. El sistema procesa y muestra mensaje de éxito.

**Resultado esperado:**
Todos los excedentes se insertan correctamente. El usuario ve mensaje de éxito.

**Datos de prueba:**
tipoAseo: 9, tipoOper: 7, anio: 2024, mes: '06', oficio: 'OF-1234', rows: [{contrato: 12345, excedencia: 2}, {contrato: 23456, excedencia: 1}]

---

## Caso de Uso 2: Intento de carga con contrato inexistente

**Descripción:** El usuario intenta cargar un excedente para un contrato que no existe o no corresponde al tipo de aseo.

**Precondiciones:**
El usuario está autenticado. El contrato no existe o no corresponde al tipo de aseo.

**Pasos a seguir:**
1. El usuario accede a la página y llena los datos generales.
2. Ingresa un contrato inexistente en la hoja de cálculo.
3. Presiona 'Validar'.
4. El sistema muestra error en la fila correspondiente.

**Resultado esperado:**
El sistema no permite grabar y muestra el error específico.

**Datos de prueba:**
tipoAseo: 9, tipoOper: 7, anio: 2024, mes: '06', oficio: 'OF-1234', rows: [{contrato: 99999, excedencia: 1}]

---

## Caso de Uso 3: Carga con excedente ya existente para el periodo

**Descripción:** El usuario intenta cargar un excedente para un contrato y periodo donde ya existe un registro de excedente.

**Precondiciones:**
El usuario está autenticado. Ya existe un registro de excedente para ese contrato, periodo y tipo de operación.

**Pasos a seguir:**
1. El usuario accede a la página y llena los datos generales.
2. Ingresa un contrato y periodo donde ya existe excedente.
3. Presiona 'Validar'.
4. El sistema muestra error en la fila correspondiente.

**Resultado esperado:**
El sistema no permite grabar y muestra el error de duplicidad.

**Datos de prueba:**
tipoAseo: 9, tipoOper: 7, anio: 2024, mes: '06', oficio: 'OF-1234', rows: [{contrato: 12345, excedencia: 1}] (asumiendo que ya existe ese excedente)

---



---
**Componente:** `AdeudosMult_Ins.vue`
**MÃ³dulo:** `aseo_contratado`

