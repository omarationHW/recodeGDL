# Casos de Uso - webBrowser

**Categoría:** Form

## Caso de Uso 1: Navegación a URL válida

**Descripción:** El usuario ingresa una URL válida en el campo y el iframe navega correctamente a esa dirección.

**Precondiciones:**
El usuario tiene acceso a la página y la API está disponible.

**Pasos a seguir:**
1. El usuario accede a la página 'Localiza predio'.
2. Ingresa 'https://www.google.com' en el campo de URL.
3. Sale del campo (blur) o presiona Enter.
4. El sistema valida la URL y actualiza el iframe.

**Resultado esperado:**
El iframe muestra la página de Google.

**Datos de prueba:**
https://www.google.com

---

## Caso de Uso 2: Ingreso de URL inválida

**Descripción:** El usuario ingresa una cadena que no es una URL válida.

**Precondiciones:**
El usuario está en la página y la API responde.

**Pasos a seguir:**
1. El usuario ingresa 'not_a_url' en el campo de URL.
2. Sale del campo (blur).
3. El sistema valida y rechaza la entrada.

**Resultado esperado:**
Se muestra un mensaje de error indicando formato inválido y el iframe no cambia.

**Datos de prueba:**
not_a_url

---

## Caso de Uso 3: Campo de URL vacío

**Descripción:** El usuario borra el contenido del campo de URL y sale del campo.

**Precondiciones:**
El usuario está en la página.

**Pasos a seguir:**
1. El usuario borra el contenido del campo de URL.
2. Sale del campo (blur).
3. El sistema valida y rechaza la entrada.

**Resultado esperado:**
Se muestra un mensaje de error indicando que la URL es obligatoria.

**Datos de prueba:**


---

