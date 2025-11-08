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
