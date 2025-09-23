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
