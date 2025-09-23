# Documentación Técnica: Migración FrmEje Delphi a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+, PostgreSQL 13+
- **Frontend:** Vue.js 3 SPA (Single Page Application)
- **API:** Endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Stored Procedures:** Toda la lógica SQL relevante migrada a funciones/procedimientos en PostgreSQL
- **Autenticación:** Laravel Sanctum/JWT (no detallado aquí)

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "nombreAccion",
      "params": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "status": "ok|error|not_found",
      "data": { ... },
      "message": "..."
    }
  }
  ```

## Acciones soportadas (FrmEje)
- `listEjecutores`: Lista todos los ejecutores vigentes
- `getEjecutor`: Obtiene un ejecutor por ID
- `createEjecutor`: Crea un nuevo ejecutor
- `updateEjecutor`: Actualiza un ejecutor existente
- `deleteEjecutor`: Baja lógica de ejecutor
- `reportEjecutores`: Reporte filtrado por fechas y recaudadora

## Stored Procedures
- **sp_eje_create:** Inserta un ejecutor
- **sp_eje_update:** Actualiza un ejecutor
- **sp_eje_delete:** Baja lógica
- **sp_eje_report:** Reporte filtrado

## Frontend (Vue.js)
- Página independiente `/ejecutores` (NO tabs)
- Tabla de ejecutores, formulario de alta/edición, reporte
- Navegación breadcrumb
- Manejo de errores y mensajes
- Llama a `/api/execute` con eRequest

## Validaciones
- Todos los campos requeridos en alta/edición
- RFC formato válido (no detallado aquí)
- Fechas válidas
- No se permite eliminar ejecutores con trabajo pendiente (lógica a implementar en SP si aplica)

## Seguridad
- Todas las acciones requieren autenticación
- Los stored procedures validan parámetros y retornan error si falta algún dato

## Migración de Datos
- Se recomienda migrar la tabla `ejecutores` de Paradox/Interbase a PostgreSQL con los mismos campos
- Revisar tipos de datos y normalización

## Pruebas
- Se proveen casos de uso y escenarios de prueba abajo

