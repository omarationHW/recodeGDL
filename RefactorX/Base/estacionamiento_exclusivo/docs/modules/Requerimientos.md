# Documentación Técnica: Migración Formulario Requerimientos (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend**: Laravel API RESTful, endpoint único `/api/execute`.
- **Frontend**: Vue.js SPA, cada formulario es una página independiente.
- **Base de Datos**: PostgreSQL, toda la lógica SQL encapsulada en stored procedures.
- **Comunicación**: El frontend envía un objeto `eRequest` con acción y parámetros; el backend responde con `eResponse`.

## 2. API Unificada
- **Endpoint**: `/api/execute` (POST)
- **Entrada**: `{ eRequest: { action: string, params: object } }`
- **Salida**: `{ eResponse: { success: bool, data: any, message: string } }`
- **Acciones soportadas**:
  - `getMercados`, `getSecciones`, `getTiposAseo`
  - `buscarMercadosAdeudos`, `buscarAseoAdeudos`
  - `emitirRequerimientosMercado`, `emitirRequerimientosAseo`
  - (Extensible para públicos, exclusivos, etc.)

## 3. Stored Procedures
- **Catálogos**: Devuelven listas para selects (mercados, secciones, tipos de aseo).
- **Reportes**: Devuelven resultados de búsqueda de adeudos según filtros.
- **Procesos**: Insertan registros de requerimientos y devuelven folios generados.
- **Secuencias**: Uso de secuencias PostgreSQL para folios (`seq_folio_requerimiento`).

## 4. Frontend (Vue.js)
- Cada formulario es una página Vue independiente, sin tabs.
- Navegación mediante breadcrumbs.
- Los filtros y resultados se adaptan dinámicamente según la aplicación seleccionada.
- Al emitir requerimientos, se muestra el resultado de la operación.

## 5. Seguridad
- Validación de parámetros en backend.
- El endpoint requiere autenticación (middleware Laravel, no mostrado aquí).
- Los stored procedures validan los parámetros críticos.

## 6. Extensibilidad
- Para agregar nuevas aplicaciones (públicos, exclusivos), crear nuevos SP y agregar acciones en el controlador y frontend.

## 7. Pruebas
- Casos de uso y pruebas automatizadas deben cubrir búsquedas, emisión y validaciones de errores.

## 8. Migración de Lógica
- La lógica de selección, agrupamiento y generación de folios del Delphi se trasladó a SPs y a la capa de Laravel.
- Los reportes impresos se generan desde el frontend o mediante endpoints adicionales (no incluidos).

## 9. Consideraciones
- El frontend asume que los catálogos y resultados tienen la estructura adecuada.
- El backend puede extenderse para soportar paginación y filtros avanzados.
