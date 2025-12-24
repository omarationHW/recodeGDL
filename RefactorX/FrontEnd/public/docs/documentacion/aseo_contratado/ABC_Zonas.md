# DocumentaciÃ³n TÃ©cnica: ABC_Zonas

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Catálogo de Zonas (ABC_Zonas)

## Descripción General
Este módulo permite la administración del catálogo de zonas (alta, baja, modificación, consulta) migrado desde Delphi a Laravel + Vue.js + PostgreSQL. Toda la lógica de negocio se implementa en stored procedures y se expone a través de un endpoint API unificado.

## Arquitectura
- **Backend**: Laravel Controller (ZonasController) con endpoint único `/api/execute`.
- **Frontend**: Componente Vue.js de página completa, sin tabs.
- **Base de Datos**: PostgreSQL con stored procedures para CRUD.
- **API**: Patrón eRequest/eResponse, donde el campo `action` define la operación y `payload` los datos.

## Endpoints
- **POST /api/execute**
  - **Body**:
    - `action`: string (ej: 'zonas.list', 'zonas.create', 'zonas.update', 'zonas.delete', 'zonas.get')
    - `payload`: objeto con los parámetros necesarios
  - **Response**:
    - `status`: 'success' | 'error'
    - `message`: string
    - `data`: resultado de la operación

## Stored Procedures
- `sp_zonas_create(zona, sub_zona, descripcion)`
- `sp_zonas_update(ctrol_zona, zona, sub_zona, descripcion)`
- `sp_zonas_delete(ctrol_zona)`

## Validaciones
- No se permite crear zonas duplicadas (zona + sub_zona únicos).
- No se puede eliminar una zona si existen empresas relacionadas.
- Todos los campos son obligatorios en alta y edición.

## Seguridad
- Validación de datos en backend (Laravel) y frontend (Vue).
- Manejo de errores y mensajes claros.

## Navegación
- Cada formulario es una página independiente.
- Breadcrumb para navegación contextual.

## Extensibilidad
- El endpoint `/api/execute` puede ser extendido para otros catálogos siguiendo el mismo patrón.

## Ejemplo de Request
```json
{
  "action": "zonas.create",
  "payload": {
    "zona": 1,
    "sub_zona": 2,
    "descripcion": "Zona Norte"
  }
}
```

## Ejemplo de Response
```json
{
  "status": "success",
  "message": "Zona creada",
  "data": [{ "ctrol_zona": 5, "zona": 1, "sub_zona": 2, "descripcion": "Zona Norte" }]
}
```


## Casos de Prueba

## Casos de Prueba: Catálogo de Zonas

### Caso 1: Alta exitosa
- **Input:** zona=20, sub_zona=5, descripcion='Zona Sur'
- **Acción:** zonas.create
- **Resultado esperado:** status=success, data contiene la nueva zona

### Caso 2: Alta duplicada
- **Input:** zona=1, sub_zona=2, descripcion='Zona Duplicada'
- **Acción:** zonas.create
- **Resultado esperado:** status=error, message='Ya existe una zona con esos datos'

### Caso 3: Edición exitosa
- **Input:** ctrol_zona=5, zona=1, sub_zona=2, descripcion='Zona Centro Editada'
- **Acción:** zonas.update
- **Resultado esperado:** status=success, data contiene la zona actualizada

### Caso 4: Eliminación con empresas relacionadas
- **Input:** ctrol_zona=3
- **Acción:** zonas.delete
- **Resultado esperado:** status=error, message='No se puede eliminar: existen empresas con esta zona.'

### Caso 5: Eliminación exitosa
- **Input:** ctrol_zona=8
- **Acción:** zonas.delete
- **Resultado esperado:** status=success, message='Zona eliminada correctamente'

### Caso 6: Consulta de listado
- **Acción:** zonas.list
- **Resultado esperado:** status=success, data es un array de zonas


## Casos de Uso

# Casos de Uso - ABC_Zonas

**Categoría:** Form

## Caso de Uso 1: Alta de Zona

**Descripción:** El usuario desea agregar una nueva zona al catálogo.

**Precondiciones:**
El usuario tiene acceso al módulo de zonas.

**Pasos a seguir:**
1. El usuario ingresa a la página de Catálogo de Zonas.
2. Hace clic en 'Agregar Zona'.
3. Llena los campos: Zona=10, Sub Zona=1, Descripción='Zona Industrial'.
4. Hace clic en 'Crear'.

**Resultado esperado:**
La zona se agrega correctamente y aparece en el listado.

**Datos de prueba:**
{ "zona": 10, "sub_zona": 1, "descripcion": "Zona Industrial" }

---

## Caso de Uso 2: Edición de Zona

**Descripción:** El usuario edita la descripción de una zona existente.

**Precondiciones:**
Existe una zona con ctrol_zona=5.

**Pasos a seguir:**
1. El usuario localiza la zona con ctrol_zona=5.
2. Hace clic en 'Editar'.
3. Cambia la descripción a 'Zona Centro Actualizada'.
4. Hace clic en 'Actualizar'.

**Resultado esperado:**
La descripción de la zona se actualiza correctamente.

**Datos de prueba:**
{ "ctrol_zona": 5, "zona": 1, "sub_zona": 2, "descripcion": "Zona Centro Actualizada" }

---

## Caso de Uso 3: Eliminación de Zona sin empresas relacionadas

**Descripción:** El usuario elimina una zona que no tiene empresas asociadas.

**Precondiciones:**
Existe una zona con ctrol_zona=8 y ninguna empresa la usa.

**Pasos a seguir:**
1. El usuario localiza la zona con ctrol_zona=8.
2. Hace clic en 'Eliminar'.
3. Confirma la eliminación.

**Resultado esperado:**
La zona se elimina correctamente del catálogo.

**Datos de prueba:**
{ "ctrol_zona": 8 }

---



---
**Componente:** `ABC_Zonas.vue`
**MÃ³dulo:** `aseo_contratado`

