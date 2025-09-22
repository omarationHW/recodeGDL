# AdeudosLocGrl - Migración Delphi a Laravel + Vue.js + PostgreSQL

## Descripción General
Este módulo permite consultar y exportar el reporte de adeudos generales de locales de mercados, filtrando por recaudadora, mercado, año y mes. Incluye la obtención de recaudadoras, mercados, y la consulta principal de adeudos, así como la exportación a Excel (a implementar).

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js de página completa, sin tabs, con navegación y tabla de resultados.
- **Base de Datos:** Toda la lógica SQL se implementa en stored procedures PostgreSQL.

## API (eRequest/eResponse)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "getAdeudosLocalesGrl",
    "params": {
      "id_rec": 1,
      "num_mercado": 5,
      "axo": 2024,
      "mes": 6
    }
  }
  ```
- **Acciones soportadas:**
  - `getRecaudadoras`: Lista recaudadoras
  - `getMercadosByRecaudadora`: Lista mercados por recaudadora
  - `getAdeudosLocalesGrl`: Consulta principal de adeudos
  - `exportExcel`: (A implementar)

## Stored Procedure Principal
- `sp_adeudos_loc_grl(id_rec, num_mercado, axo, mes)`
- Devuelve todos los campos requeridos para el reporte, incluyendo cálculo de meses y folios de requerimientos.

## Flujo de la Página Vue.js
1. Al cargar, obtiene recaudadoras.
2. Al seleccionar recaudadora, obtiene mercados.
3. El usuario selecciona año y mes, y ejecuta la búsqueda.
4. Se muestra la tabla de resultados.
5. Opción de exportar a Excel (alerta si no implementado).

## Validaciones
- No permite buscar sin seleccionar recaudadora.
- Muestra mensajes de error si la API responde con error.

## Seguridad
- Todas las consultas usan parámetros para evitar SQL Injection.
- El endpoint puede ser protegido con middleware de autenticación según la política del sistema.

## Consideraciones
- La exportación a Excel debe implementarse en backend o como descarga CSV en frontend.
- El stored procedure puede ser extendido para paginación si el volumen de datos lo requiere.

# Estructura de la Base de Datos
- `ta_11_adeudo_local`: Adeudos de locales
- `ta_11_locales`: Locales de mercados
- `ta_12_recaudadoras`: Catálogo de recaudadoras
- `ta_11_mercados`: Catálogo de mercados
- `ta_15_apremios`: Requerimientos (folios)

# Integración
- El frontend se comunica únicamente con `/api/execute`.
- El backend enruta la acción al stored procedure correspondiente y retorna los datos en formato JSON.

# Pruebas y Casos de Uso
Ver secciones siguientes.
