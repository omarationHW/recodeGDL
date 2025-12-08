# Documentación Técnica: bloqueoDomiciliosfrm

## Análisis Técnico

# Documentación Técnica: Bloqueo de Domicilios

## Descripción General
Este módulo permite la gestión de domicilios bloqueados en el sistema de licencias municipales. Incluye:
- Alta, modificación, eliminación y consulta de domicilios bloqueados.
- Exportación a Excel (requiere implementación backend o descarga CSV).
- API unificada bajo el endpoint `/api/execute` usando el patrón eRequest/eResponse.
- Lógica de negocio y persistencia en stored procedures PostgreSQL.
- Interfaz de usuario en Vue.js como página independiente.

## Arquitectura
- **Backend:** Laravel Controller (`BloqueoDomiciliosController`) expone un endpoint `/api/execute` que recibe un objeto `eRequest` con la acción y parámetros. Todas las operaciones CRUD se delegan a stored procedures en PostgreSQL.
- **Frontend:** Componente Vue.js de página completa, sin tabs, con tabla de domicilios bloqueados, formulario modal para alta/modificación, y modal para eliminación con motivo.
- **Base de Datos:** Lógica encapsulada en stored procedures para agregar, modificar y eliminar domicilios bloqueados, incluyendo manejo de histórico.

## API eRequest/eResponse
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "eRequest": {
      "action": "list|add|update|delete|search|export_excel",
      "params": { ... }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [ ... ] | { ... },
      "message": "..."
    }
  }
  ```

### Acciones soportadas
- `list`: Lista todos los domicilios bloqueados (orden calle, num_ext, num_int)
- `list_by_fecha`: Lista ordenado por fecha/hora
- `search`: Busca por calle (parámetro: `calle`)
- `add`: Agrega un domicilio bloqueado (parámetros: `cvecalle`, `calle`, `num_ext`, `let_ext`, `num_int`, `let_int`, `observacion`, `capturista`)
- `update`: Modifica un domicilio bloqueado (parámetros: igual que add, más `folio`)
- `delete`: Elimina un domicilio bloqueado (parámetros: `folio`, `motivo`, `usuario`)
- `export_excel`: (No implementado en API, debe hacerse en backend o frontend)

## Validaciones
- Todos los campos requeridos deben ser enviados.
- No se permite eliminar sin motivo y usuario.
- El alta y modificación validan existencia de datos mínimos.

## Seguridad
- El endpoint debe protegerse con autenticación (middleware Laravel).
- El campo `capturista` debe ser el usuario autenticado.

## Integración Vue.js
- El componente consume `/api/execute` vía fetch/AJAX.
- El formulario de alta/modificación se muestra en modal.
- El formulario de eliminación solicita motivo.
- La tabla permite seleccionar fila para editar/eliminar.
- La búsqueda por calle es reactiva.

## Exportación a Excel
- No implementada en API, sugerido usar descarga CSV desde frontend o endpoint dedicado.

## Manejo de Histórico
- Al eliminar un domicilio bloqueado, se inserta el registro en `h_bloqueo_dom` con motivo, usuario y tipo de movimiento.

## Estructura de Tablas
- `bloqueo_dom`: Domicilios bloqueados actuales.
- `h_bloqueo_dom`: Histórico de domicilios bloqueados.

## Stored Procedures
- `sp_bloqueo_dom_add`: Alta
- `sp_bloqueo_dom_update`: Modificación
- `sp_bloqueo_dom_delete`: Eliminación con histórico

## Flujo de Trabajo
1. El usuario accede a la página de bloqueo de domicilios.
2. Puede buscar, agregar, modificar o eliminar domicilios bloqueados.
3. Todas las operaciones se realizan vía `/api/execute`.
4. Al eliminar, se solicita motivo y se guarda en histórico.

## Consideraciones
- El componente Vue es una página completa, no un tab.
- El endpoint es único y flexible para futuras acciones.
- El backend puede extenderse para exportar Excel si se requiere.

## Casos de Prueba

*Casos de prueba no disponibles en la documentación fuente.*

## Casos de Uso

# Casos de Uso - bloqueoDomiciliosfrm

**Categoría:** Form

## Caso de Uso 1: Agregar un domicilio bloqueado

**Descripción:** El usuario necesita bloquear un domicilio específico por motivo de irregularidad.

**Precondiciones:**
El usuario está autenticado y tiene permisos de captura.

**Pasos a seguir:**
1. El usuario accede a la página de Bloqueo de Domicilios.
2. Da clic en 'Agregar'.
3. Llena los campos: Calle, No. Ext., Letra ext., No. Int., Letra int., Observaciones, Capturista.
4. Da clic en 'Aceptar'.
5. El sistema valida y envía la petición a /api/execute con acción 'add'.

**Resultado esperado:**
El domicilio aparece en la lista de bloqueados con los datos capturados.

**Datos de prueba:**
{ "calle": "AV. JUAREZ", "cvecalle": 123, "num_ext": 456, "let_ext": "A", "num_int": 2, "let_int": "B", "observacion": "Irregularidad detectada", "capturista": "usuario1" }

---

## Caso de Uso 2: Eliminar un domicilio bloqueado

**Descripción:** El usuario requiere desbloquear un domicilio y registrar el motivo.

**Precondiciones:**
El domicilio existe en la lista y el usuario tiene permisos.

**Pasos a seguir:**
1. El usuario selecciona el domicilio en la tabla.
2. Da clic en 'Eliminar'.
3. Ingresa el motivo de eliminación.
4. Da clic en 'Eliminar' en el modal de confirmación.
5. El sistema envía la petición a /api/execute con acción 'delete'.

**Resultado esperado:**
El domicilio desaparece de la lista y se registra en el histórico con el motivo.

**Datos de prueba:**
{ "folio": 1001, "motivo": "Regularización", "usuario": "usuario1" }

---

## Caso de Uso 3: Buscar domicilios bloqueados por calle

**Descripción:** El usuario desea filtrar la lista de domicilios bloqueados por nombre de calle.

**Precondiciones:**
Existen domicilios bloqueados en la base de datos.

**Pasos a seguir:**
1. El usuario escribe parte del nombre de la calle en el campo de búsqueda.
2. El sistema envía la petición a /api/execute con acción 'search' y parámetro 'calle'.
3. La tabla se actualiza mostrando solo los domicilios coincidentes.

**Resultado esperado:**
Solo se muestran los domicilios bloqueados cuya calle contiene el texto buscado.

**Datos de prueba:**
{ "calle": "AV. JUAREZ" }

---
