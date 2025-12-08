# Documentación Técnica: UnidadImg

## Análisis Técnico

# Documentación Técnica: Migración Formulario UnidadImg (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo permite configurar la unidad de disco donde se almacenan las imágenes del sistema. La configuración se almacena en la base de datos (tabla `configuracion`, clave `UnidadImg`). El frontend permite seleccionar la unidad, y el backend expone lógica para obtener/guardar la unidad y calcular rutas de imágenes.

## 2. Arquitectura
- **Frontend:** Vue.js (componente de página independiente)
- **Backend:** Laravel Controller (API unificada `/api/execute`)
- **Base de datos:** PostgreSQL (stored procedures para lógica de negocio)
- **Persistencia:** Tabla `configuracion` (clave/valor)

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Patrón:** eRequest/eResponse
- **Acciones soportadas:**
  - `getUnidadImg`: Obtiene la unidad configurada
  - `setUnidadImg`: Guarda la unidad seleccionada
  - `rutaimagen`: Devuelve la ruta completa de una imagen
  - `rutadir`: Devuelve la ruta del directorio de imágenes

### Ejemplo de eRequest
```json
{
  "eRequest": {
    "action": "setUnidadImg",
    "params": {
      "unidad_img": "D"
    }
  }
}
```

### Ejemplo de eResponse
```json
{
  "success": true,
  "message": "Actualizado correctamente",
  "data": null
}
```

## 4. Stored Procedures
- **get_unidad_img()**: Devuelve la unidad actual
- **set_unidad_img(p_unidad)**: Inserta/actualiza la unidad
- **rutaimagen(id_tramite, id_imagen)**: Devuelve la ruta de la imagen
- **rutadir(id_tramite)**: Devuelve la ruta del directorio

## 5. Tabla de Configuración
```sql
CREATE TABLE configuracion (
  clave VARCHAR PRIMARY KEY,
  valor VARCHAR
);
```

## 6. Lógica de Rutas
- Si la unidad no está configurada, se usa 'N' por defecto.
- Las rutas se construyen según el rango de `id_tramite`:
  - 1..999: `<unidad>trlic00000/<id_imagen>`
  - 1000..9999: `<unidad>trlic0<grupo>000/<id_imagen>`
  - 10000..999999: `<unidad>trlic<grupo>000/<id_imagen>`
  - Otro: `<unidad>no_encontro`

## 7. Seguridad
- Solo se permite guardar letras (A-Z) como unidad.
- El endpoint valida los parámetros requeridos.

## 8. Frontend
- Página independiente con selector de unidad (A-Z)
- Botón para guardar
- Mensaje de éxito/error
- Breadcrumb de navegación

## 9. Backend
- Controlador Laravel maneja todas las acciones vía switch/case
- Llama a stored procedures para toda la lógica

## 10. Pruebas
- Casos de uso y pruebas incluidas para validar la funcionalidad

## Casos de Prueba

# Casos de Prueba: UnidadImg

| Caso | Acción | Entrada | Resultado Esperado |
|------|--------|---------|--------------------|
| 1 | getUnidadImg | {"action":"getUnidadImg"} | Devuelve unidad actual o 'N' si no existe |
| 2 | setUnidadImg | {"action":"setUnidadImg", "params":{"unidad_img":"F"}} | Respuesta success=true, mensaje de éxito |
| 3 | setUnidadImg (actualizar) | {"action":"setUnidadImg", "params":{"unidad_img":"G"}} | Respuesta success=true, mensaje de éxito |
| 4 | rutaimagen | {"action":"rutaimagen", "params":{"id_tramite":500, "id_imagen":10}} | Devuelve ruta 'Ftrlic00000/10' |
| 5 | rutadir | {"action":"rutadir", "params":{"id_tramite":1500}} | Devuelve ruta 'Ftrlic01000' |
| 6 | setUnidadImg (inválido) | {"action":"setUnidadImg", "params":{}} | Respuesta success=false, mensaje de error |
| 7 | rutaimagen (sin id_tramite) | {"action":"rutaimagen", "params":{"id_imagen":1}} | Respuesta success=false, mensaje de error |
| 8 | rutadir (sin id_tramite) | {"action":"rutadir", "params":{}} | Respuesta success=false, mensaje de error |

## Casos de Uso

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


