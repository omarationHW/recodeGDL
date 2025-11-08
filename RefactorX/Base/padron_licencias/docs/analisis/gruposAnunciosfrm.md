# Documentación Técnica: Migración de Formulario Grupos de Anuncios (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js (SPA, cada formulario es una página independiente)
- **Base de Datos:** PostgreSQL (toda la lógica SQL encapsulada en stored procedures)
- **Patrón de Comunicación:** eRequest/eResponse (el frontend envía un objeto `eRequest` y parámetros a `/api/execute`, el backend responde con `eResponse`)

## Endpoints
- **POST /api/execute**
  - **Body:** `{ eRequest: string, params: object }`
  - **Respuesta:** `{ eResponse: { success: bool, data: any, message: string } }`

## Stored Procedures
- Toda la lógica de consulta, inserción, actualización y proceso de grupos de anuncios y licencias está en funciones de PostgreSQL.
- Las funciones reciben parámetros y devuelven tablas (TABLE) para facilitar la integración con Laravel.
- Las funciones para agregar/quitar anuncios de grupos reciben un array en formato JSON.

## Controlador Laravel
- Un solo controlador (`ExecuteController`) con método `execute`.
- El método interpreta el `eRequest` y llama al stored procedure correspondiente, pasando los parámetros recibidos.
- Maneja errores y devuelve la respuesta en el formato `eResponse`.

## Componente Vue.js
- Página independiente para Grupos de Anuncios.
- Permite buscar, agregar, editar grupos.
- Permite ver anuncios disponibles y en grupo, filtrar, agregar y quitar anuncios del grupo.
- Usa tablas simples y modales para edición/agregado.
- Navegación breadcrumb incluida.
- Llama al endpoint `/api/execute` con el `eRequest` adecuado.

## Seguridad
- Se recomienda proteger el endpoint `/api/execute` con autenticación (no incluido en este ejemplo).
- Validar los parámetros en el backend antes de ejecutar los stored procedures.

## Consideraciones
- El frontend espera que los stored procedures devuelvan los datos en formato tabla.
- Los arrays de anuncios se envían como JSON.
- El filtrado es insensible a mayúsculas/minúsculas (ILIKE).

## Extensibilidad
- Para agregar nuevos formularios, crear nuevos stored procedures y agregar casos en el controlador y el frontend.

## Pruebas
- Se recomienda usar los casos de uso y prueba incluidos para validar la funcionalidad.
