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
