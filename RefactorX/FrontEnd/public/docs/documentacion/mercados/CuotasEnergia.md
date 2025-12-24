# CuotasEnergia

## AnÃ¡lisis TÃ©cnico

# Cuotas de Energía Eléctrica - Documentación Técnica

## Descripción General
Este módulo permite la gestión de las cuotas de energía eléctrica (ta_11_kilowhatts) en el sistema de mercados municipales. Incluye la consulta, alta, modificación y eliminación de cuotas, así como la visualización de historial y usuario responsable.

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` usando el patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js independiente como página completa.
- **Base de Datos:** PostgreSQL con stored procedures para toda la lógica de negocio y acceso a datos.

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "list|create|update|delete|get",
    "params": { ... },
    "module": "cuotas_energia"
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true|false,
    "data": [ ... ] | { ... },
    "message": "..."
  }
  ```

## Métodos Disponibles
- `list`: Lista todas las cuotas.
- `create`: Crea una nueva cuota. Requiere `axo`, `periodo`, `importe`.
- `update`: Modifica una cuota existente. Requiere `id_kilowhatts`, `axo`, `periodo`, `importe`.
- `delete`: Elimina una cuota. Requiere `id_kilowhatts`.
- `get`: Obtiene una cuota por ID. Requiere `id_kilowhatts`.

## Validaciones
- El importe debe ser mayor a 0.
- El año (`axo`) debe ser razonable (ej. >= 2000).
- El periodo debe estar entre 1 y 12.

## Seguridad
- El usuario autenticado se toma de la sesión Laravel y se registra en los movimientos.
- Solo usuarios autorizados pueden crear, modificar o eliminar cuotas.

## Frontend
- Página Vue.js independiente, sin tabs.
- Tabla con paginación, búsqueda y acciones de editar/eliminar.
- Formulario para alta/modificación con validación en frontend y backend.
- Mensajes de éxito/error claros.

## Stored Procedures
- Toda la lógica de acceso y validación reside en los SPs de PostgreSQL.
- No se permite acceso directo a tablas desde el backend.

## Ejemplo de Llamada API
```js
// Listar cuotas
axios.post('/api/execute', { action: 'list', module: 'cuotas_energia' })

// Crear cuota
axios.post('/api/execute', { action: 'create', module: 'cuotas_energia', params: { axo: 2024, periodo: 6, importe: 123.456789 } })
```

## Manejo de Errores
- Los errores de validación y de base de datos se devuelven en el campo `message`.
- El frontend muestra los mensajes en pantalla.

## Integración
- El componente Vue puede ser usado en cualquier router-view.
- El backend puede ser extendido para otros catálogos usando el mismo patrón.

## Seguridad y Auditoría
- Todos los cambios quedan registrados con el usuario responsable y la fecha/hora.
- Se recomienda auditar los cambios críticos en una tabla de auditoría adicional.


## Casos de Uso

# Casos de Uso - CuotasEnergia

**Categoría:** Form

## Caso de Uso 1: Alta de nueva cuota de energía eléctrica

**Descripción:** El usuario desea registrar una nueva cuota de energía eléctrica para el periodo 7 del año 2024.

**Precondiciones:**
El usuario tiene permisos de administrador y está autenticado.

**Pasos a seguir:**
1. El usuario accede a la página de Cuotas de Energía Eléctrica.
2. Hace clic en 'Agregar Cuota'.
3. Ingresa Año: 2024, Periodo: 7, Importe: 150.123456.
4. Hace clic en 'Agregar'.

**Resultado esperado:**
La cuota se agrega correctamente, aparece en la tabla y muestra mensaje de éxito.

**Datos de prueba:**
{ "axo": 2024, "periodo": 7, "importe": 150.123456 }

---

## Caso de Uso 2: Modificación de cuota existente

**Descripción:** El usuario necesita corregir el importe de una cuota ya registrada.

**Precondiciones:**
Existe una cuota con id_kilowhatts=5, el usuario tiene permisos de edición.

**Pasos a seguir:**
1. El usuario localiza la cuota con id 5 en la tabla.
2. Hace clic en 'Editar'.
3. Cambia el importe a 200.654321.
4. Hace clic en 'Guardar Cambios'.

**Resultado esperado:**
El importe se actualiza y la tabla refleja el nuevo valor.

**Datos de prueba:**
{ "id_kilowhatts": 5, "axo": 2024, "periodo": 7, "importe": 200.654321 }

---

## Caso de Uso 3: Eliminación de cuota

**Descripción:** El usuario elimina una cuota que fue registrada por error.

**Precondiciones:**
Existe una cuota con id_kilowhatts=10.

**Pasos a seguir:**
1. El usuario localiza la cuota con id 10 en la tabla.
2. Hace clic en 'Eliminar'.
3. Confirma la eliminación.

**Resultado esperado:**
La cuota desaparece de la tabla y se muestra mensaje de éxito.

**Datos de prueba:**
{ "id_kilowhatts": 10 }

---



## Casos de Prueba

# Casos de Prueba para Cuotas de Energía Eléctrica

## 1. Alta de cuota válida
- **Entrada:** axo=2024, periodo=6, importe=123.456789
- **Acción:** create
- **Esperado:** success=true, cuota aparece en listado

## 2. Alta de cuota con importe cero
- **Entrada:** axo=2024, periodo=6, importe=0
- **Acción:** create
- **Esperado:** success=false, message indica error de validación

## 3. Modificación de cuota existente
- **Entrada:** id_kilowhatts=3, axo=2024, periodo=6, importe=321.654987
- **Acción:** update
- **Esperado:** success=true, importe actualizado

## 4. Eliminación de cuota
- **Entrada:** id_kilowhatts=4
- **Acción:** delete
- **Esperado:** success=true, cuota ya no aparece en listado

## 5. Consulta de cuota inexistente
- **Entrada:** id_kilowhatts=9999
- **Acción:** get
- **Esperado:** success=true, data=null

## 6. Listado general
- **Entrada:**
- **Acción:** list
- **Esperado:** success=true, data es array de cuotas

## 7. Validación de usuario no autenticado
- **Entrada:** create sin sesión
- **Esperado:** success=false, message de autenticación



