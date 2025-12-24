# SeccionesMntto

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Mantenimiento a Secciones (SeccionesMntto)

## Descripción General
Este módulo permite la administración del catálogo de secciones de mercados. Incluye alta, modificación y consulta de secciones. La solución está compuesta por:

- **Backend Laravel**: Un controlador con endpoint unificado `/api/execute` que recibe acciones y datos en formato eRequest/eResponse.
- **Frontend Vue.js**: Un componente de página independiente para la gestión de secciones.
- **Base de Datos PostgreSQL**: Stored procedures para inserción y actualización de secciones.

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato de entrada:**
  ```json
  {
    "action": "getAllSecciones|getSeccion|insertSeccion|updateSeccion",
    "data": { ... }
  }
  ```
- **Formato de salida:**
  ```json
  {
    "success": true|false,
    "message": "Mensaje de resultado",
    "data": { ... }
  }
  ```

## Acciones Soportadas
- `getAllSecciones`: Lista todas las secciones.
- `getSeccion`: Obtiene una sección específica (`data.seccion`).
- `insertSeccion`: Inserta una nueva sección (`data.seccion`, `data.descripcion`).
- `updateSeccion`: Actualiza la descripción de una sección (`data.seccion`, `data.descripcion`).

## Validaciones
- `seccion`: Obligatorio, máximo 2 caracteres, mayúsculas.
- `descripcion`: Obligatorio, máximo 30 caracteres, mayúsculas.

## Stored Procedures
- `sp_insert_seccion(p_seccion, p_descripcion)`
- `sp_update_seccion(p_seccion, p_descripcion)`

## Seguridad
- Todas las operaciones deben estar autenticadas (middleware Laravel recomendado).
- Validación de datos en backend y frontend.

## Frontend
- Página independiente, sin tabs.
- Formulario para alta/modificación.
- Tabla de consulta.
- Mensajes de éxito/error.
- Navegación breadcrumb.

## Backend
- Controlador Laravel centralizado.
- Uso de stored procedures para operaciones de escritura.
- Manejo de errores y mensajes claros.

## Integración
- El frontend consume el endpoint `/api/execute` con la acción y datos correspondientes.
- El backend enruta la acción al stored procedure o consulta adecuada.

## Ejemplo de Request para Insertar
```json
{
  "action": "insertSeccion",
  "data": {
    "seccion": "AB",
    "descripcion": "ABASTOS"
  }
}
```

## Ejemplo de Response
```json
{
  "success": true,
  "message": "Sección insertada correctamente",
  "data": null
}
```

## Notas
- El endpoint puede ser extendido para otras entidades siguiendo el mismo patrón.
- El frontend puede ser adaptado para otros catálogos reutilizando la estructura.


## Casos de Uso

# Casos de Uso - SeccionesMntto

**Categoría:** Form

## Caso de Uso 1: Alta de nueva sección

**Descripción:** Un usuario desea agregar una nueva sección al catálogo.

**Precondiciones:**
El usuario tiene permisos de administrador y la sección no existe.

**Pasos a seguir:**
1. El usuario accede a la página de Secciones.
2. Hace clic en 'Agregar'.
3. Ingresa 'seccion' = 'PS', 'descripcion' = 'PUESTOS'.
4. Presiona 'Aceptar'.

**Resultado esperado:**
La sección 'PS' se agrega y aparece en la lista. Se muestra mensaje de éxito.

**Datos de prueba:**
{ "seccion": "PS", "descripcion": "PUESTOS" }

---

## Caso de Uso 2: Modificación de descripción de sección

**Descripción:** El usuario desea actualizar la descripción de una sección existente.

**Precondiciones:**
La sección 'PS' ya existe.

**Pasos a seguir:**
1. El usuario selecciona la sección 'PS' en la tabla.
2. Hace clic en 'Editar'.
3. Cambia la descripción a 'PUESTOS SECUNDARIOS'.
4. Presiona 'Actualizar'.

**Resultado esperado:**
La descripción de la sección 'PS' se actualiza. Se muestra mensaje de éxito.

**Datos de prueba:**
{ "seccion": "PS", "descripcion": "PUESTOS SECUNDARIOS" }

---

## Caso de Uso 3: Intento de alta de sección duplicada

**Descripción:** El usuario intenta agregar una sección que ya existe.

**Precondiciones:**
La sección 'PS' ya existe.

**Pasos a seguir:**
1. El usuario accede a la página de Secciones.
2. Ingresa 'seccion' = 'PS', 'descripcion' = 'DUPLICADO'.
3. Presiona 'Agregar'.

**Resultado esperado:**
Se muestra mensaje de error indicando que la sección ya existe.

**Datos de prueba:**
{ "seccion": "PS", "descripcion": "DUPLICADO" }

---



## Casos de Prueba

# Casos de Prueba para SeccionesMntto

| Caso | Acción | Datos de Entrada | Resultado Esperado |
|------|--------|------------------|-------------------|
| 1 | Alta válida | {"seccion": "AB", "descripcion": "ABASTOS"} | Sección agregada, mensaje de éxito |
| 2 | Alta duplicada | {"seccion": "AB", "descripcion": "DUPLICADO"} | Error: La sección ya existe |
| 3 | Modificación válida | {"seccion": "AB", "descripcion": "ABASTOS CENTRO"} | Descripción actualizada, mensaje de éxito |
| 4 | Modificación inexistente | {"seccion": "ZZ", "descripcion": "NO EXISTE"} | Error: La sección no existe |
| 5 | Consulta general | - | Lista de secciones mostrada |
| 6 | Consulta específica | {"seccion": "AB"} | Sección 'AB' mostrada |
| 7 | Validación campos vacíos | {"seccion": "", "descripcion": ""} | Error de validación |
| 8 | Validación longitud | {"seccion": "ABC", "descripcion": "D".repeat(31)} | Error de validación |



