# Documentación Técnica: Migración de PadronEnergia (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel 10+ (PHP 8+), API RESTful, endpoint único `/api/execute` (eRequest/eResponse)
- **Frontend:** Vue.js 3 (SPA), componente de página independiente para PadronEnergia
- **Base de Datos:** PostgreSQL 13+, lógica de negocio en stored procedures
- **Comunicación:** JSON, patrón eRequest/eResponse

## 2. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "action": "getPadronEnergia",
    "params": {
      "id_rec": 1,
      "num_mercado_nvo": 5
    }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": [ ... ],
    "message": ""
  }
  ```

## 3. Stored Procedures
- Toda la lógica SQL se encapsula en stored procedures para desacoplar la lógica de negocio de la aplicación.
- Los procedimientos devuelven tablas (RETURNS TABLE) para facilitar la integración con Laravel.

## 4. Laravel Controller
- Un solo controlador maneja todas las acciones relacionadas con PadronEnergia.
- Utiliza validación de parámetros y manejo de errores.
- Llama a los stored procedures usando DB::select o DB::statement.
- Soporta acciones: obtener recaudadoras, mercados, padrón, exportar Excel, imprimir PDF.

## 5. Vue.js Component
- Página independiente, sin tabs ni subcomponentes.
- Filtros: recaudadora y mercado (ambos obligatorios).
- Botones: Buscar, Exportar Excel, Imprimir PDF.
- Tabla de resultados con scroll horizontal.
- Mensajes de error y loading.
- Navegación breadcrumb.

## 6. Seguridad
- Validación de parámetros en backend.
- Sanitización de entradas.
- Acceso autenticado (middleware Laravel recomendado).

## 7. Exportación e Impresión
- Exportar Excel: genera archivo y devuelve URL para descarga.
- Imprimir PDF: genera PDF y devuelve URL para previsualización/impresión.

## 8. Pruebas y Casos de Uso
- Incluye casos de uso y escenarios de prueba para asegurar la funcionalidad y robustez.

## 9. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- Los stored procedures pueden evolucionar sin afectar la API.

## 10. Consideraciones de Migración
- Los nombres de campos y tablas se adaptan a la convención PostgreSQL (snake_case).
- Los tipos de datos Delphi se mapean a tipos PostgreSQL equivalentes.
- La lógica de negocio (por ejemplo, cálculos de recargos) debe migrarse a stored procedures si es necesario.

---
