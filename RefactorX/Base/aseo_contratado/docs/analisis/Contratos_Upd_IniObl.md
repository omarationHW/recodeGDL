# Documentación Técnica: Migración Formulario Contratos_Upd_IniObl (Delphi) a Laravel + Vue.js + PostgreSQL

## Descripción General
Este módulo permite actualizar el periodo de inicio de obligación de un contrato vigente, eliminando pagos anteriores, generando nuevos pagos a partir del periodo seleccionado y registrando el documento probatorio del cambio. La solución implementa:

- **Backend**: Laravel Controller con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend**: Componente Vue.js como página independiente.
- **Base de Datos**: Stored Procedure en PostgreSQL para la lógica de negocio.

## API
### Endpoint
`POST /api/execute`

#### Entrada (eRequest)
- `action`: `catalogs` | `search` | `update` | `validate`
- Parámetros según acción:
  - `catalogs`: sin parámetros
  - `search`: `{ num_contrato, ctrol_aseo }`
  - `update`: `{ num_contrato, ctrol_aseo, ejercicio, mes, documento, descripcion_docto, usuario_id }`
  - `validate`: igual a update

#### Salida (eResponse)
- `success`: boolean
- `message`: string
- `data`: objeto o null

## Stored Procedure
- `sp16_update_inicio_obligacion`: realiza toda la lógica de actualización de inicio de obligación, pagos y registro de documento.

## Frontend
- Página Vue.js independiente, sin tabs, con búsqueda de contrato y formulario de actualización.
- Navegación simple, mensajes de éxito/error.

## Seguridad
- El endpoint requiere autenticación (no implementada aquí, pero debe integrarse en producción).
- Validación de parámetros en backend y frontend.

## Flujo de Trabajo
1. Usuario ingresa número de contrato y tipo de aseo, busca contrato.
2. Si existe y está vigente, se muestran los datos.
3. Usuario selecciona nuevo ejercicio y mes de inicio de obligación, documento y descripción.
4. Al enviar, se ejecuta el stored procedure que:
   - Elimina pagos anteriores al periodo.
   - Inserta pagos del periodo en adelante (año actual y siguiente si aplica).
   - Actualiza el campo `aso_mes_oblig` del contrato.
   - Registra el documento probatorio.
5. Se muestra mensaje de éxito o error.

## Validaciones
- No permite actualizar si el contrato no existe o no está vigente.
- No permite si la fecha de inicio de obligación es igual a la actual.
- No permite si faltan campos obligatorios.

## Integración
- El frontend llama al endpoint `/api/execute` con la acción correspondiente.
- El backend enruta la acción y ejecuta la lógica o el stored procedure.
- El stored procedure realiza toda la lógica transaccional y retorna el resultado.

## Consideraciones
- El usuario debe tener permisos para actualizar contratos.
- El proceso es atómico: si falla algo, no se realizan cambios parciales.
- El frontend debe mostrar mensajes claros según el resultado.

#