# Documentación Técnica: consultausuariosfrm

## Análisis Técnico

# Documentación Técnica: Migración de Formulario consultausuariosfrm

## 1. Arquitectura General

- **Backend**: Laravel (PHP) + PostgreSQL
- **Frontend**: Vue.js (SPA, rutas separadas por formulario)
- **API**: Endpoint único `/api/execute` usando patrón eRequest/eResponse
- **Base de datos**: Toda la lógica de consulta encapsulada en stored procedures PostgreSQL

## 2. API Unificada

- **Endpoint**: `/api/execute`
- **Método**: POST
- **Entrada**: JSON con campos:
  - `eRequest`: nombre de la operación (string)
  - `params`: parámetros específicos (object)
- **Salida**: JSON con campo `eResponse`:
  - `success`: bool
  - `data`: array de resultados o null
  - `message`: mensaje de error o vacío

### Ejemplo de request
```json
{
  "eRequest": "consulta_usuario_por_usuario",
  "params": { "usuario": "jdoe" }
}
```

### Ejemplo de response
```json
{
  "eResponse": {
    "success": true,
    "data": [ ... ],
    "message": ""
  }
}
```

## 3. Stored Procedures

- Toda la lógica SQL se implementa en funciones PostgreSQL (ver sección stored_procedures).
- Las funciones devuelven tablas con los campos requeridos.
- Se usan JOINs explícitos y parámetros tipados.

## 4. Laravel Controller

- Controlador `ExecuteController` con método `execute`.
- Recibe el eRequest y los params, despacha a la función SQL correspondiente.
- Maneja errores y devuelve la respuesta en formato eResponse.
- Se recomienda registrar la ruta en `routes/api.php`:

```php
Route::post('/execute', [\App\Http\Controllers\Api\ExecuteController::class, 'execute']);
```

## 5. Vue.js Frontend

- Cada formulario/tab original es ahora una página independiente:
  - `/consulta-usuario` (por usuario)
  - `/consulta-nombre` (por nombre)
  - `/consulta-depto` (por dependencia/departamento)
- Cada página tiene su propio formulario y lógica de búsqueda.
- Se usa un componente `UsuariosGrid` para mostrar los resultados.
- Navegación mediante breadcrumbs.
- Se recomienda usar Vue Router para las rutas.
- Axios se usa para llamadas a la API.

## 6. Validaciones y UX

- Validación de campos requeridos en frontend.
- Mensajes de error claros si falta algún dato.
- Resultados en tabla con campos: Usuario, Nombre, Dependencia, Departamento, Teléfono, Fechas, Capturó, Vigencia.
- Vigencia calculada en frontend: si `fecbaj` tiene valor, mostrar "Cancelado" en rojo, si no, "Vigente" en verde.

## 7. Seguridad

- Todas las consultas son parametrizadas vía stored procedures.
- No se expone SQL directo al usuario.
- Se recomienda proteger el endpoint con autenticación si es necesario.

## 8. Pruebas

- Casos de uso y pruebas detalladas en las secciones correspondientes.

## 9. Migración de Datos

- Se asume que las tablas `usuarios`, `deptos`, `c_dependencias` ya existen y están pobladas en PostgreSQL.
- Los nombres de campos y tipos deben coincidir con los usados en los stored procedures.

## Casos de Prueba

# Casos de Prueba

## Caso 1: Consulta por usuario exacto
- **Entrada:** usuario = 'jdoe'
- **Acción:** POST /api/execute { eRequest: 'consulta_usuario_por_usuario', params: { usuario: 'jdoe' } }
- **Resultado esperado:**
  - success: true
  - data: array con un registro de usuario 'jdoe'
  - message: ''

## Caso 2: Consulta por nombre (prefijo)
- **Entrada:** nombre = 'JUAN'
- **Acción:** POST /api/execute { eRequest: 'consulta_usuario_por_nombre', params: { nombre: 'JUAN' } }
- **Resultado esperado:**
  - success: true
  - data: array con todos los usuarios cuyo nombre inicia con 'JUAN'
  - message: ''

## Caso 3: Consulta por dependencia y departamento
- **Entrada:** id_dependencia = 2, cvedepto = 5
- **Acción:** POST /api/execute { eRequest: 'consulta_usuario_por_depto', params: { id_dependencia: 2, cvedepto: 5 } }
- **Resultado esperado:**
  - success: true
  - data: array con todos los usuarios del departamento 5 de la dependencia 2
  - message: ''

## Caso 4: Validación de campos requeridos
- **Entrada:** usuario = ''
- **Acción:** POST /api/execute { eRequest: 'consulta_usuario_por_usuario', params: { usuario: '' } }
- **Resultado esperado:**
  - success: false
  - data: null
  - message: 'usuario is required'

## Caso 5: Consulta de dependencias
- **Entrada:**
- **Acción:** POST /api/execute { eRequest: 'get_dependencias' }
- **Resultado esperado:**
  - success: true
  - data: array de dependencias
  - message: ''

## Caso 6: Consulta de departamentos por dependencia
- **Entrada:** id_dependencia = 2
- **Acción:** POST /api/execute { eRequest: 'get_deptos_by_dependencia', params: { id_dependencia: 2 } }
- **Resultado esperado:**
  - success: true
  - data: array de departamentos de la dependencia 2
  - message: ''

## Casos de Uso

# Casos de Uso - consultausuariosfrm

**Categoría:** Form

## Caso de Uso 1: Consulta de usuario por nombre de usuario exacto

**Descripción:** El usuario desea buscar información de un usuario específico ingresando su nombre de usuario exacto.

**Precondiciones:**
El usuario conoce el nombre de usuario exacto y existe en la base de datos.

**Pasos a seguir:**
1. Navegar a la página 'Consulta por Usuario'.
2. Ingresar el nombre de usuario (por ejemplo, 'jdoe') en el campo correspondiente.
3. Presionar el botón 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con la información del usuario 'jdoe', incluyendo dependencia, departamento, teléfono, fechas y vigencia.

**Datos de prueba:**
usuario: 'jdoe'

---

## Caso de Uso 2: Consulta de usuarios por prefijo de nombre

**Descripción:** El usuario desea buscar todos los usuarios cuyo nombre inicia con un texto dado.

**Precondiciones:**
Existen usuarios cuyos nombres inician con el texto proporcionado.

**Pasos a seguir:**
1. Navegar a la página 'Consulta por Nombre'.
2. Ingresar el prefijo del nombre (por ejemplo, 'JUAN') en el campo correspondiente.
3. Presionar el botón 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los usuarios cuyos nombres inician con 'JUAN'.

**Datos de prueba:**
nombre: 'JUAN'

---

## Caso de Uso 3: Consulta de usuarios por dependencia y departamento

**Descripción:** El usuario desea buscar todos los usuarios de un departamento específico dentro de una dependencia.

**Precondiciones:**
Existen dependencias y departamentos registrados en la base de datos.

**Pasos a seguir:**
1. Navegar a la página 'Consulta por Departamento'.
2. Seleccionar una dependencia de la lista desplegable.
3. Seleccionar un departamento de la lista desplegable.
4. Presionar el botón 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los usuarios del departamento seleccionado.

**Datos de prueba:**
id_dependencia: 2, cvedepto: 5

---
