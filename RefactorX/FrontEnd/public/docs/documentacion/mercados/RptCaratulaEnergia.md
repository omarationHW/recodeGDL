# RptCaratulaEnergia

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Carátula de Energía Eléctrica (RptCaratulaEnergia)

## Descripción General
Este módulo permite consultar y visualizar la carátula de energía eléctrica de un local, mostrando los datos generales, adeudos, recargos calculados y requerimientos asociados. Incluye lógica de cálculo de recargos según reglas históricas y de negocio, y permite la impresión de la carátula.

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Componente Vue.js de página completa (sin tabs)
- **Base de Datos:** PostgreSQL con stored procedures para lógica de negocio y reportes

## Flujo de Datos
1. El usuario ingresa el ID del local y solicita la consulta.
2. El frontend realiza llamadas a `/api/execute` con acciones:
   - `getEnergiaCaratula` → Obtiene datos generales del local y energía
   - `getAdeudosEnergia` → Obtiene lista de adeudos y recargos calculados
   - `getRequerimientosEnergia` → Obtiene requerimientos asociados
3. El backend ejecuta los stored procedures correspondientes y retorna los datos en formato JSON.
4. El frontend muestra los datos y permite imprimir la carátula.

## Endpoints API
- **POST /api/execute**
  - **Body:** `{ action: string, params: object }`
  - **Acciones soportadas:**
    - `getEnergiaCaratula` { id_local }
    - `getAdeudosEnergia` { id_local }
    - `getRequerimientosEnergia` { id_local }
    - `getDiaVencimiento` { mes }
    - `calcularRecargosEnergia` { id_adeudo }

## Stored Procedures
- `sp_get_energia_caratula(id_local)` → Datos generales del local y energía
- `sp_get_adeudos_energia(id_local)` → Lista de adeudos y recargos
- `sp_get_requerimientos_energia(id_local)` → Requerimientos asociados
- `sp_get_dia_vencimiento(mes)` → Día de vencimiento para recargos
- `sp_calcular_recargos_energia(id_adeudo)` → Cálculo de recargos según reglas históricas

## Lógica de Recargos
- Si el mercado es 1 (Cruz del Sur), no hay recargos.
- Para años <= 2002, los adeudos son bimestrales y el cálculo es especial.
- El cálculo de recargos depende de la fecha actual, el periodo, y si existen requerimientos.
- Los porcentajes de recargo se obtienen de la tabla `ta_12_recargos`.

## Seguridad
- Todas las acciones requieren autenticación (middleware Laravel, no mostrado aquí).
- Validación de parámetros en backend.

## Extensibilidad
- El endpoint `/api/execute` permite agregar nuevas acciones sin modificar la ruta.
- Los stored procedures encapsulan la lógica de negocio, facilitando el mantenimiento.

## Pruebas
- Se recomienda usar Postman o similar para probar el endpoint con diferentes acciones y parámetros.
- El frontend puede ser probado de forma independiente usando mock de la API.

## Consideraciones
- El cálculo de recargos es sensible a la fecha actual y a la existencia de requerimientos.
- El frontend debe manejar errores y mostrar mensajes claros al usuario.


## Casos de Uso

# Casos de Uso - RptCaratulaEnergia

**Categoría:** Form

## Caso de Uso 1: Consulta de Carátula de Energía para un Local Vigente

**Descripción:** El usuario consulta la carátula de energía de un local vigente, visualizando datos generales, adeudos, recargos y requerimientos.

**Precondiciones:**
El local existe y tiene registros de energía y adeudos.

**Pasos a seguir:**
1. El usuario ingresa el ID del local en el formulario.
2. Presiona el botón 'Consultar'.
3. El sistema muestra los datos generales del local y energía.
4. El sistema muestra la tabla de adeudos y recargos.
5. El sistema muestra la tabla de requerimientos si existen.

**Resultado esperado:**
Se visualiza correctamente la carátula con todos los datos, recargos calculados y requerimientos.

**Datos de prueba:**
id_local: 12345 (local vigente con adeudos y requerimientos)

---

## Caso de Uso 2: Cálculo de Recargos para Adeudo de Energía sin Requerimientos

**Descripción:** El sistema calcula los recargos de un adeudo de energía para un local sin requerimientos asociados.

**Precondiciones:**
El local tiene adeudos de energía y no tiene requerimientos.

**Pasos a seguir:**
1. El usuario consulta la carátula de energía del local.
2. El sistema ejecuta el cálculo de recargos para cada adeudo usando el stored procedure.

**Resultado esperado:**
Los recargos se calculan correctamente según la lógica histórica y se muestran en la tabla.

**Datos de prueba:**
id_local: 23456 (local sin requerimientos, con adeudos de energía)

---

## Caso de Uso 3: Impresión de Carátula de Energía

**Descripción:** El usuario imprime la carátula de energía de un local para entregar al contribuyente.

**Precondiciones:**
La carátula ya fue consultada y se visualiza en pantalla.

**Pasos a seguir:**
1. El usuario presiona el botón 'Imprimir Carátula'.
2. El navegador muestra el diálogo de impresión.

**Resultado esperado:**
La carátula se imprime correctamente con todos los datos visibles.

**Datos de prueba:**
id_local: 34567 (local con datos completos)

---



## Casos de Prueba

# Casos de Prueba: Carátula de Energía Eléctrica

## Caso 1: Consulta exitosa de carátula
- **Entrada:** id_local = 12345
- **Acción:** POST /api/execute { action: 'getEnergiaCaratula', params: { id_local: 12345 } }
- **Resultado esperado:** Código 200, success=true, data contiene datos del local y energía

## Caso 2: Consulta de adeudos y recargos
- **Entrada:** id_local = 12345
- **Acción:** POST /api/execute { action: 'getAdeudosEnergia', params: { id_local: 12345 } }
- **Resultado esperado:** Código 200, success=true, data es array de adeudos con campo recargos calculado

## Caso 3: Consulta de requerimientos
- **Entrada:** id_local = 12345
- **Acción:** POST /api/execute { action: 'getRequerimientosEnergia', params: { id_local: 12345 } }
- **Resultado esperado:** Código 200, success=true, data es array de requerimientos

## Caso 4: Cálculo de recargos para adeudo específico
- **Entrada:** id_adeudo = 67890
- **Acción:** POST /api/execute { action: 'calcularRecargosEnergia', params: { id_adeudo: 67890 } }
- **Resultado esperado:** Código 200, success=true, data es el valor numérico de recargos

## Caso 5: Error por parámetro faltante
- **Entrada:** id_local no enviado
- **Acción:** POST /api/execute { action: 'getEnergiaCaratula', params: { } }
- **Resultado esperado:** Código 200, success=false, message indica parámetro requerido

## Caso 6: Error por acción no soportada
- **Entrada:** action = 'accionInexistente'
- **Acción:** POST /api/execute { action: 'accionInexistente', params: { id_local: 12345 } }
- **Resultado esperado:** Código 200, success=false, message indica acción no soportada



