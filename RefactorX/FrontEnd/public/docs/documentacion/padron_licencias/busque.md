# Documentación Técnica: busque

## Análisis Técnico
# Documentación Técnica: Migración de Formulario de Búsqueda Catastral (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Arquitectura General
- **Backend**: Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend**: Vue.js 3 SPA, cada formulario de búsqueda es una página independiente.
- **Base de Datos**: PostgreSQL, lógica SQL en stored procedures.
- **Comunicación**: Patrón eRequest/eResponse (JSON), desacoplado de la UI.

## 2. Endpoint Unificado
- **Ruta**: `/api/execute` (POST)
- **Entrada**: `{ eRequest: { action: 'buscar_por_nombre', params: { ... } } }`
- **Salida**: `{ eResponse: { success: bool, data: array|null, error: string|null } }`
- **Acciones soportadas**:
  - buscar_por_nombre
  - buscar_por_ubicacion
  - buscar_por_clave_catastral
  - buscar_por_rfc
  - buscar_por_cuenta

## 3. Controlador Laravel
- Valida la acción y los parámetros.
- Llama al stored procedure correspondiente vía DB::select('CALL ...').
- Devuelve los resultados en eResponse.
- Maneja errores y validaciones.

## 4. Stored Procedures PostgreSQL
- Cada búsqueda tiene su propio SP.
- Todos los SPs limitan los resultados a 300 registros.
- Uso de ILIKE para búsquedas insensibles a mayúsculas/minúsculas.
- JOINs para obtener información de propietario, predio y ubicación.

## 5. Componente Vue.js
- Cada formulario es una página independiente (no tabs).
- Menú para seleccionar el tipo de búsqueda.
- Cada formulario tiene su propio submit y validación.
- Resultados se muestran en tabla dinámica.
- Manejo de loading y errores.

## 6. Seguridad
- Validación de parámetros en backend.
- Límite de resultados para evitar abuso.
- No se exponen detalles internos de la base de datos.

## 7. Extensibilidad
- Se pueden agregar nuevas acciones/SPs fácilmente.
- El frontend puede agregar nuevas páginas de búsqueda sin afectar el backend.

## 8. Pruebas
- Casos de uso y escenarios de prueba incluidos.

---

# Esquema de Datos (Simplificado)
- **contrib**: Propietarios/contribuyentes
- **regprop**: Relación propietario-predio
- **convcta**: Cuentas catastrales
- **ubicacion**: Domicilio del predio
- **catastro**: Información adicional del predio
- **c_calidpro**: Catálogo de tipo de propietario

---

# Ejemplo de eRequest/eResponse

**Request:**
```json
{
  "eRequest": {
    "action": "buscar_por_nombre",
    "params": { "nombre": "JUAN PEREZ" }
  }
}
```

**Response:**
```json
{
  "eResponse": {
    "success": true,
    "data": [ { ... } ],
    "error": null
  }
}
```

## Casos de Prueba
# Casos de Prueba para Búsqueda Catastral

## 1. Búsqueda por Nombre (Éxito)
- **Entrada:** nombre = 'JUAN PEREZ'
- **Acción:** buscar_por_nombre
- **Esperado:** Lista de cuentas catastrales con propietarios que contienen 'JUAN PEREZ'.

## 2. Búsqueda por Nombre (Sin Resultados)
- **Entrada:** nombre = 'ZZZZZZZZ'
- **Acción:** buscar_por_nombre
- **Esperado:** Respuesta con data vacía y mensaje 'No se encontraron resultados.'

## 3. Búsqueda por Ubicación (Calle y Número)
- **Entrada:** calle = 'AV. JUAREZ', exterior = '123'
- **Acción:** buscar_por_ubicacion
- **Esperado:** Lista de cuentas catastrales que coinciden con la dirección.

## 4. Búsqueda por Clave Catastral (Zona/Manzana/Predio/Subpredio)
- **Entrada:** zona = 'D65J1', manzana = '345', predio = '12', subpredio = '1'
- **Acción:** buscar_por_clave_catastral
- **Esperado:** Lista de cuentas catastrales que coinciden con la clave.

## 5. Búsqueda por RFC (Éxito)
- **Entrada:** rfc = 'PEPJ800101'
- **Acción:** buscar_por_rfc
- **Esperado:** Lista de cuentas catastrales con ese RFC.

## 6. Búsqueda por RFC (Sin Resultados)
- **Entrada:** rfc = 'XXXX000000'
- **Acción:** buscar_por_rfc
- **Esperado:** Respuesta con data vacía y mensaje 'No se encontraron resultados.'

## 7. Búsqueda por Cuenta (Recaud/URBRUS/Cuenta)
- **Entrada:** recaud = 1, urbrus = 'U', cuenta = 123456
- **Acción:** buscar_por_cuenta
- **Esperado:** Lista de cuentas catastrales que coinciden con los datos.

## 8. Validación de Parámetros (Error)
- **Entrada:** nombre = ''
- **Acción:** buscar_por_nombre
- **Esperado:** Error de validación 'Nombre requerido para búsqueda.'

## 9. Límite de Resultados
- **Entrada:** nombre = 'A'
- **Acción:** buscar_por_nombre
- **Esperado:** Máximo 300 resultados en la respuesta.

## Casos de Uso
# Casos de Uso - busque

**Categoría:** Form

## Caso de Uso 1: Búsqueda por Nombre de Propietario

**Descripción:** El usuario busca cuentas catastrales ingresando el nombre completo del propietario.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce el nombre completo o parcial del propietario.

**Pasos a seguir:**
1. El usuario accede a la página de búsqueda por nombre.
2. Ingresa 'JUAN PEREZ' en el campo de nombre.
3. Presiona el botón 'Buscar'.
4. El sistema envía un eRequest con action 'buscar_por_nombre' y params { nombre: 'JUAN PEREZ' }.
5. El backend ejecuta el SP correspondiente y retorna los resultados.

**Resultado esperado:**
Se muestra una tabla con todas las cuentas catastrales cuyo propietario coincide parcial o totalmente con 'JUAN PEREZ'.

**Datos de prueba:**
nombre: 'JUAN PEREZ'

---

## Caso de Uso 2: Búsqueda por Ubicación (Calle y Número)

**Descripción:** El usuario busca cuentas catastrales por dirección del predio.

**Precondiciones:**
El usuario conoce la calle y opcionalmente el número exterior.

**Pasos a seguir:**
1. El usuario accede a la página de búsqueda por ubicación.
2. Ingresa 'AV. JUAREZ' en el campo de calle y '123' en el campo de exterior.
3. Presiona 'Buscar'.
4. El sistema envía un eRequest con action 'buscar_por_ubicacion' y params { calle: 'AV. JUAREZ', exterior: '123' }.
5. El backend ejecuta el SP y retorna los resultados.

**Resultado esperado:**
Se muestran las cuentas catastrales que coinciden con la calle y número exterior indicados.

**Datos de prueba:**
calle: 'AV. JUAREZ', exterior: '123'

---

## Caso de Uso 3: Búsqueda por RFC

**Descripción:** El usuario busca cuentas catastrales por RFC del propietario.

**Precondiciones:**
El usuario conoce el RFC completo o parcial.

**Pasos a seguir:**
1. El usuario accede a la página de búsqueda por RFC.
2. Ingresa 'PEPJ800101' en el campo RFC.
3. Presiona 'Buscar'.
4. El sistema envía un eRequest con action 'buscar_por_rfc' y params { rfc: 'PEPJ800101' }.
5. El backend ejecuta el SP y retorna los resultados.

**Resultado esperado:**
Se muestran las cuentas catastrales cuyo propietario tiene el RFC indicado.

**Datos de prueba:**
rfc: 'PEPJ800101'

---
