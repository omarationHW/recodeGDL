# Documentación: SdosFavor_Pagos

## Análisis Técnico

# Documentación Técnica: Migración Formulario SdosFavor_Pagos (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo permite la gestión de pagos a favor, migrando la funcionalidad de Delphi a una arquitectura moderna basada en Laravel (API), Vue.js (frontend) y PostgreSQL (base de datos). El formulario permite crear, consultar, actualizar, eliminar y listar pagos a favor.

## 2. Estructura de la Solución
- **Backend (Laravel):**
  - Un único endpoint `/api/execute` que recibe un objeto `eRequest` con la acción y los datos.
  - El controlador `SdosFavorPagosController` ejecuta la acción solicitada llamando a los stored procedures correspondientes en PostgreSQL.
- **Frontend (Vue.js):**
  - Componente de página independiente, con formulario para captura/edición y tabla de pagos registrados.
  - Navegación breadcrumb incluida.
- **Base de Datos (PostgreSQL):**
  - Tabla `sdosfavor_pagos` (debe existir con los campos: reca, caja, folio, importe, fecha).
  - Stored procedures para CRUD y catálogo.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "create|read|update|delete|list|find",
      "data": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": { ... } | [ ... ]
    }
  }
  ```

## 4. Stored Procedures
- **sp_sdosfavor_pagos_create:** Inserta un pago.
- **sp_sdosfavor_pagos_read:** Consulta un pago por clave.
- **sp_sdosfavor_pagos_update:** Actualiza un pago.
- **sp_sdosfavor_pagos_delete:** Elimina un pago.
- **sp_sdosfavor_pagos_list:** Lista todos los pagos.
- **sp_sdosfavor_pagos_find:** Busca un pago (igual que read, para compatibilidad).

## 5. Frontend (Vue.js)
- Formulario con campos: Rec. pago, Caja, Folio, Importe, Fecha Pago.
- Botón "Localizar Pago" para buscar por clave.
- Botón "Guardar" para crear/actualizar.
- Botón "Eliminar" para borrar el registro actual.
- Tabla con todos los pagos registrados.
- Mensajes de éxito/error.

## 6. Validaciones
- Todos los campos son obligatorios.
- Importe debe ser numérico y positivo.
- Fecha debe ser válida.

## 7. Consideraciones de Seguridad
- Validar y sanitizar todos los datos en backend.
- El endpoint debe estar protegido por autenticación (no incluido en este ejemplo).

## 8. Requisitos Previos
- Tabla `sdosfavor_pagos` creada en PostgreSQL:
  ```sql
  CREATE TABLE sdosfavor_pagos (
    reca VARCHAR(3) NOT NULL,
    caja VARCHAR(2) NOT NULL,
    folio VARCHAR(10) NOT NULL,
    importe NUMERIC(12,2) NOT NULL,
    fecha DATE NOT NULL,
    PRIMARY KEY (reca, caja, folio)
  );
  ```

## 9. Flujo de Uso
1. El usuario accede a la página de pagos a favor.
2. Puede crear un nuevo pago, localizar uno existente, editarlo o eliminarlo.
3. Todos los cambios se reflejan en la tabla inferior.

## 10. Extensibilidad
- Se pueden agregar filtros, paginación y búsqueda avanzada en el futuro.

## Casos de Uso

# Casos de Uso - SdosFavor_Pagos

**Categoría:** Form

## Caso de Uso 1: Registrar un nuevo pago a favor

**Descripción:** El usuario ingresa los datos de un nuevo pago y lo guarda.

**Precondiciones:**
No debe existir un pago con la misma combinación de reca, caja y folio.

**Pasos a seguir:**
[
  "Ingresar 'reca': '101'",
  "Ingresar 'caja': '01'",
  "Ingresar 'folio': '000123'",
  "Ingresar 'importe': '1500.00'",
  "Seleccionar 'fecha': '2024-06-10'",
  "Presionar 'Guardar'"
]

**Resultado esperado:**
El pago se registra correctamente y aparece en la tabla de pagos.

**Datos de prueba:**
{
  "reca": "101",
  "caja": "01",
  "folio": "000123",
  "importe": "1500.00",
  "fecha": "2024-06-10"
}

---

## Caso de Uso 2: Editar un pago existente

**Descripción:** El usuario localiza un pago existente, modifica el importe y guarda los cambios.

**Precondiciones:**
Debe existir un pago con reca='101', caja='01', folio='000123'.

**Pasos a seguir:**
[
  "Ingresar 'reca': '101'",
  "Ingresar 'caja': '01'",
  "Ingresar 'folio': '000123'",
  "Presionar 'Localizar Pago'",
  "Modificar 'importe' a '2000.00'",
  "Presionar 'Guardar'"
]

**Resultado esperado:**
El importe del pago se actualiza y se refleja en la tabla.

**Datos de prueba:**
{
  "reca": "101",
  "caja": "01",
  "folio": "000123",
  "importe": "2000.00",
  "fecha": "2024-06-10"
}

---

## Caso de Uso 3: Eliminar un pago a favor

**Descripción:** El usuario localiza un pago y lo elimina.

**Precondiciones:**
Debe existir un pago con reca='101', caja='01', folio='000123'.

**Pasos a seguir:**
[
  "Ingresar 'reca': '101'",
  "Ingresar 'caja': '01'",
  "Ingresar 'folio': '000123'",
  "Presionar 'Localizar Pago'",
  "Presionar 'Eliminar'",
  "Confirmar la eliminación"
]

**Resultado esperado:**
El pago se elimina y ya no aparece en la tabla.

**Datos de prueba:**
{
  "reca": "101",
  "caja": "01",
  "folio": "000123"
}

---

## Casos de Prueba

# Casos de Prueba para SdosFavor_Pagos

| Caso | Descripción | Datos de Entrada | Resultado Esperado |
|------|-------------|------------------|-------------------|
| 1 | Crear pago válido | reca: '101', caja: '01', folio: '000123', importe: '1500.00', fecha: '2024-06-10' | Pago creado, aparece en la lista |
| 2 | Crear pago duplicado | reca: '101', caja: '01', folio: '000123', importe: '1500.00', fecha: '2024-06-10' | Error: clave duplicada |
| 3 | Localizar pago existente | reca: '101', caja: '01', folio: '000123' | Pago localizado, datos mostrados |
| 4 | Localizar pago inexistente | reca: '999', caja: '99', folio: '999999' | Mensaje: Pago no encontrado |
| 5 | Editar importe de pago | reca: '101', caja: '01', folio: '000123', nuevo importe: '2000.00' | Importe actualizado |
| 6 | Eliminar pago existente | reca: '101', caja: '01', folio: '000123' | Pago eliminado, ya no aparece en la lista |
| 7 | Eliminar pago inexistente | reca: '999', caja: '99', folio: '999999' | Mensaje: Pago no encontrado |
| 8 | Crear pago con importe negativo | reca: '102', caja: '02', folio: '000124', importe: '-100.00', fecha: '2024-06-11' | Error: importe inválido |
| 9 | Crear pago con fecha inválida | reca: '103', caja: '03', folio: '000125', importe: '100.00', fecha: '2024-02-30' | Error: fecha inválida |
| 10 | Listar pagos | - | Lista de pagos mostrada correctamente |

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

