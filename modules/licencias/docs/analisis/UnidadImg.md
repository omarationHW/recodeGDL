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
