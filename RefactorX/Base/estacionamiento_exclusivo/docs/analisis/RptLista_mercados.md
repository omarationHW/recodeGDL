# Documentación Técnica: Migración de RptLista_mercados Delphi a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel API con endpoint único `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`.
- **Frontend:** Componente Vue.js como página independiente, consulta el API y muestra el reporte.
- **Base de Datos:** PostgreSQL, toda la lógica SQL y de negocio se implementa en stored procedures.

## 2. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "RptListaMercados",
      "params": {
        "vofna": 1,
        "vmerc1": 1,
        "vmerc2": 2,
        "vlocal1": 1,
        "vlocal2": 9999,
        "vsecc": "todas"
      }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```

## 3. Stored Procedures
- Toda la lógica de consulta, cálculos de recargos, gastos y totales se implementa en funciones de PostgreSQL.
- El SP principal `rpt_lista_mercados` devuelve todos los datos requeridos para el reporte, incluyendo los cálculos de recargos y gastos.
- SPs auxiliares permiten obtener resúmenes y detalles adicionales.

## 4. Laravel Controller
- El controlador `ExecuteController` recibe el `eRequest`, despacha la acción y llama el SP correspondiente.
- El resultado se empaqueta en `eResponse`.
- Maneja errores y validaciones básicas.

## 5. Vue.js Component
- Página completa, sin tabs.
- Formulario para filtros (oficina, mercados, locales, sección).
- Tabla de resultados con exportación a CSV.
- Manejo de loading y errores.
- Navegación breadcrumb.

## 6. Seguridad
- Se recomienda proteger el endpoint con autenticación (no incluido aquí por simplicidad).
- Validar y sanear los parámetros recibidos.

## 7. Consideraciones de Migración
- El cálculo de recargos y gastos se trasladó a SQL para mantener la lógica centralizada y eficiente.
- El frontend es desacoplado y solo consume el API.
- El SP puede ser extendido para incluir más campos si se requiere.

## 8. Pruebas
- Casos de uso y pruebas incluidas para validar la funcionalidad y lógica de negocio.

## 9. Extensibilidad
- Para agregar más reportes, basta con crear nuevos SPs y mapearlos en el controlador.
- El frontend puede ser extendido para mostrar más detalles o filtros.
