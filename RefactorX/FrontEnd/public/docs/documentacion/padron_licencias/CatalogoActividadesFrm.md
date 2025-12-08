# Documentación Técnica: CatalogoActividadesFrm

## Análisis Técnico

# Documentación Técnica: Catálogo de Actividades (Delphi → Laravel + Vue.js + PostgreSQL)

## Arquitectura General
- **Backend**: Laravel API, PostgreSQL, lógica de negocio en stored procedures.
- **Frontend**: Vue.js SPA, cada formulario es una página independiente.
- **API**: Único endpoint `/api/execute` que recibe `{ action, params }` y responde con `{ success, data, message }`.
- **Patrón**: eRequest/eResponse, desacoplando lógica de presentación y negocio.

## Endpoints y Acciones
- `/api/execute` (POST):
  - `action`: string, nombre de la acción (ej: `catalogo_actividades.list`)
  - `params`: objeto, parámetros requeridos por la acción

### Acciones soportadas
- `catalogo_actividades.list`: Listar actividades (filtro opcional por descripción)
- `catalogo_actividades.get`: Obtener actividad por ID
- `catalogo_actividades.create`: Crear nueva actividad
- `catalogo_actividades.update`: Actualizar actividad existente
- `catalogo_actividades.delete`: Baja lógica de actividad
- `catalogo_actividades.giros`: Listar giros vigentes

## Stored Procedures
- Toda la lógica de acceso y manipulación de datos reside en funciones/procedimientos almacenados en PostgreSQL.
- Se utiliza la extensión `unaccent` para búsquedas insensibles a acentos.
- Las bajas son lógicas (`vigente = 'C'`), nunca se borra físicamente.

## Seguridad
- El controlador asume autenticación previa (JWT/Sanctum).
- El usuario autenticado se utiliza para registrar acciones de alta, modificación y baja.

## Frontend (Vue.js)
- Página independiente, sin tabs ni componentes compartidos.
- CRUD completo: listar, buscar, agregar, editar, eliminar (baja lógica).
- Formulario modal para alta/edición.
- Validación básica en frontend y backend.
- Navegación breadcrumb.
- Tabla con acciones por registro.

## Integración
- El frontend consume el endpoint `/api/execute` con la acción y parámetros adecuados.
- El backend enruta la petición al stored procedure correspondiente y retorna el resultado.

## Consideraciones
- El campo `vigente` controla el estatus ('V' = Vigente, 'C' = Cancelado).
- El campo `id_giro` debe existir y estar vigente en la tabla de giros.
- Los campos de auditoría (`usuario_alta`, `usuario_baja`, etc.) se llenan automáticamente.
- El frontend muestra todos los campos relevantes y permite búsqueda por descripción.

# Diagrama de Flujo
1. Usuario accede a la página de Catálogo de Actividades.
2. Se cargan los giros vigentes y la lista de actividades.
3. El usuario puede buscar, agregar, editar o eliminar actividades.
4. Cada acción llama a `/api/execute` con la acción y parámetros adecuados.
5. El backend ejecuta el stored procedure y retorna el resultado.
6. El frontend actualiza la vista según la respuesta.

## Casos de Prueba

# Casos de Prueba: Catálogo de Actividades

## Caso 1: Alta de actividad válida
- **Entrada:** id_giro=1001, descripcion="Venta de alimentos preparados", observaciones="Incluye restaurantes y fondas", vigente="V"
- **Acción:** catalogo_actividades.create
- **Esperado:** Código 200, success=true, data contiene id_actividad nuevo, la actividad aparece en la lista.

## Caso 2: Alta con descripción vacía
- **Entrada:** id_giro=1001, descripcion="", observaciones="", vigente="V"
- **Acción:** catalogo_actividades.create
- **Esperado:** Código 200, success=false, message indica error de validación.

## Caso 3: Edición de actividad existente
- **Entrada:** id=5, id_giro=1001, descripcion="Venta de alimentos y bebidas", observaciones="Incluye restaurantes, bares y fondas", vigente="V"
- **Acción:** catalogo_actividades.update
- **Esperado:** Código 200, success=true, data contiene id_actividad=5, cambios reflejados en la lista.

## Caso 4: Baja lógica de actividad
- **Entrada:** id=7, motivo_baja="Actividad obsoleta"
- **Acción:** catalogo_actividades.delete
- **Esperado:** Código 200, success=true, data contiene id_actividad=7, la actividad aparece como 'Cancelado'.

## Caso 5: Listado filtrado por descripción
- **Entrada:** descripcion="alimentos"
- **Acción:** catalogo_actividades.list
- **Esperado:** Código 200, success=true, data contiene solo actividades con "alimentos" en la descripción.

## Caso 6: Obtener giros vigentes
- **Entrada:** (sin parámetros)
- **Acción:** catalogo_actividades.giros
- **Esperado:** Código 200, success=true, data contiene lista de giros vigentes.

## Casos de Uso

# Casos de Uso - CatalogoActividadesFrm

**Categoría:** Form

## Caso de Uso 1: Agregar una nueva actividad al catálogo

**Descripción:** El usuario desea registrar una nueva actividad asociada a un giro existente.

**Precondiciones:**
El usuario está autenticado y tiene permisos de edición. Existen giros vigentes en el sistema.

**Pasos a seguir:**
- El usuario accede a la página de Catálogo de Actividades.
- Da clic en 'Agregar Actividad'.
- Llena el formulario: selecciona un giro, escribe la descripción y observaciones, selecciona 'Vigente'.
- Da clic en 'Guardar'.
- El sistema envía la petición a `/api/execute` con acción `catalogo_actividades.create` y los datos del formulario.

**Resultado esperado:**
La actividad se registra correctamente, aparece en la lista y muestra mensaje de éxito.

**Datos de prueba:**
{
  "id_giro": 1001,
  "descripcion": "Venta de alimentos preparados",
  "observaciones": "Incluye restaurantes y fondas",
  "vigente": "V"
}

---

## Caso de Uso 2: Editar una actividad existente

**Descripción:** El usuario necesita corregir la descripción de una actividad ya registrada.

**Precondiciones:**
El usuario está autenticado y tiene permisos de edición. La actividad existe y está vigente.

**Pasos a seguir:**
- El usuario busca la actividad por descripción.
- Da clic en 'Editar' en la fila correspondiente.
- Modifica la descripción y observaciones.
- Da clic en 'Guardar'.
- El sistema envía la petición a `/api/execute` con acción `catalogo_actividades.update` y los datos modificados.

**Resultado esperado:**
La actividad se actualiza correctamente y la lista refleja los cambios.

**Datos de prueba:**
{
  "id": 5,
  "id_giro": 1001,
  "descripcion": "Venta de alimentos y bebidas",
  "observaciones": "Incluye restaurantes, bares y fondas",
  "vigente": "V"
}

---

## Caso de Uso 3: Eliminar (cancelar) una actividad

**Descripción:** El usuario desea dar de baja una actividad que ya no debe estar disponible.

**Precondiciones:**
El usuario está autenticado y tiene permisos de edición. La actividad existe y está vigente.

**Pasos a seguir:**
- El usuario localiza la actividad en la lista.
- Da clic en 'Eliminar'.
- Confirma la acción.
- El sistema envía la petición a `/api/execute` con acción `catalogo_actividades.delete` y el ID de la actividad.

**Resultado esperado:**
La actividad cambia su estatus a 'Cancelado' y ya no puede ser editada ni eliminada nuevamente.

**Datos de prueba:**
{
  "id": 7,
  "motivo_baja": "Actividad obsoleta"
}

---

