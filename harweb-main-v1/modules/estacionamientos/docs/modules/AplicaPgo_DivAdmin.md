# Documentación Técnica: Migración de Formulario AplicaPgo_DivAdmin

## 1. Descripción General
Este módulo permite buscar folios de adeudo por diferentes criterios y aplicar pagos de "Diversos Admin" sobre los folios seleccionados. La migración incluye:
- Backend Laravel con endpoint unificado `/api/execute` (patrón eRequest/eResponse)
- Stored Procedures en PostgreSQL para lógica de negocio
- Frontend Vue.js como página independiente

## 2. Arquitectura
- **Backend**: Laravel Controller `ExecuteController` maneja todas las acciones vía un endpoint único, despachando según el campo `action` de `eRequest`.
- **Frontend**: Componente Vue.js de página completa, sin tabs, con navegación breadcrumb.
- **Base de Datos**: PostgreSQL, con stored procedures para búsqueda y aplicación de pagos.

## 3. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Entrada**: JSON con campo `eRequest`:
  - `action`: (string) Acción a ejecutar (`getRecaudadoras`, `buscarFolios`, `aplicarPagosDiversosAdmin`)
  - `params`: (object) Parámetros requeridos por la acción
- **Salida**: JSON con campo `eResponse`:
  - `success`: (bool)
  - `data`: (array/object)
  - `message`: (string)

## 4. Stored Procedures
- `sp_busca_folios_divadmin`: Devuelve los folios según criterio de búsqueda
- `sp_aplica_pago_divadmin`: Aplica el pago a un folio específico

## 5. Flujo de Usuario
1. Selecciona criterio de búsqueda (placa, placa+folio, año+folio)
2. Ingresa datos y busca folios
3. Selecciona uno o varios folios
4. Hace clic en "Aplicar Pago Diversos"
5. Ingresa datos de pago (fecha, recaudadora, caja, operación)
6. Confirma y aplica el pago
7. El sistema muestra mensaje de éxito o error

## 6. Seguridad
- Validar que el usuario esté autenticado (no implementado en ejemplo, agregar según sistema)
- Validar datos de entrada en backend

## 7. Consideraciones
- El usuario debe tener permisos para aplicar pagos
- El proceso es transaccional: si falla un pago, se revierte todo
- Los stored procedures pueden adaptarse según reglas de negocio reales

## 8. Extensibilidad
- Se pueden agregar más acciones al endpoint `/api/execute` siguiendo el patrón eRequest/eResponse
- El frontend puede ser extendido fácilmente para otros formularios similares
