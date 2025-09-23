# Casos de Prueba - Catálogo de Etiquetas

## Caso 1: Consulta y edición exitosa
- **Preparación:**
  - Asegúrate que existe un registro en t34_etiq para cve_tab = '3'.
- **Acción:**
  - Selecciona '3 - Rastro'.
  - Cambia 'concesionario' a 'Nuevo Concesionario'.
  - Haz clic en 'Actualizar'.
- **Esperado:**
  - Mensaje de éxito.
  - Consulta directa en BD muestra el nuevo valor.

## Caso 2: Actualización con tabla no seleccionada
- **Preparación:**
  - Ingresa a la página y no selecciones ninguna tabla.
- **Acción:**
  - Haz clic en 'Actualizar'.
- **Esperado:**
  - Mensaje de error: 'cve_tab requerido'.

## Caso 3: Selección de tabla sin etiquetas
- **Preparación:**
  - Crea una tabla en t34_tablas sin registro en t34_etiq.
- **Acción:**
  - Selecciona esa tabla.
- **Esperado:**
  - Formulario vacío.
  - Botón 'Actualizar' deshabilitado.

## Caso 4: SQL Injection
- **Preparación:**
  - Intenta enviar en algún campo: "' OR 1=1; --"
- **Esperado:**
  - No debe ejecutarse ninguna acción peligrosa.
  - El sistema debe rechazar la petición o sanitizar el input.

## Caso 5: Campos vacíos
- **Preparación:**
  - Deja todos los campos vacíos y actualiza.
- **Esperado:**
  - Los campos en la base de datos se actualizan a espacios en blanco.
