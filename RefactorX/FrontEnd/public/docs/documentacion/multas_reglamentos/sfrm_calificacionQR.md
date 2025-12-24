# Documentación: sfrm_calificacionQR

## Análisis Técnico

# Documentación Técnica: Migración Formulario sfrm_calificacionQR

## 1. Descripción General
Este módulo corresponde a la migración del formulario Delphi `sfrm_calificacionQR` a una arquitectura moderna basada en Laravel (API RESTful), Vue.js (SPA) y PostgreSQL (procedimientos almacenados). Permite consultar e imprimir la calificación de una multa, mostrando datos principales, artículos relacionados y un código QR generado dinámicamente.

## 2. Arquitectura
- **Backend:** Laravel 10+, API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 2/3 SPA, componente de página independiente.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato de entrada:**
  ```json
  {
    "eRequest": "get_calificacion_qr_full",
    "params": { "id_multa": 123 }
  }
  ```
- **Formato de salida:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": {
        "calificacion": { ... },
        "articulos": [ ... ]
      },
      "error": null
    }
  }
  ```

## 4. Stored Procedures
- **sp_get_calificacion_qr:** Devuelve los datos principales de la multa.
- **sp_get_multas_articulos:** Devuelve los artículos asociados a la multa.

## 5. Lógica de Negocio
- El usuario ingresa un ID de multa.
- Se consulta la información principal y los artículos asociados vía stored procedures.
- Se genera un string QR con los campos clave y se muestra visualmente.
- Se permite imprimir la información en formato amigable.

## 6. Seguridad
- Validación de parámetros en backend.
- Manejo de errores y mensajes claros en frontend.

## 7. Dependencias Frontend
- `qrcode.vue` para generación de QR.
- Bootstrap (opcional) para estilos.

## 8. Extensibilidad
- El endpoint `/api/execute` permite agregar nuevos eRequest fácilmente.
- Los stored procedures pueden ser reutilizados por otros módulos.

## 9. Consideraciones
- El componente Vue es una página independiente, no usa tabs.
- El QR contiene: dependencia|año|num_acta|fecha_acta|contribuyente.
- El botón imprimir usa `window.print()` para impresión directa.

## 10. Ejemplo de Uso
1. Usuario ingresa el ID de multa y presiona Buscar.
2. Se muestran los datos, artículos y el QR.
3. Puede imprimir la página.

---

## Casos de Uso

# Casos de Uso - sfrm_calificacionQR

**Categoría:** Form

## Caso de Uso 1: Consulta de Calificación QR por ID de Multa

**Descripción:** El usuario desea consultar la información completa de una multa específica, incluyendo datos principales, artículos relacionados y el código QR.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce el ID de la multa.

**Pasos a seguir:**
1. Acceder a la página de Calificación QR.
2. Ingresar el ID de la multa en el formulario.
3. Presionar el botón 'Buscar'.

**Resultado esperado:**
Se muestran los datos principales de la multa, los artículos relacionados y el código QR generado.

**Datos de prueba:**
id_multa: 12345

---

## Caso de Uso 2: Intento de Consulta con ID de Multa Inexistente

**Descripción:** El usuario ingresa un ID de multa que no existe en la base de datos.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. Acceder a la página de Calificación QR.
2. Ingresar un ID de multa inexistente (por ejemplo, 999999).
3. Presionar el botón 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que no hay multa con ese dato.

**Datos de prueba:**
id_multa: 999999

---

## Caso de Uso 3: Impresión de Calificación QR

**Descripción:** El usuario consulta una multa válida y desea imprimir la información mostrada.

**Precondiciones:**
El usuario ha realizado una consulta exitosa de una multa.

**Pasos a seguir:**
1. Consultar una multa válida.
2. Presionar el botón 'Imprimir'.

**Resultado esperado:**
Se abre el diálogo de impresión del navegador con la información formateada para impresión.

**Datos de prueba:**
id_multa: 12345

---

## Casos de Prueba

## Casos de Prueba para Calificación QR

### Caso 1: Consulta Exitosa de Multa
- **Entrada:** id_multa = 12345
- **Acción:** POST /api/execute con eRequest = get_calificacion_qr_full
- **Resultado esperado:**
  - success = true
  - data.calificacion contiene los campos principales
  - data.articulos es un array con al menos un elemento
  - El QR generado contiene los datos correctos

### Caso 2: Consulta con ID Inexistente
- **Entrada:** id_multa = 999999
- **Acción:** POST /api/execute con eRequest = get_calificacion_qr_full
- **Resultado esperado:**
  - success = true
  - data.calificacion = null
  - data.articulos = []
  - El frontend muestra mensaje 'No hay multa con este dato'

### Caso 3: Error de Parámetro Faltante
- **Entrada:** No se envía id_multa
- **Acción:** POST /api/execute con eRequest = get_calificacion_qr_full
- **Resultado esperado:**
  - success = false
  - error indica parámetro faltante o error de ejecución

### Caso 4: Impresión
- **Precondición:** Consulta exitosa de multa
- **Acción:** Usuario presiona botón 'Imprimir'
- **Resultado esperado:**
  - Se abre el diálogo de impresión del navegador
  - Solo se imprime la información relevante (sin formulario ni navegación)

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

