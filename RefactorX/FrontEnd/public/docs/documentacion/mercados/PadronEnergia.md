# PadronEnergia

## AnÃ¡lisis TÃ©cnico

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


## Casos de Uso

# Casos de Uso - PadronEnergia

**Categoría:** Form

## Caso de Uso 1: Consulta de Padrón de Energía para un Mercado

**Descripción:** El usuario desea consultar el padrón de energía eléctrica para un mercado específico de una recaudadora.

**Precondiciones:**
El usuario está autenticado y tiene acceso al módulo de energía.

**Pasos a seguir:**
1. El usuario accede a la página 'Padrón de Energía Eléctrica'.
2. Selecciona una recaudadora de la lista.
3. Selecciona un mercado de la lista filtrada por la recaudadora.
4. Hace clic en 'Buscar'.
5. El sistema muestra la tabla con los locales y datos de energía.

**Resultado esperado:**
Se muestra el padrón de energía eléctrica correspondiente al mercado seleccionado.

**Datos de prueba:**
{ "id_rec": 2, "num_mercado_nvo": 10 }

---

## Caso de Uso 2: Exportar Padrón de Energía a Excel

**Descripción:** El usuario desea exportar el padrón de energía eléctrica a un archivo Excel.

**Precondiciones:**
El usuario ya realizó una consulta y hay datos en pantalla.

**Pasos a seguir:**
1. El usuario hace clic en 'Exportar Excel'.
2. El sistema genera el archivo y muestra un enlace de descarga.

**Resultado esperado:**
El usuario puede descargar el archivo Excel con los datos del padrón.

**Datos de prueba:**
{ "id_rec": 3, "num_mercado_nvo": 7 }

---

## Caso de Uso 3: Imprimir Padrón de Energía en PDF

**Descripción:** El usuario desea imprimir el padrón de energía eléctrica en formato PDF.

**Precondiciones:**
El usuario ya realizó una consulta y hay datos en pantalla.

**Pasos a seguir:**
1. El usuario hace clic en 'Imprimir PDF'.
2. El sistema genera el PDF y lo muestra en una nueva ventana.

**Resultado esperado:**
El usuario visualiza el PDF listo para imprimir.

**Datos de prueba:**
{ "id_rec": 1, "num_mercado_nvo": 5 }

---



## Casos de Prueba

# Casos de Prueba para PadronEnergia

## 1. Consulta Exitosa
- **Entrada:** id_rec=2, num_mercado_nvo=10
- **Acción:** Buscar
- **Esperado:** Se muestra la tabla con datos del padrón de energía para el mercado 10 de la recaudadora 2.

## 2. Validación de Parámetros Vacíos
- **Entrada:** id_rec=, num_mercado_nvo=
- **Acción:** Buscar
- **Esperado:** Se muestra mensaje de error 'Seleccione oficina y mercado'.

## 3. Exportar Excel sin Datos
- **Entrada:** No hay datos en pantalla
- **Acción:** Exportar Excel
- **Esperado:** Botón deshabilitado o mensaje de error.

## 4. Exportar Excel con Datos
- **Entrada:** id_rec=3, num_mercado_nvo=7
- **Acción:** Buscar, luego Exportar Excel
- **Esperado:** Se descarga archivo Excel con los datos correctos.

## 5. Imprimir PDF sin Datos
- **Entrada:** No hay datos en pantalla
- **Acción:** Imprimir PDF
- **Esperado:** Botón deshabilitado o mensaje de error.

## 6. Imprimir PDF con Datos
- **Entrada:** id_rec=1, num_mercado_nvo=5
- **Acción:** Buscar, luego Imprimir PDF
- **Esperado:** Se abre PDF con los datos correctos.

## 7. Consulta con Mercado sin Energía
- **Entrada:** id_rec=2, num_mercado_nvo=99 (sin energía)
- **Acción:** Buscar
- **Esperado:** Mensaje 'No hay datos para mostrar.'



