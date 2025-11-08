# Documentación Técnica: Módulo Recargos (Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
El módulo de Recargos permite la administración de los porcentajes de recargo por año y mes, usados para el cálculo de recargos en pagos atrasados. Incluye operaciones de alta, modificación, eliminación y consulta de recargos.

## 2. Arquitectura
- **Backend:** Laravel Controller con endpoint unificado `/api/execute` usando el patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js como página independiente, sin tabs.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "action": "recargos.list|recargos.create|recargos.update|recargos.delete",
      "params": { ... }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [ ... ],
      "message": ""
    }
  }
  ```

## 4. Stored Procedures
- `sp_recargos_list()`: Devuelve todos los recargos.
- `sp_recargos_create(axo, periodo, porcentaje, usuario_id)`: Inserta un nuevo recargo.
- `sp_recargos_update(axo, periodo, porcentaje, usuario_id)`: Actualiza un recargo existente.
- `sp_recargos_delete(axo, periodo)`: Elimina un recargo.

## 5. Validaciones
- Año (`axo`): Obligatorio, entero.
- Mes (`periodo`): Obligatorio, entero entre 1 y 12.
- Porcentaje: Obligatorio, numérico.
- Usuario: Obligatorio, entero.

## 6. Seguridad
- Todas las operaciones requieren autenticación (middleware Laravel recomendado).
- Validación de parámetros en backend.

## 7. Frontend
- Página Vue.js independiente.
- Tabla con listado de recargos.
- Modales para alta y edición.
- Acciones de editar y eliminar por fila.
- Navegación breadcrumb.

## 8. Consideraciones
- No se usan tabs ni componentes tabulares.
- El frontend consume el endpoint unificado.
- Los stored procedures encapsulan toda la lógica de acceso a datos.

## 9. Ejemplo de Request para Alta
```json
{
  "eRequest": {
    "action": "recargos.create",
    "params": {
      "axo": 2024,
      "periodo": 6,
      "porcentaje": 2.5,
      "usuario_id": 1
    }
  }
}
```

## 10. Ejemplo de Response
```json
{
  "eResponse": {
    "success": true,
    "data": null,
    "message": ""
  }
}
```
