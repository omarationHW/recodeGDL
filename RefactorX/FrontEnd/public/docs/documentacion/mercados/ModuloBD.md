# ModuloBD

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica - Migración ModuloBD (Delphi → Laravel + Vue.js + PostgreSQL)

## Arquitectura General

- **Backend:** Laravel 10+ (PHP 8.1+), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente (NO tabs), navegación por rutas.
- **Base de Datos:** PostgreSQL 14+, toda la lógica SQL encapsulada en stored procedures (SPs).
- **Autenticación:** Laravel Sanctum/JWT (no incluido aquí, pero recomendado para producción).

## Flujo de Comunicación

1. **Frontend** envía peticiones POST a `/api/execute` con un JSON:
   ```json
   {
     "action": "getCategorias",
     "params": {}
   }
   ```
2. **Backend** (Laravel Controller) recibe la petición, despacha según `action`, llama el SP correspondiente y retorna la respuesta en formato eResponse:
   ```json
   {
     "success": true,
     "data": [...],
     "message": ""
   }
   ```
3. **Frontend** renderiza la respuesta y actualiza la UI.

## Estructura del Endpoint `/api/execute`
- **Método:** POST
- **Body:** `{ action: string, params: object }`
- **Respuesta:** `{ success: bool, data: any, message: string }`

## Ejemplo de Uso
- Obtener categorías:
  - Request: `{ "action": "getCategorias" }`
  - Response: `{ "success": true, "data": [{"categoria":1,"descripcion":"A"},...], "message": "" }`
- Agregar categoría:
  - Request: `{ "action": "addCategoria", "params": { "descripcion": "Nueva" } }`
  - Response: `{ "success": true, "data": [{"categoria":5,"descripcion":"NUEVA"}], "message": "" }`

## Seguridad
- Todas las acciones deben validar permisos del usuario autenticado (no incluido en este ejemplo).
- Validar y sanitizar todos los parámetros antes de ejecutar SPs.

## Convenciones
- Todos los SPs devuelven un TABLE para facilitar el consumo por Laravel.
- Los nombres de los SPs siguen el patrón `sp_[accion]_[entidad]`.
- El frontend debe manejar errores y mostrar mensajes amigables.

## Extensibilidad
- Para agregar nuevos formularios, crear el SP correspondiente y agregar el case en el controlador.
- El frontend puede reutilizar el patrón de página para otros catálogos CRUD.

## Despliegue
- Laravel: Usar migraciones para crear tablas y SPs.
- Vue: Compilar y desplegar en el mismo dominio o como SPA independiente.
- PostgreSQL: Ejecutar los scripts de SPs en la base de datos destino.

## Notas
- El ejemplo de Vue es para "Catálogo de Categorías". Para otros catálogos, replicar el patrón cambiando los campos y acciones.
- El endpoint es unificado para facilitar integración y auditoría.


## Casos de Uso

# Casos de Uso - ModuloBD

**Categoría:** Form

## Caso de Uso 1: Agregar una nueva Categoría

**Descripción:** El usuario desea agregar una nueva categoría al catálogo.

**Precondiciones:**
El usuario tiene permisos de administrador y está autenticado.

**Pasos a seguir:**
1. El usuario accede a la página de Categorías.
2. Hace clic en 'Agregar Categoría'.
3. Ingresa la descripción 'Especial'.
4. Hace clic en 'Guardar'.

**Resultado esperado:**
La nueva categoría aparece en la lista con la descripción 'ESPECIAL'.

**Datos de prueba:**
{ "descripcion": "Especial" }

---

## Caso de Uso 2: Editar una Categoría existente

**Descripción:** El usuario desea modificar la descripción de una categoría.

**Precondiciones:**
Existe una categoría con ID 2 y el usuario tiene permisos.

**Pasos a seguir:**
1. El usuario accede a la página de Categorías.
2. Hace clic en 'Editar' en la fila de la categoría con ID 2.
3. Cambia la descripción a 'Comercial'.
4. Hace clic en 'Actualizar'.

**Resultado esperado:**
La categoría con ID 2 muestra la descripción 'COMERCIAL'.

**Datos de prueba:**
{ "categoria": 2, "descripcion": "Comercial" }

---

## Caso de Uso 3: Listar todas las Categorías

**Descripción:** El usuario desea ver el listado completo de categorías.

**Precondiciones:**
Existen al menos 3 categorías en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de Categorías.
2. El sistema muestra la tabla con todas las categorías.

**Resultado esperado:**
Se muestran todas las categorías existentes.

**Datos de prueba:**
N/A

---



## Casos de Prueba

# Casos de Prueba - Catálogo de Categorías

## Caso 1: Agregar Categoría
- **Entrada:** { "action": "addCategoria", "params": { "descripcion": "Industrial" } }
- **Esperado:** Respuesta success true, data contiene la nueva categoría con descripción 'INDUSTRIAL'.

## Caso 2: Editar Categoría
- **Entrada:** { "action": "updateCategoria", "params": { "categoria": 1, "descripcion": "Residencial" } }
- **Esperado:** Respuesta success true, data contiene la categoría con ID 1 y descripción 'RESIDENCIAL'.

## Caso 3: Listar Categorías
- **Entrada:** { "action": "getCategorias" }
- **Esperado:** Respuesta success true, data es un array de categorías.

## Caso 4: Validación de campos vacíos
- **Entrada:** { "action": "addCategoria", "params": { "descripcion": "" } }
- **Esperado:** Respuesta success false, message indica error de validación.

## Caso 5: Error de SP
- **Simular:** Forzar error en base de datos (por ejemplo, descripción muy larga).
- **Esperado:** Respuesta success false, message contiene el error del SP.



