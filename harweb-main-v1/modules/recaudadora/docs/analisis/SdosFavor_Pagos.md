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
