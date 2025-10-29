# AdeEnergiaGrl - Migración Delphi a Laravel + Vue.js + PostgreSQL

## Descripción General
Este módulo corresponde al formulario de "Adeudos Generales de Energía" migrado desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El objetivo es consultar, visualizar y exportar los adeudos de energía eléctrica por mercado y recaudadora, con filtros por año y mes.

## Arquitectura
- **Backend:** Laravel, expone un endpoint único `/api/execute` que recibe peticiones eRequest/eResponse.
- **Frontend:** Vue.js, componente de página independiente, sin tabs, con navegación y tabla de resultados.
- **Base de Datos:** PostgreSQL, lógica de negocio y reportes encapsulados en stored procedures.

## Flujo de Trabajo
1. El usuario accede a la página de Adeudos Generales de Energía.
2. Selecciona la recaudadora (oficina) y el mercado.
3. Selecciona el año y mes límite para el reporte.
4. Presiona "Buscar" y se consulta el endpoint `/api/execute` con acción `getAdeudosEnergiaGrl`.
5. El backend ejecuta el stored procedure `sp_ade_energia_grl` en PostgreSQL y retorna los datos.
6. El usuario puede exportar a Excel o imprimir (funcionalidad a implementar).

## API (Laravel)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato:**
  ```json
  {
    "action": "getAdeudosEnergiaGrl",
    "params": {
      "id_rec": 1,
      "num_mercado_nvo": 5,
      "axo": 2024,
      "mes": 6
    }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true,
    "data": [ ... ],
    "message": ""
  }
  ```

## Frontend (Vue.js)
- Página independiente, sin tabs.
- Selección de recaudadora y mercado.
- Filtros de año y mes.
- Tabla de resultados con columnas: Rec., Merc., Cat., Sec., Local, Letra, Bloque, Nombre, Adicionales, Cuota, Año, Adeudo, Periodo de Adeudo.
- Botones para buscar, exportar a Excel, imprimir.

## Stored Procedure (PostgreSQL)
- Toda la lógica de consulta y cálculo de periodos/cuotas se encapsula en el SP `sp_ade_energia_grl`.
- El SP retorna los campos requeridos para la tabla y exportación.

## Seguridad
- Validación de parámetros en backend.
- El endpoint puede protegerse con middleware de autenticación según la política del sistema.

## Extensibilidad
- El endpoint `/api/execute` permite agregar nuevas acciones sin crear nuevos endpoints.
- El frontend puede extenderse para agregar filtros adicionales o exportaciones.

## Consideraciones
- La exportación a Excel y la impresión pueden implementarse como endpoints adicionales o como generación en frontend.
- El SP puede optimizarse para grandes volúmenes de datos usando índices y paginación si es necesario.

