# Documentación Técnica - Catálogo de Etiquetas

## Descripción General
Este módulo permite la consulta y edición de las etiquetas asociadas a cada tabla de rubros (t34_tablas) en el sistema. Cada etiqueta define los nombres y leyendas que se muestran en los formularios y reportes para cada tipo de rubro (ejemplo: Rastro, Juegos Mecánicos, etc).

La migración Delphi → Laravel + Vue.js + PostgreSQL implementa:
- Un endpoint API unificado `/api/execute` que recibe peticiones eRequest/eResponse.
- Un procedimiento almacenado para la actualización de etiquetas.
- Un componente Vue.js como página independiente para la edición de etiquetas.

## Arquitectura
- **Backend:** Laravel Controller (`EtiquetasController`) con endpoint `/api/execute`.
- **Frontend:** Componente Vue.js (`EtiquetasPage.vue`) como página completa.
- **Base de Datos:** PostgreSQL con stored procedure `sp_update_t34_etiq`.

## API (eRequest/eResponse)
- **Endpoint:** `POST /api/execute`
- **Body:**
  ```json
  {
    "action": "get_tablas|get_etiquetas|update_etiquetas",
    "params": { ... }
  }
  ```
- **Acciones soportadas:**
  - `get_tablas`: Devuelve todas las tablas activas.
  - `get_etiquetas`: Devuelve las etiquetas de una tabla (`cve_tab`).
  - `update_etiquetas`: Actualiza los campos de etiquetas para una tabla.
- **Respuesta:**
  ```json
  {
    "success": true|false,
    "data": [ ... ],
    "message": "..."
  }
  ```

## Stored Procedure
- **sp_update_t34_etiq**: Actualiza todos los campos de la tabla `t34_etiq` para una clave de tabla específica.

## Frontend
- Página Vue.js independiente.
- Selección de tabla (combo).
- Formulario editable con todos los campos de etiquetas.
- Botón "Actualizar" solo habilitado si existe registro.
- Mensajes de éxito/error.

## Seguridad
- Validación de parámetros en backend.
- Solo permite actualizar etiquetas existentes.

## Flujo de trabajo
1. El usuario selecciona una tabla.
2. El sistema carga las etiquetas actuales.
3. El usuario edita y guarda los cambios.
4. El backend ejecuta el stored procedure y responde.

# Esquema de Base de Datos
- **t34_tablas**: Catálogo de rubros.
- **t34_etiq**: Etiquetas asociadas a cada rubro (`cve_tab`).

# Consideraciones
- Todos los campos de etiquetas son de tipo texto.
- El procedimiento almacenado es idempotente: solo actualiza, no inserta ni elimina.
- El endpoint es unificado para facilitar integración y pruebas.
