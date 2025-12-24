# Documentación Técnica: dictamenfrm

## Análisis Técnico

# Documentación Técnica: Migración de Formulario dictamenfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Frontend**: Vue.js SPA (Single Page Application), cada formulario es una página independiente.
- **Backend**: Laravel API RESTful, endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos**: PostgreSQL, lógica SQL encapsulada en stored procedures.

## 2. API Unificada (eRequest/eResponse)
- **Endpoint**: `/api/execute` (POST)
- **Request**:
  ```json
  {
    "eRequest": "dictamenfrm.getAnuncio",
    "params": { "anuncio": 12345 }
  }
  ```
- **Response**:
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "error": null
    }
  }
  ```
- **eRequest soportados**:
  - `dictamenfrm.getAnuncio`: Consulta de datos de anuncio.
  - `dictamenfrm.printReport`: Simulación de generación de PDF (en producción, integración con servicio de reportes).

## 3. Stored Procedure
- Toda la lógica SQL se encapsula en `dictamenfrm_get_anuncio(anuncio_id integer)`.
- Devuelve todos los campos requeridos para el reporte y la vista.

## 4. Controlador Laravel
- Un solo controlador (`ExecuteController`) maneja todos los eRequest.
- Valida parámetros, ejecuta el SP, y retorna la respuesta estructurada.

## 5. Componente Vue.js
- Página independiente `/dictamenfrm`.
- Permite ingresar el número de anuncio y seleccionar tipo de dictamen.
- Muestra los datos del anuncio y permite "imprimir" (simulado: descarga PDF).
- Maneja errores y estados de carga.

## 6. Seguridad
- Validación de parámetros en backend.
- El endpoint puede protegerse con middleware de autenticación según necesidades del proyecto.

## 7. Extensibilidad
- Nuevos eRequest pueden agregarse fácilmente en el controlador y frontend.
- Los SP pueden evolucionar sin afectar la API.

## 8. Notas de Migración
- El reporte visual (PDF) debe implementarse con una solución de generación de reportes en Laravel (ej: DomPDF, TCPDF, o integración con JasperReports).
- El SP puede adaptarse para devolver datos adicionales si el reporte lo requiere.

## 9. Estructura de Carpetas
- `app/Http/Controllers/Api/ExecuteController.php`
- `resources/js/pages/DictamenFrmPage.vue`
- `database/migrations/` y `database/functions/` para SP

## 10. Pruebas
- Casos de uso y pruebas detallados en las secciones siguientes.

## Casos de Prueba

## Casos de Prueba para Dictamen de Anuncio

### Caso 1: Consulta Exitosa de Anuncio
- **Entrada:** anuncio = 12345
- **Acción:** POST /api/execute { eRequest: 'dictamenfrm.getAnuncio', params: { anuncio: 12345 } }
- **Resultado esperado:** success = true, data contiene los campos del anuncio, error = null

### Caso 2: Consulta de Anuncio Inexistente
- **Entrada:** anuncio = 99999
- **Acción:** POST /api/execute { eRequest: 'dictamenfrm.getAnuncio', params: { anuncio: 99999 } }
- **Resultado esperado:** success = false, data = null, error = 'No se encontró el anuncio' o similar

### Caso 3: Generación de Reporte PDF
- **Entrada:** anuncio = 12345, tipo = 1
- **Acción:** POST /api/execute { eRequest: 'dictamenfrm.printReport', params: { anuncio: 12345, tipo: 1 } }
- **Resultado esperado:** success = true, data.pdf_url contiene la URL del PDF, error = null

### Caso 4: Error por Falta de Parámetro
- **Entrada:** anuncio = null
- **Acción:** POST /api/execute { eRequest: 'dictamenfrm.getAnuncio', params: { } }
- **Resultado esperado:** success = false, error = 'El parámetro anuncio es requerido'

### Caso 5: eRequest No Soportado
- **Entrada:** eRequest = 'dictamenfrm.unknown'
- **Acción:** POST /api/execute { eRequest: 'dictamenfrm.unknown', params: { anuncio: 12345 } }
- **Resultado esperado:** success = false, error = 'eRequest no soportado: dictamenfrm.unknown'

## Casos de Uso

# Casos de Uso - dictamenfrm

**Categoría:** Form

## Caso de Uso 1: Consulta de Dictamen de Anuncio Existente

**Descripción:** El usuario ingresa el número de anuncio existente y obtiene todos los datos del dictamen.

**Precondiciones:**
El anuncio existe en la base de datos y está vigente.

**Pasos a seguir:**
- El usuario accede a la página Dictamen de Anuncio.
- Ingresa el número de anuncio (ej: 12345).
- Selecciona el tipo de dictamen (Procedente o Improcedente).
- Presiona 'Buscar'.

**Resultado esperado:**
Se muestran todos los datos del anuncio, incluyendo propietario, ubicación, descripción, medidas, etc.

**Datos de prueba:**
{ "anuncio": 12345 }

---

## Caso de Uso 2: Intento de Consulta con Anuncio Inexistente

**Descripción:** El usuario ingresa un número de anuncio que no existe o no está vigente.

**Precondiciones:**
El anuncio no existe o no está vigente.

**Pasos a seguir:**
- El usuario accede a la página Dictamen de Anuncio.
- Ingresa el número de anuncio (ej: 99999).
- Presiona 'Buscar'.

**Resultado esperado:**
Se muestra un mensaje de error: 'No se encontró el anuncio'.

**Datos de prueba:**
{ "anuncio": 99999 }

---

## Caso de Uso 3: Generación de Reporte PDF de Dictamen

**Descripción:** El usuario consulta un anuncio existente y solicita la impresión del dictamen.

**Precondiciones:**
El anuncio existe y los datos han sido cargados.

**Pasos a seguir:**
- El usuario busca un anuncio válido.
- Se muestran los datos.
- El usuario presiona 'Imprimir Dictamen'.

**Resultado esperado:**
Se genera un enlace para descargar el PDF del dictamen.

**Datos de prueba:**
{ "anuncio": 12345, "tipo": 1 }

---
