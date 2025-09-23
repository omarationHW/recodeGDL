# Documentación Técnica: ActualizaCont (Migración Delphi → Laravel + Vue.js + PostgreSQL)

## Descripción General
Este módulo permite la actualización masiva de contratos de desarrollo social, migrando registros desde una tabla temporal (`ta_17_paso_cont`) hacia el catálogo principal de calles (`ta_17_calles`). Incluye la detección de diferencias, ejecución de la actualización y reporte de totales (adicionados, modificados, inconsistencias, descuentos).

## Arquitectura
- **Backend**: Laravel Controller (`ActualizaContController`) con endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Frontend**: Componente Vue.js de página completa, sin tabs, con navegación breadcrumb y dos paneles principales (diferencias y totales).
- **Base de Datos**: PostgreSQL, lógica encapsulada en stored procedures (`sp_get_diferencias_contratos`, `sp_actualiza_contratos`, `sp_totales_actualizacion`).

## API Unificada
- **Endpoint**: `POST /api/execute`
- **Request**:
  - `action`: string (ej: `getDiferencias`, `actualizarContratos`, `getTotalesActualizacion`)
  - `params`: objeto con parámetros específicos (ej: `{ user_id: 123 }`)
- **Response**:
  - `success`: boolean
  - `data`: array/objeto con resultados
  - `message`: string de error o información

## Stored Procedures
- `sp_get_diferencias_contratos()`: Devuelve diferencias entre contratos temporales y catálogo.
- `sp_actualiza_contratos(p_id_usuario)`: Ejecuta la actualización masiva, devuelve totales.
- `sp_totales_actualizacion(p_id_usuario)`: Devuelve los totales de la última ejecución (puede ser extendido para logs).

## Seguridad
- El endpoint requiere autenticación JWT o session para obtener el `user_id`.
- Todas las operaciones quedan registradas por usuario.

## Flujo de la Página
1. Al cargar, se muestran las diferencias actuales.
2. El usuario puede ejecutar la actualización masiva.
3. Se muestran los totales de la operación (adicionados, modificados, inconsistencias, descuentos).

## Integración
- El componente Vue.js utiliza Axios para consumir el endpoint `/api/execute`.
- El backend enruta todas las acciones a los stored procedures correspondientes.

## Consideraciones
- El proceso es idempotente: puede ejecutarse varias veces sin duplicar datos.
- El proceso de actualización es transaccional por registro (manejo de errores por inconsistencia).
- El frontend es responsivo y accesible.

## Extensión
- Se pueden agregar logs de auditoría por usuario y fecha.
- Puede integrarse con otros módulos de catálogo (colonias, calles, etc).
