# Documentación Técnica: LigaRequisitos

## Análisis Técnico

# Documentación Técnica: Liga de Requisitos a Giros

## Descripción General
Este módulo permite la administración de los requisitos (requisitos/documentos) que deben cumplir los diferentes giros comerciales. Permite ligar (asignar) o quitar requisitos a cada giro, así como consultar y reportar la configuración actual.

## Arquitectura
- **Backend**: Laravel Controller con endpoint único `/api/execute` usando el patrón eRequest/eResponse.
- **Frontend**: Componente Vue.js como página independiente.
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures.
- **API**: Todas las operaciones (consulta, alta, baja, reporte) se realizan mediante el endpoint `/api/execute`.

## Flujo de Datos
1. El usuario accede a la página de "Liga de Requisitos a Giros".
2. Se listan los giros disponibles (solo tipo 'L').
3. Al seleccionar un giro, se muestran dos listas:
   - Requisitos ligados (ya asignados a ese giro)
   - Requisitos disponibles (no asignados a ese giro)
4. El usuario puede agregar o quitar requisitos usando los botones correspondientes.
5. Todas las operaciones se ejecutan vía AJAX usando el endpoint `/api/execute`.
6. El usuario puede imprimir un reporte de la configuración actual.

## API (eRequest/eResponse)
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Body**:
  ```json
  {
    "action": "nombre_accion",
    "params": { ... }
  }
  ```
- **Acciones soportadas**:
  - `get_giros`: Lista de giros
  - `get_requisitos_ligados`: Requisitos ligados a un giro
  - `get_requisitos_disponibles`: Requisitos no ligados a un giro
  - `add_requisito`: Liga un requisito a un giro
  - `remove_requisito`: Quita un requisito de un giro
  - `search_giros`: Búsqueda de giros por descripción
  - `search_requisitos`: Búsqueda de requisitos por descripción
  - `print_report`: Genera un reporte PDF (simulado)

## Seguridad
- Todas las operaciones de alta/baja requieren autenticación y se recomienda registrar bitácora de usuario.
- Validaciones de existencia y unicidad en los stored procedures.

## Integración Frontend
- El componente Vue.js consume la API vía fetch/AJAX.
- No hay tabs ni subcomponentes: cada formulario es una página independiente.
- Navegación mediante breadcrumbs.

## Consideraciones de Migración
- El diseño desacopla completamente la UI de la lógica de negocio.
- El endpoint único permite fácil integración con otros sistemas.
- Los stored procedures aseguran integridad y reglas de negocio en la base de datos.

## Tablas Relacionadas
- `c_giros`: Catálogo de giros comerciales.
- `c_girosreq`: Catálogo de requisitos/documentos.
- `giro_req`: Relación N:M entre giros y requisitos.

## Ejemplo de Request/Response
### Agregar requisito
```json
{
  "action": "add_requisito",
  "params": { "id_giro": 1234, "req": 5 }
}
```
Respuesta:
```json
{
  "success": true,
  "message": "Requisito agregado"
}
```

### Quitar requisito
```json
{
  "action": "remove_requisito",
  "params": { "id_giro": 1234, "req": 5 }
}
```
Respuesta:
```json
{
  "success": true,
  "message": "Requisito eliminado"
}
```

## Reportes
- El reporte PDF muestra todos los giros y sus requisitos ligados.
- El endpoint `print_report` devuelve una URL de descarga o visualización.

## Casos de Prueba

# Casos de Prueba: Liga de Requisitos a Giros

## 1. Alta de requisito exitoso
- **Input:** { "action": "add_requisito", "params": { "id_giro": 1201, "req": 7 } }
- **Resultado esperado:** { "success": true, "message": "Requisito agregado" }
- **Verificación:** El registro existe en la tabla giro_req.

## 2. Alta de requisito duplicado
- **Input:** { "action": "add_requisito", "params": { "id_giro": 1201, "req": 7 } } (si ya existe)
- **Resultado esperado:** { "success": false, "message": "El requisito ya está ligado a este giro" }

## 3. Baja de requisito exitoso
- **Input:** { "action": "remove_requisito", "params": { "id_giro": 1201, "req": 7 } }
- **Resultado esperado:** { "success": true, "message": "Requisito eliminado" }
- **Verificación:** El registro ya no existe en giro_req.

## 4. Baja de requisito inexistente
- **Input:** { "action": "remove_requisito", "params": { "id_giro": 1201, "req": 999 } }
- **Resultado esperado:** { "success": false, "message": "El requisito no está ligado a este giro" }

## 5. Consulta de requisitos ligados
- **Input:** { "action": "get_requisitos_ligados", "params": { "id_giro": 1201 } }
- **Resultado esperado:** Lista de requisitos ligados a ese giro.

## 6. Consulta de requisitos disponibles
- **Input:** { "action": "get_requisitos_disponibles", "params": { "id_giro": 1201 } }
- **Resultado esperado:** Lista de requisitos no ligados a ese giro.

## 7. Búsqueda de giros
- **Input:** { "action": "search_giros", "params": { "descripcion": "ALIMENTOS" } }
- **Resultado esperado:** Lista de giros que contienen "ALIMENTOS" en la descripción.

## 8. Búsqueda de requisitos
- **Input:** { "action": "search_requisitos", "params": { "descripcion": "RFC" } }
- **Resultado esperado:** Lista de requisitos que contienen "RFC" en la descripción.

## 9. Reporte
- **Input:** { "action": "print_report", "params": {} }
- **Resultado esperado:** { "success": true, "url": "/api/reports/liga-requisitos.pdf" }

## Casos de Uso

# Casos de Uso - LigaRequisitos

**Categoría:** Form

## Caso de Uso 1: Agregar un requisito a un giro

**Descripción:** El usuario desea asignar un nuevo requisito/documento a un giro comercial específico.

**Precondiciones:**
El usuario tiene permisos de edición y el requisito no está ya ligado al giro.

**Pasos a seguir:**
1. El usuario accede a la página de Liga de Requisitos a Giros.
2. Busca y selecciona el giro deseado.
3. En la lista de requisitos disponibles, localiza el requisito a agregar.
4. Da clic en 'Agregar'.
5. El sistema envía la petición a la API.
6. El backend ejecuta el stored procedure de alta.
7. El frontend actualiza ambas listas.

**Resultado esperado:**
El requisito aparece en la lista de requisitos ligados y desaparece de la lista de disponibles. Se muestra mensaje de éxito.

**Datos de prueba:**
{ "id_giro": 1201, "req": 7 }

---

## Caso de Uso 2: Quitar un requisito de un giro

**Descripción:** El usuario necesita eliminar un requisito previamente asignado a un giro.

**Precondiciones:**
El requisito está actualmente ligado al giro.

**Pasos a seguir:**
1. El usuario selecciona el giro.
2. En la lista de requisitos ligados, localiza el requisito a quitar.
3. Da clic en 'Quitar'.
4. El sistema envía la petición a la API.
5. El backend ejecuta el stored procedure de baja.
6. El frontend actualiza ambas listas.

**Resultado esperado:**
El requisito desaparece de la lista de ligados y aparece en la lista de disponibles. Se muestra mensaje de éxito.

**Datos de prueba:**
{ "id_giro": 1201, "req": 7 }

---

## Caso de Uso 3: Buscar giros y requisitos por descripción

**Descripción:** El usuario quiere filtrar la lista de giros o requisitos por texto.

**Precondiciones:**
Existen giros y requisitos en el catálogo.

**Pasos a seguir:**
1. El usuario escribe parte de la descripción en el campo de búsqueda.
2. El sistema filtra la lista en tiempo real usando la API.

**Resultado esperado:**
Solo se muestran los registros que coinciden con el texto buscado.

**Datos de prueba:**
{ "descripcion": "ALIMENTOS" }

---
