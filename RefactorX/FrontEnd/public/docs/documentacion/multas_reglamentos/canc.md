# Documentación: canc

## Análisis Técnico

# Cancelación/Reasignación Masiva de Folios (Predial, Multas, Licencias, Anuncios, Diferencias)

## Descripción General
Este módulo permite la cancelación o reasignación masiva de folios de requerimientos (predial, multas, licencias, anuncios, diferencias de transmisión) en un rango determinado, así como la asignación de folios a ejecutores. Incluye:
- Búsqueda de folios en un rango y tipo.
- Cancelación masiva con motivo y usuario.
- Reasignación de ejecutor en masa.
- Asignación de folios a ejecutor.
- Consulta de ejecutores disponibles.

## Arquitectura
- **Backend**: Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Frontend**: Componente Vue.js como página independiente.
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures.
- **API**: Todas las operaciones se realizan vía POST a `/api/execute` con un objeto `eRequest`.

## Flujo de Trabajo
1. El usuario selecciona el tipo de requerimiento, recaudadora y rango de folios.
2. El sistema muestra los folios encontrados.
3. El usuario puede:
   - Cancelar todos los folios seleccionados (requiere motivo y usuario).
   - Reasignar los folios a otro ejecutor (requiere ejecutor actual, nuevo y fecha).
   - Asignar folios a ejecutor (requiere ejecutor y fecha).
4. El sistema ejecuta la acción solicitada y retorna el resultado.

## API (eRequest/eResponse)
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Body**:
  ```json
  {
    "eRequest": {
      "action": "buscarFolios|cancelarFolios|reasignarFolios|asignarFoliosEjecutor|consultarEjecutores",
      "params": { ... }
    }
  }
  ```
- **Respuesta**:
  ```json
  {
    "eResponse": {
      "status": "success|error",
      "message": "...",
      "data": { ... }
    }
  }
  ```

## Seguridad
- Todas las acciones requieren autenticación JWT o sesión Laravel.
- Los stored procedures validan los parámetros y sólo afectan los registros permitidos.

## Integración Vue.js
- Cada formulario es una página independiente.
- Navegación y breadcrumbs opcionales.
- No se usan tabs ni componentes tabulares.
- El componente consume la API y muestra mensajes de éxito/error.

## Consideraciones
- El endpoint es único y flexible para futuras acciones.
- Los stored procedures pueden ser extendidos para otros tipos de requerimientos.
- El frontend es desacoplado y puede ser reutilizado en otros módulos.

## Casos de Uso

> ⚠️ Pendiente de documentar

## Casos de Prueba

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

