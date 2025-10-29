# Casos de Uso - newsfrm

**Categoría:** Form

## Caso de Uso 1: Visualización de Cambios del Módulo

**Descripción:** El usuario accede a la página de cambios del módulo y visualiza la lista de notas de versión.

**Precondiciones:**
El usuario tiene acceso a la aplicación y está autenticado.

**Pasos a seguir:**
1. El usuario navega a la ruta /news.
2. El sistema consulta el endpoint /api/execute con eRequest 'get_news_changes'.
3. El sistema muestra la lista de cambios.

**Resultado esperado:**
El usuario ve la lista completa de cambios/notas de versión.

**Datos de prueba:**
No se requiere data específica, solo acceso a la app.

---

## Caso de Uso 2: Aceptar Cambios del Módulo

**Descripción:** El usuario acepta los cambios del módulo presionando el botón correspondiente.

**Precondiciones:**
El usuario ha visualizado la lista de cambios.

**Pasos a seguir:**
1. El usuario presiona el botón 'Aceptar Cambios'.
2. El sistema envía eRequest 'acknowledge_news_changes' con el user_id.
3. El sistema muestra que los cambios han sido aceptados.

**Resultado esperado:**
El botón cambia a 'Cambios Aceptados' y se deshabilita.

**Datos de prueba:**
user_id = 1

---

## Caso de Uso 3: Error por Falta de user_id al Aceptar Cambios

**Descripción:** El sistema maneja el caso en que no se envía user_id al intentar aceptar los cambios.

**Precondiciones:**
El usuario intenta aceptar cambios sin estar autenticado o sin user_id.

**Pasos a seguir:**
1. El usuario presiona 'Aceptar Cambios' sin que el sistema tenga user_id.
2. El sistema envía eRequest 'acknowledge_news_changes' sin user_id.
3. El backend responde con error.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que user_id es requerido.

**Datos de prueba:**
user_id = null

---

