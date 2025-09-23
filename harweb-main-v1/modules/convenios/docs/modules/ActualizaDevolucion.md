# Documentación Técnica: Actualización de Devoluciones de Pago

## Descripción General
Este módulo permite la carga masiva y actualización de devoluciones de pago asociadas a contratos/convenios. El proceso consiste en cargar un archivo de texto (pipe-separated), previsualizar los datos en una grilla y finalmente ejecutar la inserción masiva en la base de datos PostgreSQL, validando la existencia del contrato.

## Arquitectura
- **Frontend**: Vue.js SPA, página independiente `/actualiza-devolucion`
- **Backend**: Laravel Controller, endpoint único `/api/execute` (eRequest/eResponse)
- **Base de Datos**: PostgreSQL, lógica encapsulada en stored procedures

## Flujo de Trabajo
1. **Carga de Archivo**: El usuario selecciona un archivo de texto plano con datos de devoluciones (campos separados por '|').
2. **Previsualización**: El archivo se parsea y muestra en una tabla para revisión.
3. **Procesamiento**: Al confirmar, el sistema recorre cada fila, valida la existencia del contrato (colonia, calle, folio) y ejecuta el SP `sp_insert_devolucion`.
4. **Reporte de Errores**: Se reportan filas con errores (contrato no encontrado, columnas insuficientes, etc).

## API (Laravel)
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Formato**:
  - Entrada: `{ eRequest: { action: string, payload: any } }`
  - Salida: `{ eResponse: { success: bool, message: string, data: any } }`
- **Acciones soportadas**:
  - `uploadDevolucionFile`: Recibe archivo base64, lo parsea y devuelve grid.
  - `previewDevolucionGrid`: Recibe grid, lo devuelve para previsualización.
  - `processDevolucionGrid`: Recibe grid, procesa e inserta devoluciones usando SP.

## Stored Procedures
- `sp_insert_devolucion`: Inserta una devolución en `ta_17_devoluciones`.
- `sp_find_contrato_by_col_calle_fol`: Busca contrato por colonia, calle y folio.

## Validaciones
- El archivo debe tener al menos 15 columnas por fila.
- El contrato debe existir (colonia, calle, folio).
- Se reportan errores por fila.

## Seguridad
- El endpoint requiere autenticación (no mostrado aquí, pero debe implementarse en producción).
- El user_id se pasa en el payload y debe validarse contra la sesión.

## Consideraciones
- El proceso es transaccional: si ocurre un error, se hace rollback.
- El SP puede ser extendido para más validaciones o lógica de negocio.

## Integración
- El componente Vue puede ser integrado en cualquier SPA con Vue Router.
- El backend puede ser extendido para otros formularios similares.
