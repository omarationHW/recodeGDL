# Documentación Técnica: firma

## Análisis Técnico

# Documentación Técnica: Migración Formulario Firma Electrónica (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo implementa el formulario de ingreso de firma electrónica, migrado desde Delphi a una arquitectura moderna basada en Laravel (API), Vue.js (Frontend SPA) y PostgreSQL (Base de datos). El flujo permite validar y guardar la firma digital de un usuario, usando un endpoint API unificado y procedimientos almacenados.

## 2. Arquitectura
- **Frontend**: Vue.js SPA, página independiente para el formulario de firma electrónica.
- **Backend**: Laravel API, controlador único para todas las operaciones (patrón eRequest/eResponse).
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures.

## 3. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Entrada**: Objeto `eRequest` con campos:
  - `operation`: Nombre de la operación (ej: `firma_validate`, `firma_save`)
  - `data`: Datos requeridos por la operación
- **Salida**: Objeto `eResponse` con:
  - `success`: boolean
  - `message`: string
  - `data`: objeto con datos adicionales

## 4. Operaciones Soportadas
- `firma_validate`: Valida la firma digital ingresada.
- `firma_save`: Guarda o actualiza la firma digital de un usuario.

## 5. Stored Procedures
- **sp_firma_validate**: Recibe la firma digital, retorna si es válida y datos del usuario.
- **sp_firma_save**: Recibe usuario y firma, actualiza la firma en la tabla de usuarios.

## 6. Seguridad
- La firma digital se transmite encriptada por HTTPS.
- El campo de firma es tipo password en el frontend.
- Se recomienda almacenar la firma digital hasheada en la base de datos.

## 7. Flujo de Usuario
1. El usuario accede a la página de firma electrónica.
2. Ingresa su firma digital (campo password).
3. Al presionar "Aceptar", se envía a `/api/execute` con operación `firma_validate`.
4. El backend valida la firma y responde si es válida o no.
5. Si es válida, se puede proceder a guardar o permitir acceso.

## 8. Integración
- El componente Vue puede ser usado como página independiente.
- El controlador Laravel puede ser extendido para más operaciones.
- Los stored procedures pueden ser adaptados según la estructura real de la tabla de usuarios.

## 9. Consideraciones
- El endpoint es genérico y puede manejar múltiples operaciones.
- El frontend puede ser adaptado para usarse como modal o página según la navegación de la aplicación.

## 10. Dependencias
- Laravel 8+
- Vue.js 2/3
- PostgreSQL 12+
- Axios (para llamadas HTTP en Vue)

## Casos de Prueba

## Casos de Prueba: Firma Electrónica

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|--------------------|
| 1 | Firma válida | { "firma_digital": "123456" } | success: true, message: 'Firma válida.' |
| 2 | Firma inválida | { "firma_digital": "abcdef" } | success: false, message: 'Firma inválida.' |
| 3 | Campo vacío | { "firma_digital": "" } | success: false, message: 'Firma digital requerida.' |
| 4 | Actualizar firma existente | { "usuario_id": 1, "firma_digital": "nuevaFirma2024" } | success: true, message: 'Firma guardada correctamente.' |
| 5 | Actualizar firma con usuario inexistente | { "usuario_id": 999, "firma_digital": "firmaX" } | success: false, message: 'Usuario no encontrado.' |

## Casos de Uso

# Casos de Uso - firma

**Categoría:** Form

## Caso de Uso 1: Validación exitosa de firma electrónica

**Descripción:** Un usuario ingresa su firma electrónica correcta y es validado exitosamente.

**Precondiciones:**
El usuario existe en la tabla 'usuarios' y su campo 'firma_digital' coincide con la ingresada.

**Pasos a seguir:**
1. El usuario accede a la página de firma electrónica.
2. Ingresa su firma digital en el campo correspondiente.
3. Presiona el botón 'Aceptar'.
4. El sistema envía la firma al endpoint '/api/execute' con operación 'firma_validate'.
5. El backend valida la firma y responde con éxito.

**Resultado esperado:**
El usuario recibe un mensaje de éxito ('Firma válida. Bienvenido.') y puede continuar.

**Datos de prueba:**
{ "firma_digital": "123456" } // Asumiendo que '123456' es la firma válida en la base de datos

---

## Caso de Uso 2: Validación fallida de firma electrónica

**Descripción:** Un usuario ingresa una firma electrónica incorrecta.

**Precondiciones:**
El usuario existe, pero la firma ingresada no coincide con la registrada.

**Pasos a seguir:**
1. El usuario accede a la página de firma electrónica.
2. Ingresa una firma digital incorrecta.
3. Presiona 'Aceptar'.
4. El sistema envía la firma al endpoint '/api/execute'.
5. El backend responde que la firma es inválida.

**Resultado esperado:**
El usuario recibe un mensaje de error ('Firma inválida.') y no puede continuar.

**Datos de prueba:**
{ "firma_digital": "abcdef" } // 'abcdef' no existe en la base de datos

---

## Caso de Uso 3: Actualización de firma electrónica

**Descripción:** Un usuario actualiza su firma electrónica.

**Precondiciones:**
El usuario está autenticado y conoce su usuario_id.

**Pasos a seguir:**
1. El usuario accede a la página de actualización de firma.
2. Ingresa la nueva firma digital.
3. Presiona 'Aceptar'.
4. El sistema envía la nueva firma y usuario_id al endpoint '/api/execute' con operación 'firma_save'.
5. El backend actualiza la firma en la base de datos.

**Resultado esperado:**
El usuario recibe un mensaje de éxito ('Firma guardada correctamente.').

**Datos de prueba:**
{ "usuario_id": 1, "firma_digital": "nuevaFirma2024" }

---
