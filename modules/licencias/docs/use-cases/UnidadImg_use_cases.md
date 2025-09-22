# Casos de Uso - UnidadImg

**Categoría:** Form

## Caso de Uso 1: Configurar la unidad de imágenes por primera vez

**Descripción:** El usuario accede al formulario y selecciona la unidad de disco donde se almacenarán las imágenes. Guarda la configuración.

**Precondiciones:**
No existe la clave 'UnidadImg' en la tabla de configuración.

**Pasos a seguir:**
1. El usuario ingresa a la página 'Unidad de Imágenes'.
2. Selecciona la unidad 'D' en el selector.
3. Presiona el botón 'Guardar'.

**Resultado esperado:**
La unidad 'D' se almacena en la base de datos y se muestra un mensaje de éxito.

**Datos de prueba:**
{ "unidad_img": "D" }

---

## Caso de Uso 2: Actualizar la unidad de imágenes existente

**Descripción:** El usuario cambia la unidad de imágenes de 'D' a 'E'.

**Precondiciones:**
La clave 'UnidadImg' existe con valor 'D'.

**Pasos a seguir:**
1. El usuario ingresa a la página 'Unidad de Imágenes'.
2. El selector muestra 'D' como valor actual.
3. Cambia la selección a 'E'.
4. Presiona 'Guardar'.

**Resultado esperado:**
La unidad se actualiza a 'E' en la base de datos y se muestra un mensaje de éxito.

**Datos de prueba:**
{ "unidad_img": "E" }

---

## Caso de Uso 3: Obtener la ruta de una imagen

**Descripción:** El sistema calcula la ruta de una imagen para un trámite y un id de imagen dados.

**Precondiciones:**
La clave 'UnidadImg' existe con valor 'E'.

**Pasos a seguir:**
1. Se realiza una petición a la API con acción 'rutaimagen', id_tramite=1234, id_imagen=5678.

**Resultado esperado:**
La API responde con la ruta: 'Etrlic0001000/5678'.

**Datos de prueba:**
{ "id_tramite": 1234, "id_imagen": 5678 }

---

