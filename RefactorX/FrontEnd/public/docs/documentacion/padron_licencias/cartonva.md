# Documentación Técnica: cartonva

## Análisis Técnico
# Documentación Técnica: Migración Formulario Cartografía Predial (cartonva)

## 1. Descripción General
Este módulo permite consultar la información de una cuenta catastral y visualizar su cartografía predial en un visor web externo. El formulario original en Delphi ha sido migrado a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA), y PostgreSQL (base de datos y lógica de negocio).

## 2. Arquitectura
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3, componente de página independiente, sin tabs.
- **Base de Datos:** PostgreSQL 13+, lógica encapsulada en stored procedures.
- **Patrón de integración:** eRequest/eResponse (entrada/salida JSON).

## 3. API Backend
- **Endpoint:** `POST /api/execute`
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "getCartografiaPredial",
      "params": { "cvecuenta": 123456 }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true,
      "cuenta": { ... },
      "visor_url": "http://192.168.4.20:8080/Visor/index.html#user=123&session=se123&clavePredi0=XXXXXX"
    }
  }
  ```
- **Acciones soportadas:**
  - `getCartografiaPredial`: Devuelve datos de la cuenta y URL del visor.
  - `getCuentaByCvecuenta`: Devuelve solo los datos de la cuenta.
  - `getVisorUrl`: Devuelve solo la URL del visor para una clave catastral.

## 4. Stored Procedures
- Toda la lógica SQL se encapsula en funciones PostgreSQL (`sp_get_cartografia_predial`, `sp_get_cuenta_by_cvecuenta`).
- El backend invoca estos SP vía DB::select o DB::statement.

## 5. Frontend (Vue.js)
- Página independiente `/cartografia-predial`.
- Formulario para ingresar la clave de cuenta catastral.
- Al buscar, muestra los datos y un iframe con el visor cartográfico.
- No usa tabs ni componentes tabulares.
- Incluye breadcrumbs y manejo de errores.

## 6. Seguridad
- Validación de parámetros en backend y frontend.
- Manejo de errores y mensajes claros al usuario.
- No expone SQL ni rutas internas.

## 7. Extensibilidad
- El endpoint `/api/execute` puede ser extendido para otras acciones relacionadas.
- El componente Vue puede ser reutilizado en otras vistas.

## 8. Configuración
- La URL base del visor puede configurarse en `config/cartonva.php` en Laravel.

## 9. Pruebas
- Incluye casos de uso y escenarios de prueba para asegurar la funcionalidad.

---

## Casos de Prueba
# Casos de Prueba para Cartografía Predial (cartonva)

## Caso 1: Consulta exitosa de cuenta catastral
- **Entrada:** cvecuenta = 123456
- **Acción:** Buscar
- **Resultado esperado:**
  - Se muestran los datos de la cuenta (campos principales no vacíos)
  - El iframe del visor carga la URL con la clave catastral correspondiente

## Caso 2: Cuenta catastral inexistente
- **Entrada:** cvecuenta = 99999999
- **Acción:** Buscar
- **Resultado esperado:**
  - Se muestra mensaje de error: "Cuenta no encontrada"
  - No se muestra el iframe del visor

## Caso 3: Visualización directa del visor
- **Entrada:** cvecatnva = 'A1234567890'
- **Acción:** Llamar a la acción getVisorUrl vía API
- **Resultado esperado:**
  - Se recibe una URL válida del visor
  - El iframe o ventana muestra el visor con la clave catastral

## Caso 4: Validación de campos vacíos
- **Entrada:** cvecuenta = ''
- **Acción:** Buscar
- **Resultado esperado:**
  - El frontend no permite enviar el formulario
  - El backend responde con error de parámetro requerido si se fuerza la petición

## Caso 5: Respuesta de error del backend
- **Simulación:** Forzar un error en la base de datos
- **Acción:** Buscar cualquier cuenta
- **Resultado esperado:**
  - El frontend muestra un mensaje de error general
  - El backend responde con success: false y un mensaje de error

## Casos de Uso
# Casos de Uso - cartonva

**Categoría:** Form

## Caso de Uso 1: Consulta de Cartografía Predial por Cuenta Catastral

**Descripción:** El usuario ingresa la clave de cuenta catastral y visualiza la información y el visor cartográfico.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce la clave de cuenta catastral.

**Pasos a seguir:**
[
  "El usuario accede a la página 'Cartografía Predial'.",
  "Ingresa el número de cuenta catastral en el formulario.",
  "Presiona el botón 'Buscar'.",
  "El sistema consulta la API y muestra los datos de la cuenta.",
  "El visor cartográfico se carga en un iframe con la clave catastral correspondiente."
]

**Resultado esperado:**
Se muestran los datos de la cuenta y el visor cartográfico correctamente.

**Datos de prueba:**
cvecuenta: 123456

---

## Caso de Uso 2: Error al Buscar Cuenta Inexistente

**Descripción:** El usuario intenta buscar una cuenta catastral que no existe.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
[
  "Accede a la página 'Cartografía Predial'.",
  "Ingresa un número de cuenta catastral inexistente (ej: 99999999).",
  "Presiona 'Buscar'."
]

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que la cuenta no fue encontrada.

**Datos de prueba:**
cvecuenta: 99999999

---

## Caso de Uso 3: Visualización Directa del Visor Cartográfico

**Descripción:** El usuario accede directamente al visor cartográfico para una clave catastral específica.

**Precondiciones:**
El usuario conoce la clave catastral (cvecatnva).

**Pasos a seguir:**
[
  "El usuario accede a la página 'Cartografía Predial'.",
  "Hace clic en un enlace o botón que abre el visor cartográfico para una clave catastral.",
  "El sistema construye la URL y la muestra en un iframe o nueva ventana."
]

**Resultado esperado:**
El visor cartográfico se muestra correctamente para la clave catastral indicada.

**Datos de prueba:**
cvecatnva: 'A1234567890'

---
