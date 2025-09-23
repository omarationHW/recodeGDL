# Documentación Técnica: Reasignación de Ejecutor

## Descripción General
Este módulo permite la reasignación masiva de folios (ta_15_apremios) a un nuevo ejecutor, actualizando la fecha de entrega y el usuario responsable. Incluye:
- Listado de ejecutores activos
- Búsqueda de folios por rango y módulo
- Selección múltiple de folios para reasignar
- Ejecución de la reasignación en lote

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Componente Vue.js de página completa, sin tabs
- **Base de Datos:** PostgreSQL con stored procedures para lógica de negocio

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "listar_ejecutores|buscar_folios|reasignar_folios",
      ... parámetros ...
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": ...
    }
  }
  ```

## Stored Procedures
- `sp_listar_ejecutores(p_id_rec_min, p_id_rec_max)`
- `sp_buscar_folios(p_zona, p_modulo, p_folio1, p_folio2, p_vigencia)`
- `sp_reasignar_folio(p_id_control, p_nuevo_ejecutor, p_fecha_entrega2, p_usuario, p_fecha_actualiz)`

## Seguridad
- Todas las operaciones deben ser autenticadas (middleware Laravel Auth recomendado)
- Validar que el usuario tenga permisos para reasignar folios

## Manejo de Errores
- Todas las respuestas de error deben ir en el campo `message` de `eResponse`
- Las transacciones de reasignación son atómicas (rollback en error)

## Flujo de la Página Vue
1. El usuario selecciona rango de folios, recaudadora y módulo
2. Se listan los folios encontrados
3. El usuario selecciona uno o varios folios
4. Selecciona el nuevo ejecutor y la fecha de entrega
5. Confirma la reasignación
6. El sistema actualiza los folios y muestra mensaje de éxito

## Consideraciones
- El frontend debe mostrar mensajes claros de validación y error
- El backend debe registrar todas las reasignaciones (auditoría recomendada)

## Ejemplo de Llamada para Reasignación
```json
{
  "eRequest": {
    "action": "reasignar_folios",
    "folios": [123, 124, 125],
    "nuevo_ejecutor": 45,
    "fecha_entrega2": "2024-06-10",
    "usuario": 1,
    "fecha_actualiz": "2024-06-10"
  }
}
```

## Ejemplo de Respuesta
```json
{
  "eResponse": {
    "success": true,
    "message": "Folios reasignados correctamente",
    "data": [
      {"id_control": 123, "result": "OK"},
      {"id_control": 124, "result": "OK"},
      {"id_control": 125, "result": "OK"}
    ]
  }
}
```
