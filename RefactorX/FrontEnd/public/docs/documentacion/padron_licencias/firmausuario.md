# Documentación Técnica: firmausuario

## Análisis Técnico

# Documentación Técnica: Migración Formulario firmausuario (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo implementa el formulario de validación de firma electrónica de usuario, migrado desde Delphi a una arquitectura moderna basada en Laravel (API REST), Vue.js (SPA) y PostgreSQL (lógica de negocio en stored procedures). El flujo permite que un usuario ingrese su nombre de usuario y firma electrónica, y valida estos datos contra la base de datos.

## 2. Arquitectura
- **Frontend:** Componente Vue.js independiente, página completa, sin tabs.
- **Backend:** Laravel Controller con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos:** PostgreSQL, lógica de validación encapsulada en stored procedure.

## 3. API Unificada
- **Endpoint:** `POST /api/execute`
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "validate_firma_usuario",
      "data": {
        "usuario": "nombre_usuario",
        "firma": "firma_digital"
      }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true/false,
      "message": "Mensaje de validación",
      "usuario": "nombre_usuario" // solo si success=true
    }
  }
  ```

## 4. Stored Procedure
- **Nombre:** `sp_validate_firma_usuario`
- **Parámetros:**
  - `p_usuario` (VARCHAR): Nombre de usuario
  - `p_firma` (VARCHAR): Firma electrónica
- **Retorno:**
  - `success` (BOOLEAN): true si la validación es correcta
  - `message` (TEXT): Mensaje descriptivo
- **Tabla esperada:** `usuarios(usuario VARCHAR, firma_digital VARCHAR, ...)`

## 5. Flujo de la Aplicación
1. El usuario accede a la página de firma electrónica.
2. Ingresa usuario y firma.
3. Al presionar "Aceptar", se envía la petición a `/api/execute`.
4. Laravel recibe la petición, valida los datos y llama al stored procedure.
5. El resultado se retorna al frontend y se muestra el mensaje correspondiente.

## 6. Validaciones
- Frontend: Campos obligatorios.
- Backend: Validación de presencia y tipo de datos.
- Stored Procedure: Validación de existencia y coincidencia de usuario/firma.

## 7. Seguridad
- La firma se transmite cifrada por HTTPS.
- El campo de firma es tipo password en el frontend.
- Se recomienda almacenar la firma cifrada/hasheada en la base de datos (no incluido en este ejemplo por compatibilidad con Delphi).

## 8. Extensibilidad
- El endpoint `/api/execute` permite agregar nuevas acciones fácilmente.
- El frontend puede ser reutilizado en otros módulos.

## 9. Consideraciones
- El icono de firma debe estar disponible en `/public/firma-icon.png`.
- El stored procedure asume que la tabla `usuarios` existe y contiene los campos necesarios.

## Casos de Prueba

## Casos de Prueba para FirmaUsuario

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|--------------------|
| 1 | Validación exitosa | usuario: 'jdoe', firma: 'abc123' | success: true, message: 'Firma validada correctamente.' |
| 2 | Firma incorrecta | usuario: 'jdoe', firma: 'wrongpass' | success: false, message: 'Usuario o firma incorrectos.' |
| 3 | Usuario inexistente | usuario: 'ghost', firma: 'cualquier' | success: false, message: 'Usuario o firma incorrectos.' |
| 4 | Campos vacíos | usuario: '', firma: '' | success: false, errors: usuario y firma obligatorios |
| 5 | Usuario vacío | usuario: '', firma: 'abc123' | success: false, errors: usuario obligatorio |
| 6 | Firma vacía | usuario: 'jdoe', firma: '' | success: false, errors: firma obligatoria |
| 7 | SQL Injection intento | usuario: "' OR '1'='1", firma: 'abc123' | success: false, message: 'Usuario o firma incorrectos.' |

## Casos de Uso

# Casos de Uso - firmausuario

**Categoría:** Form

## Caso de Uso 1: Validación exitosa de firma electrónica

**Descripción:** Un usuario autorizado ingresa correctamente su usuario y firma electrónica, y el sistema valida exitosamente.

**Precondiciones:**
El usuario 'jdoe' existe en la tabla 'usuarios' con firma_digital 'abc123'.

**Pasos a seguir:**
1. Acceder a la página de firma electrónica.
2. Ingresar 'jdoe' en el campo Usuario.
3. Ingresar 'abc123' en el campo Firma.
4. Presionar 'Aceptar'.

**Resultado esperado:**
El sistema muestra el mensaje 'Firma validada correctamente.' y success=true.

**Datos de prueba:**
{ "usuario": "jdoe", "firma": "abc123" }

---

## Caso de Uso 2: Firma incorrecta para usuario existente

**Descripción:** Un usuario existente ingresa una firma incorrecta.

**Precondiciones:**
El usuario 'jdoe' existe en la tabla 'usuarios' con firma_digital 'abc123'.

**Pasos a seguir:**
1. Acceder a la página de firma electrónica.
2. Ingresar 'jdoe' en el campo Usuario.
3. Ingresar 'wrongpass' en el campo Firma.
4. Presionar 'Aceptar'.

**Resultado esperado:**
El sistema muestra el mensaje 'Usuario o firma incorrectos.' y success=false.

**Datos de prueba:**
{ "usuario": "jdoe", "firma": "wrongpass" }

---

## Caso de Uso 3: Usuario inexistente

**Descripción:** Un usuario que no existe intenta validar su firma.

**Precondiciones:**
El usuario 'ghost' no existe en la tabla 'usuarios'.

**Pasos a seguir:**
1. Acceder a la página de firma electrónica.
2. Ingresar 'ghost' en el campo Usuario.
3. Ingresar cualquier valor en el campo Firma.
4. Presionar 'Aceptar'.

**Resultado esperado:**
El sistema muestra el mensaje 'Usuario o firma incorrectos.' y success=false.

**Datos de prueba:**
{ "usuario": "ghost", "firma": "cualquier" }

---
