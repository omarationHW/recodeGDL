# DocumentaciÃ³n TÃ©cnica: Rep_AdeudCond

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración de Formulario Rep_AdeudCond (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite consultar y generar reportes de adeudos condonados por contrato y tipo de aseo. El flujo original en Delphi ha sido migrado a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos).

## 2. Arquitectura
- **Frontend:** Vue.js SPA, cada formulario es una página independiente.
- **Backend:** Laravel API con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures.

## 3. Flujo de la Aplicación
1. El usuario ingresa el número de contrato y selecciona el tipo de aseo.
2. El usuario elige el criterio de ordenamiento (periodo de adeudo u operación).
3. Al hacer clic en "Vista Previa":
   - Se valida el número de contrato.
   - Se consulta el contrato y tipo de aseo.
   - Se verifica si existen adeudos condonados para ese contrato.
   - Si existen, se genera y muestra el reporte.

## 4. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  - `eRequest`: Identificador de la operación (string)
  - `params`: Parámetros específicos de la operación (object)
- **Salida:**
  - `eResponse`: Objeto con `success`, `data`, `message`

### Ejemplo de Request
```json
{
  "eRequest": "get_reporte_adeudos_condonados",
  "params": {
    "control_contrato": 12345,
    "opcion": 1
  }
}
```

### Ejemplo de Response
```json
{
  "eResponse": {
    "success": true,
    "data": [ ... ],
    "message": ""
  }
}
```

## 5. Stored Procedures
Toda la lógica SQL reside en funciones de PostgreSQL:
- `get_tipo_aseo_catalog()`: Catálogo de tipos de aseo.
- `get_contrato_by_numero_tipoaseo(num_contrato, ctrol_aseo)`: Consulta contrato.
- `get_adeudos_condonados_by_contrato(control_contrato)`: Adeudos condonados.
- `get_reporte_adeudos_condonados(control_contrato, opcion)`: Reporte principal.

## 6. Validaciones
- El número de contrato debe ser numérico y no vacío.
- Debe existir el contrato y el tipo de aseo seleccionado.
- Deben existir adeudos condonados para mostrar el reporte.

## 7. Seguridad
- Todas las operaciones usan parámetros preparados para evitar SQL Injection.
- El endpoint puede protegerse con middleware de autenticación según la política de la aplicación.

## 8. Extensibilidad
- Se pueden agregar nuevos eRequest fácilmente en el controlador Laravel y como nuevos stored procedures.
- El frontend está desacoplado y puede consumir cualquier operación definida en la API.

## 9. Manejo de Errores
- Los errores se devuelven en el campo `message` de `eResponse`.
- El frontend muestra mensajes claros al usuario.

## 10. Pruebas
- Se proveen casos de uso y escenarios de prueba para validar la funcionalidad.


## Casos de Prueba

# Casos de Prueba para Rep_AdeudCond

| Caso | Descripción | Datos de Entrada | Resultado Esperado |
|------|-------------|------------------|--------------------|
| TC01 | Consulta exitosa de reporte | num_contrato=10001, ctrol_aseo=1, opcion=1 | Tabla con datos de adeudos condonados |
| TC02 | Contrato inexistente | num_contrato=99999, ctrol_aseo=1 | Mensaje de error: 'No existe el contrato o tipo de aseo seleccionado.' |
| TC03 | Contrato sin adeudos condonados | num_contrato=10002, ctrol_aseo=1 | Mensaje de error: 'No existen adeudos condonados para este contrato.' |
| TC04 | Validación de campo obligatorio | num_contrato='', ctrol_aseo=1 | Mensaje de error: 'El No. de Contrato debe ser mayor a cero, intenta con otro.' |
| TC05 | Consulta con ordenamiento por operación | num_contrato=10001, ctrol_aseo=1, opcion=2 | Tabla con datos ordenados por operación |


## Casos de Uso

# Casos de Uso - Rep_AdeudCond

**Categoría:** Form

## Caso de Uso 1: Consulta exitosa de reporte de adeudos condonados

**Descripción:** El usuario ingresa un número de contrato válido y un tipo de aseo existente, selecciona 'Periodo de Adeudo' y obtiene el reporte correctamente.

**Precondiciones:**
El contrato y tipo de aseo existen y tienen adeudos condonados (status 'S').

**Pasos a seguir:**
1. Ingresar el número de contrato '10001'.
2. Seleccionar tipo de aseo '001 - A - DOMICILIARIO'.
3. Seleccionar 'Periodo de Adeudo' como criterio de ordenamiento.
4. Hacer clic en 'Vista Previa'.

**Resultado esperado:**
Se muestra una tabla con los adeudos condonados del contrato, ordenados por periodo de pago.

**Datos de prueba:**
{ "num_contrato": 10001, "ctrol_aseo": 1, "opcion": 1 }

---

## Caso de Uso 2: Contrato inexistente

**Descripción:** El usuario ingresa un número de contrato que no existe en la base de datos.

**Precondiciones:**
El número de contrato no existe.

**Pasos a seguir:**
1. Ingresar el número de contrato '99999'.
2. Seleccionar cualquier tipo de aseo.
3. Hacer clic en 'Vista Previa'.

**Resultado esperado:**
Se muestra un mensaje de error: 'No existe el contrato o tipo de aseo seleccionado.'

**Datos de prueba:**
{ "num_contrato": 99999, "ctrol_aseo": 1 }

---

## Caso de Uso 3: Contrato sin adeudos condonados

**Descripción:** El usuario ingresa un contrato válido pero que no tiene adeudos condonados.

**Precondiciones:**
El contrato existe pero no tiene registros en ta_16_pagos con status_vigencia = 'S'.

**Pasos a seguir:**
1. Ingresar el número de contrato '10002'.
2. Seleccionar tipo de aseo '001 - A - DOMICILIARIO'.
3. Hacer clic en 'Vista Previa'.

**Resultado esperado:**
Se muestra un mensaje de error: 'No existen adeudos condonados para este contrato.'

**Datos de prueba:**
{ "num_contrato": 10002, "ctrol_aseo": 1 }

---



---
**Componente:** `Rep_AdeudCond.vue`
**MÃ³dulo:** `aseo_contratado`

