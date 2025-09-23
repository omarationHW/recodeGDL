# Documentación Técnica: Migración Formulario sfrmMetrometers a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General

- **Backend**: Laravel API con endpoint único `/api/execute` que recibe un objeto `eRequest` y `params`.
- **Frontend**: Vue.js SPA con rutas independientes para cada sección (Datos, Foto 1, Foto 2, Mapa).
- **Base de Datos**: PostgreSQL, toda la lógica SQL encapsulada en stored procedures.

## 2. API Unificada

- **Endpoint**: `/api/execute` (POST)
- **Entrada**:
  ```json
  {
    "eRequest": "getMetrometersByAxoFolio",
    "params": { "axo": 2024, "folio": 12345 }
  }
  ```
- **Salida**:
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```
- **eRequest soportados**:
  - `getMetrometersByAxoFolio`: Datos generales
  - `getMetrometersPhoto`: URL de foto 1 o 2
  - `getMetrometersMapUrl`: URL de mapa estático

## 3. Stored Procedures

- **sp_get_metrometers_by_axo_folio**: Devuelve todos los campos del registro por axo y folio.
- **sp_get_metrometers_photo**: Devuelve la URL de la foto 1 o 2.
- **sp_get_metrometers_map_url**: Devuelve la URL del mapa estático de Google Maps.

## 4. Frontend Vue.js

- **Página principal**: Formulario de búsqueda por axo y folio, muestra datos generales.
- **Página Foto 1**: Muestra la imagen 1 (usando la URL obtenida por API).
- **Página Foto 2**: Muestra la imagen 2.
- **Página Mapa**: Muestra el mapa estático de Google Maps.
- **Navegación**: Cada página es independiente, con breadcrumbs.

## 5. Seguridad

- Validación de parámetros en backend.
- Manejo de errores y mensajes claros en API y frontend.

## 6. Pruebas

- Casos de uso y escenarios de prueba definidos para asegurar cobertura funcional.

## 7. Extensibilidad

- El patrón eRequest/eResponse permite agregar nuevas operaciones sin modificar el endpoint.

## 8. Notas de Migración

- No se usan tabs en frontend, cada sección es una página.
- No se decodifican imágenes en base64, se usan URLs directas.
- El acceso a fotos y mapas es vía URL, no se almacenan archivos localmente.
