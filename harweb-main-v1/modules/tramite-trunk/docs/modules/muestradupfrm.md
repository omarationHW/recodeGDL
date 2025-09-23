# Documentación Técnica: Migración Formulario muestradupfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel Controller con endpoint único `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`.
- **Frontend**: Componente Vue.js de página completa, sin tabs, con navegación y acciones independientes.
- **Base de Datos**: PostgreSQL, toda la lógica de negocio y validación crítica se implementa en stored procedures (SPs).
- **API Unificada**: Todas las operaciones (listado, detalle, creación, actualización, borrado, integración, reporte) se realizan a través del endpoint `/api/execute` usando el patrón eRequest/eResponse.

## Flujo de Datos
1. **El usuario ingresa la clave catastral del condominio** y solicita la búsqueda de cuentas duplicadas.
2. **El frontend Vue.js** envía una petición POST a `/api/execute` con `{ eRequest: { action: 'list', params: { cvecond } } }`.
3. **El backend Laravel** recibe la petición, despacha la acción al SP correspondiente y retorna el resultado en `eResponse`.
4. **El usuario puede ver detalles, eliminar cuentas duplicadas o aplicar la integración** (proceso de cierre de subpredios).

## Estructura de la Tabla Principal
- **cuentas_duplicadas**
  - cvecond (int)
  - cvecuenta (int, PK)
  - recaud (int)
  - urbrus (varchar)
  - cuenta (int)
  - subpredio (int)
  - indiviso (numeric)
  - estado (varchar, N/M/R/D)
  - fecha (timestamp)
  - usuario (varchar)

- **condominios**
  - cvecond (int, PK)
  - numpred (int)
  - fecha_verificado (timestamp)
  - usr_verificado (varchar)
  - ...otros campos...

## Stored Procedures
- **sp_muestradup_list**: Lista cuentas duplicadas de un condominio.
- **sp_muestradup_show**: Devuelve detalle de una cuenta duplicada.
- **sp_muestradup_create**: Inserta una cuenta duplicada (para pruebas/migración).
- **sp_muestradup_update**: Actualiza estado de una cuenta duplicada.
- **sp_muestradup_delete**: Marca como eliminada una cuenta duplicada.
- **sp_muestradup_report**: Reporte de cuentas duplicadas.
- **sp_muestradup_integrate**: Aplica integración de subpredios (validaciones y cierre).

## API Unificada
- **Endpoint**: `/api/execute`
- **Entrada**: `{ eRequest: { action: 'list'|'show'|'create'|'update'|'delete'|'report'|'process', params: { ... } } }`
- **Salida**: `{ eResponse: { success: bool, message: string, data: any } }`

## Seguridad
- Todas las acciones requieren autenticación (middleware Laravel, no mostrado aquí).
- El usuario que realiza la integración queda registrado en `usr_verificado`.

## Validaciones Críticas
- No se puede aplicar integración si:
  - Hay subpredios duplicados.
  - El número de subpredios no coincide con el número de predios.
  - La suma de indivisos no es 100%.
- Los SPs devuelven mensajes de error claros para el frontend.

## Navegación Frontend
- Página Vue.js independiente para el formulario de duplicados.
- Breadcrumb para navegación.
- Acciones: buscar, ver detalle, eliminar, aplicar integración.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin cambiar la estructura del endpoint.
- Los SPs pueden ser versionados y auditados en la base de datos.

## Pruebas
- Casos de uso y pruebas detallados en las siguientes secciones.
