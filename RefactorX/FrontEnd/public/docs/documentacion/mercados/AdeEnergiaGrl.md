# AdeEnergiaGrl

## AnÃ¡lisis TÃ©cnico

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



## Casos de Uso

# Casos de Uso - AdeEnergiaGrl

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos de Energía por Mercado

**Descripción:** El usuario desea consultar todos los adeudos de energía eléctrica del Mercado 5 de la Recaudadora 1 hasta junio de 2024.

**Precondiciones:**
El usuario tiene acceso al sistema y existen datos de adeudos en la base.

**Pasos a seguir:**
1. Acceder a la página de Adeudos Generales de Energía.
2. Seleccionar '1' en el campo Oficina (Recaudadora).
3. Seleccionar '5' en el campo Mercado.
4. Ingresar '2024' en Año Hasta y '6' en Mes Hasta.
5. Presionar el botón 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con los adeudos de energía eléctrica del Mercado 5 de la Recaudadora 1 hasta junio de 2024, incluyendo nombre, cuota, adeudo y periodos.

**Datos de prueba:**
{ "id_rec": 1, "num_mercado_nvo": 5, "axo": 2024, "mes": 6 }

---

## Caso de Uso 2: Exportación de Adeudos a Excel

**Descripción:** El usuario desea exportar el listado de adeudos consultado a un archivo Excel.

**Precondiciones:**
El usuario ya realizó una consulta y hay datos en la tabla.

**Pasos a seguir:**
1. Realizar la consulta como en el caso anterior.
2. Presionar el botón 'Excel'.

**Resultado esperado:**
Se descarga un archivo Excel con los mismos datos mostrados en la tabla.

**Datos de prueba:**
N/A (depende de la implementación de exportación)

---

## Caso de Uso 3: Validación de Parámetros Faltantes

**Descripción:** El usuario intenta buscar sin seleccionar recaudadora o mercado.

**Precondiciones:**
El usuario accede a la página pero no selecciona todos los filtros.

**Pasos a seguir:**
1. Acceder a la página.
2. No seleccionar recaudadora o mercado.
3. Presionar 'Buscar'.

**Resultado esperado:**
Se muestra un mensaje de error indicando que debe seleccionar recaudadora, mercado, año y mes.

**Datos de prueba:**
{ "id_rec": null, "num_mercado_nvo": null, "axo": 2024, "mes": 6 }

---



## Casos de Prueba

# Casos de Prueba para AdeEnergiaGrl

## Caso 1: Consulta exitosa de adeudos
- **Entrada:**
  - id_rec: 1
  - num_mercado_nvo: 5
  - axo: 2024
  - mes: 6
- **Acción:** POST /api/execute con action=getAdeudosEnergiaGrl
- **Resultado esperado:**
  - success: true
  - data: Array de objetos con campos id_local, oficina, num_mercado, ...
  - message: ""

## Caso 2: Filtros incompletos
- **Entrada:**
  - id_rec: null
  - num_mercado_nvo: null
  - axo: 2024
  - mes: 6
- **Acción:** POST /api/execute con action=getAdeudosEnergiaGrl
- **Resultado esperado:**
  - success: false
  - message: 'El campo id_rec es obligatorio.' o similar

## Caso 3: Exportación a Excel (no implementada)
- **Acción:** Click en botón 'Excel' sin datos
- **Resultado esperado:**
  - Mensaje: 'Funcionalidad de exportación a Excel no implementada.'

## Caso 4: Navegación y renderizado
- **Acción:** Acceder a la ruta de la página AdeEnergiaGrl
- **Resultado esperado:**
  - Se renderiza la página con los campos de filtro y tabla vacía

## Caso 5: Validación de año y mes fuera de rango
- **Entrada:**
  - axo: 1800
  - mes: 13
- **Acción:** POST /api/execute con action=getAdeudosEnergiaGrl
- **Resultado esperado:**
  - success: false
  - message: 'El campo axo debe ser mayor o igual a 1995.' o similar



