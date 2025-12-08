# DocumentaciÃ³n TÃ©cnica: Pagos_Cons_Cont

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Pagos_Cons_Cont (Migración Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo permite consultar los pagos realizados por contrato y tipo de aseo. El usuario ingresa el número de contrato y selecciona el tipo de aseo; el sistema muestra todos los pagos asociados con status 'P' (pagado) y permite descargar el estado de cuenta en PDF.

## 2. Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Componente Vue.js de página completa, sin tabs, con navegación breadcrumb
- **Base de Datos:** PostgreSQL, lógica SQL en stored procedures
- **API:** Todas las operaciones se realizan mediante el endpoint `/api/execute`

## 3. Flujo de Datos
1. El usuario accede a la página de consulta de pagos.
2. El frontend solicita la lista de tipos de aseo (`getTipoAseo`).
3. El usuario ingresa el número de contrato y selecciona el tipo de aseo.
4. El frontend solicita la existencia del contrato (`buscarContrato`).
5. Si existe, solicita los pagos asociados (`buscarPagos`).
6. El usuario puede descargar el Edo. de Cuenta en PDF (`edoCuentaPDF`).

## 4. API Detalle
### Endpoint
- **POST** `/api/execute`

#### Request
```json
{
  "action": "buscarPagos",
  "params": {
    "control_contrato": 1234
  }
}
```

#### Response
```json
{
  "success": true,
  "data": [ ... ],
  "message": ""
}
```

### Acciones soportadas
- `getTipoAseo`: Lista de tipos de aseo
- `buscarContrato`: Busca contrato por número y tipo de aseo
- `buscarPagos`: Lista pagos de un contrato
- `edoCuentaPDF`: Genera y retorna URL/base64 del Edo. de Cuenta

## 5. Stored Procedures
- `sp_pagos_cons_cont_buscar_pagos`: Devuelve pagos de un contrato
- `sp_pagos_cons_cont_edocuenta`: Genera Edo. de Cuenta (simulado)

## 6. Seguridad
- Validación de parámetros en backend
- El endpoint debe estar protegido por autenticación (middleware Laravel)

## 7. Consideraciones de Migración
- Los combos Delphi se migran a selects Vue.js
- El grid Delphi se migra a tabla HTML
- El botón de Edo. de Cuenta llama al SP que retorna la URL del PDF
- El SP de Edo. de Cuenta debe integrarse con el sistema de reportes real (no incluido aquí)

## 8. Errores y Mensajes
- Si no existe el contrato, se muestra mensaje de error
- Si no hay pagos, se muestra mensaje adecuado

## 9. Extensibilidad
- El endpoint puede extenderse para otras acciones relacionadas con pagos y contratos

## 10. Pruebas
- Ver sección de Casos de Uso y Casos de Prueba


## Casos de Prueba

# Casos de Prueba: Pagos_Cons_Cont

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|--------------------|
| TC1  | Consulta exitosa de pagos | contrato=1803, ctrol_aseo=8 | Tabla con pagos, sin errores |
| TC2  | Contrato inexistente | contrato=999999, ctrol_aseo=8 | Mensaje de error: 'No existe contrato, intenta con otro.' |
| TC3  | Descarga de Edo. de Cuenta | contrato=1803, ctrol_aseo=8 | Se abre PDF del Edo. de Cuenta |
| TC4  | Validación de campos vacíos | contrato='', ctrol_aseo='' | Mensaje de error de campos requeridos |
| TC5  | Contrato sin pagos | contrato=1234, ctrol_aseo=8 (sin pagos 'P') | Mensaje: 'No existen pagos para este contrato.' |


## Casos de Uso

# Casos de Uso - Pagos_Cons_Cont

**Categoría:** Form

## Caso de Uso 1: Consulta de pagos de un contrato existente

**Descripción:** El usuario consulta los pagos realizados para un contrato y tipo de aseo válidos.

**Precondiciones:**
El contrato y tipo de aseo existen y tienen pagos con status 'P'.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta de Pagos por Contrato.
2. Ingresa el número de contrato (ej: 1803).
3. Selecciona el tipo de aseo correspondiente (ej: 8 - Ordinario).
4. Presiona el botón 'Buscar'.
5. El sistema muestra la lista de pagos asociados.

**Resultado esperado:**
Se muestra una tabla con los pagos del contrato, incluyendo periodo, operación, importe, status, fecha de pago, etc.

**Datos de prueba:**
contrato: 1803, ctrol_aseo: 8

---

## Caso de Uso 2: Intento de consulta con contrato inexistente

**Descripción:** El usuario intenta consultar pagos para un contrato que no existe.

**Precondiciones:**
El número de contrato no existe en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página.
2. Ingresa un número de contrato inexistente (ej: 999999).
3. Selecciona cualquier tipo de aseo.
4. Presiona 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de error: 'No existe contrato, intenta con otro.'

**Datos de prueba:**
contrato: 999999, ctrol_aseo: 8

---

## Caso de Uso 3: Descarga de Edo. de Cuenta en PDF

**Descripción:** El usuario descarga el estado de cuenta en PDF para un contrato válido.

**Precondiciones:**
El contrato existe y tiene pagos.

**Pasos a seguir:**
1. El usuario realiza una búsqueda exitosa de pagos.
2. Presiona el botón 'Edo. de Cuenta'.
3. El sistema genera el PDF y lo muestra/descarga.

**Resultado esperado:**
Se abre el PDF del Edo. de Cuenta en una nueva ventana/pestaña.

**Datos de prueba:**
contrato: 1803, ctrol_aseo: 8

---



---
**Componente:** `Pagos_Cons_Cont.vue`
**MÃ³dulo:** `aseo_contratado`

