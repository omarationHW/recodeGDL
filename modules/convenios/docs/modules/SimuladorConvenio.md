# Simulador de Convenios - Documentación Técnica

## Descripción General
El Simulador de Convenios permite consultar y simular el cálculo de convenios de diferentes tipos de ingresos municipales (Predial, Licencias, Mercados, Aseo, Estacionamientos, Obras Públicas, etc.) a partir de la búsqueda de un registro y la simulación de los importes, recargos y parcialidades.

## Arquitectura
- **Backend:** Laravel (PHP) + PostgreSQL
- **Frontend:** Vue.js SPA (Single Page Application)
- **API:** Endpoint único `/api/execute` usando patrón eRequest/eResponse
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures

## Flujo de Trabajo
1. El usuario selecciona el tipo de convenio a simular (Predial, Licencias, etc.).
2. El usuario ingresa los datos requeridos para buscar el registro (ej. cuenta predial, licencia, local de mercado, etc.).
3. El frontend llama `/api/execute` con `action: buscarRegistro` y los parámetros.
4. El backend ejecuta el stored procedure `spd_17_buscaregistro` y retorna los datos del registro.
5. El frontend llama `/api/execute` con `action: simularConvenio` y los parámetros del registro.
6. El backend ejecuta el stored procedure `spd_17_liqtotgral` y retorna los totales simulados.
7. El frontend muestra los totales y las parcialidades simuladas (llamando a `listarPeriodos` si aplica).

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "showMercados|buscarRegistro|simularConvenio|listarPeriodos",
      ... parámetros ...
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": { ... }
  }
  ```

## Stored Procedures
- **spd_17_buscaregistro:** Busca el registro según módulo y parámetros.
- **spd_17_liqtotgral:** Calcula los totales simulados para el registro y periodo.

## Seguridad
- Validación de parámetros en backend.
- Manejo de errores y mensajes amigables.
- No se exponen detalles internos de la base de datos.

## Frontend
- Cada formulario es una página independiente (no tabs).
- Navegación por rutas y breadcrumbs.
- Componentes Vue.js desacoplados para cada tipo de convenio.
- Lógica de simulación y presentación desacoplada.

## Backend
- Controlador Laravel centralizado para todas las acciones.
- Uso de stored procedures para lógica de negocio compleja.
- Respuestas estructuradas y uniformes.

## Extensibilidad
- Para agregar un nuevo tipo de convenio, basta con:
  - Agregar el formulario Vue.js correspondiente.
  - Implementar el caso en el controlador y stored procedure.

# Parámetros de Entrada por Módulo
- **Predial (modulo=5):** rec, ur, cuenta
- **Licencias (modulo=9):** licencia
- **Anuncios (modulo=10):** anuncio
- **Mercados (modulo=11):** oficina, mercado, categoria, seccion, local, letra, bloque
- **Aseo (modulo=16):** tipo, contrato
- **Est. Público (modulo=24):** público
- **Est. Exclusivo (modulo=28):** exclusivo
- **Obras Públicas (modulo=17):** ...

# Errores Comunes
- Si no se encuentra el registro, se retorna status 'not_found'.
- Si ocurre un error de cálculo, se retorna status 'error' y mensaje.

# Ejemplo de Llamada API
```json
{
  "eRequest": {
    "action": "buscarRegistro",
    "modulo": 5,
    "p1": 1,
    "p2": "U",
    "p3": 123456
  }
}
```

# Ejemplo de Respuesta
```json
{
  "eResponse": {
    "status": "ok",
    "registro": {
      "id_registro": 123,
      "nombre": "Juan Pérez",
      ...
    }
  }
}
```
