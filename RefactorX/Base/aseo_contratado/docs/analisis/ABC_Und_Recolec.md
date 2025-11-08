# Documentación Técnica: Migración de Formulario ABC_Und_Recolec (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel API con endpoint unificado `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`.
- **Frontend**: Vue.js SPA, cada formulario es una página independiente (no tabs), con navegación y breadcrumbs.
- **Base de Datos**: PostgreSQL, lógica de negocio encapsulada en stored procedures.

## API Unificada
- **Endpoint**: `/api/execute` (POST)
- **Entrada**: `{ "eRequest": { "action": "list|create|update|delete", "entity": "unidades_recoleccion", "params": { ... } } }`
- **Salida**: `{ "eResponse": [ ... ] }` (array de resultados o error)

## Controlador Laravel
- Un solo controlador (`ExecuteController`) maneja todas las acciones CRUD para el catálogo de Unidades de Recolección.
- Llama a los stored procedures de PostgreSQL según la acción y entidad.
- Valida parámetros y retorna errores amigables.

## Componente Vue.js
- Página completa para el catálogo de Unidades de Recolección.
- Tabla con listado, botones para crear, editar y eliminar.
- Formularios modales para alta y edición.
- Llama al endpoint `/api/execute` usando fetch/AJAX.
- Maneja errores y muestra mensajes amigables.

## Stored Procedures PostgreSQL
- Toda la lógica de negocio (altas, bajas, cambios, consultas) está en SPs.
- Validaciones de unicidad y restricciones de integridad.
- Devuelven mensajes de error o éxito en formato estándar.

## Seguridad
- Se recomienda proteger el endpoint con autenticación JWT o similar.
- Validar que el usuario tenga permisos para cada acción.

## Nombres de Campos
- `ctrol_recolec`: Identificador único de la unidad.
- `ejercicio_recolec`: Año/ejericio fiscal.
- `cve_recolec`: Clave corta (1 carácter).
- `descripcion`: Descripción textual.
- `costo_unidad`: Costo por unidad.
- `costo_exed`: Costo por excedente.

## Flujo de Trabajo
1. El usuario accede a la página de Unidades de Recolección.
2. El frontend solicita la lista para el ejercicio actual.
3. El usuario puede agregar, editar o eliminar unidades.
4. Cada acción llama al endpoint `/api/execute` con la acción y parámetros.
5. El backend ejecuta el SP correspondiente y retorna el resultado.

## Manejo de Errores
- Si se intenta crear una clave duplicada, el SP retorna `error: clave ya existe`.
- Si se intenta eliminar una unidad referenciada, retorna `error: existen contratos con esta unidad`.
- Todos los errores se muestran en el frontend.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar más entidades y acciones fácilmente.
- Los SPs pueden evolucionar sin cambiar el frontend.
