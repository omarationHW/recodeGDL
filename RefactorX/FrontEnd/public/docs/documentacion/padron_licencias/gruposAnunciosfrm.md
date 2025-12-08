# Documentación Técnica: gruposAnunciosfrm

## Análisis Técnico

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

## Casos de Uso

# Casos de Uso - gruposAnunciosfrm

**Categoría:** Form

## Caso de Uso 1: Agregar un nuevo grupo de anuncios y asociar anuncios

**Descripción:** El usuario crea un nuevo grupo de anuncios y agrega anuncios disponibles al grupo.

**Precondiciones:**
El usuario tiene acceso a la página de Grupos de Anuncios.

**Pasos a seguir:**
1. El usuario ingresa la descripción del nuevo grupo y hace clic en 'Agregar Grupo'.
2. El grupo aparece en la lista.
3. El usuario selecciona el grupo recién creado.
4. El usuario filtra los anuncios disponibles por giro o propietario.
5. El usuario selecciona varios anuncios y hace clic en 'Agregar a Grupo'.

**Resultado esperado:**
El grupo se crea y los anuncios seleccionados quedan asociados al grupo. Los anuncios ya no aparecen en la lista de disponibles.

**Datos de prueba:**
Descripción del grupo: 'GRUPO PRUEBA 1'. Anuncios a asociar: [1001, 1002, 1003].

---

## Caso de Uso 2: Quitar anuncios de un grupo existente

**Descripción:** El usuario elimina anuncios de un grupo de anuncios existente.

**Precondiciones:**
Existe al menos un grupo con anuncios asociados.

**Pasos a seguir:**
1. El usuario selecciona un grupo existente.
2. El usuario filtra los anuncios en el grupo si lo desea.
3. El usuario selecciona uno o más anuncios y hace clic en 'Quitar de Grupo'.

**Resultado esperado:**
Los anuncios seleccionados se eliminan del grupo y aparecen nuevamente en la lista de anuncios disponibles.

**Datos de prueba:**
Grupo: 'GRUPO PRUEBA 1'. Anuncios a quitar: [1002].

---

## Caso de Uso 3: Editar la descripción de un grupo de anuncios

**Descripción:** El usuario edita la descripción de un grupo de anuncios.

**Precondiciones:**
Existe al menos un grupo de anuncios.

**Pasos a seguir:**
1. El usuario hace clic en 'Editar' en el grupo deseado.
2. El usuario modifica la descripción y guarda los cambios.

**Resultado esperado:**
La descripción del grupo se actualiza correctamente en la base de datos y en la interfaz.

**Datos de prueba:**
Grupo original: 'GRUPO PRUEBA 1'. Nueva descripción: 'GRUPO PRUEBA EDITADO'.

---
