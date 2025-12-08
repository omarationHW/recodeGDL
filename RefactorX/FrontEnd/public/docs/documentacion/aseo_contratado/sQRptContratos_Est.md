# Documentación Técnica: sQRptContratos_Est

## Análisis

# Documentación Técnica: Estadística General de Contratos (ContratosEst)

## Descripción General
Este módulo implementa la migración del formulario Delphi `sQRptContratos_Est` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA), y PostgreSQL (base de datos y lógica de negocio vía stored procedures). El objetivo es proveer una página de consulta estadística de contratos de aseo, con filtros por tipo de aseo y periodo, y mostrar totales y desgloses por estado y operación.

## Arquitectura
- **Backend:** Laravel 10+, API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 3 SPA, componente de página independiente
- **Base de Datos:** PostgreSQL 13+, lógica de negocio en stored procedures

## API (Laravel)
- **Endpoint:** `POST /api/execute`
- **Request:**
  - `action`: string (ej: `get_estadistica_periodo`)
  - `params`: objeto con parámetros específicos
- **Response:**
  - `success`: boolean
  - `data`: array/objeto con los resultados
  - `message`: string (mensaje de error o éxito)

### Acciones soportadas
- `get_tipo_aseo`: Lista de tipos de aseo
- `get_dia_limite`: Día límite del mes actual
- `get_contratos_estadistica`: Estadística general (por tipo de aseo)
- `get_contratos_estadistica_totales`: Totales generales
- `get_periodos`: Periodos disponibles
- `get_estadistica_periodo`: Estadística filtrada por tipo de aseo y periodo

## Frontend (Vue.js)
- Página independiente `/contratos-estadistica`
- Formulario de filtros: tipo de aseo, año/mes inicio y fin
- Tabla de resultados con totales y desglose por operación y estado
- Navegación breadcrumb
- Manejo de loading y errores

## Stored Procedures (PostgreSQL)
- `sp_contratos_estadistica(p_cve_aseo TEXT)`: Estadística general por tipo de aseo
- `sp_contratos_estadistica_periodo(p_cve_aseo TEXT, p_aso_in INT, p_mes_in INT, p_aso_fin INT, p_mes_fin INT)`: Estadística filtrada por periodo
- `sp_contratos_estadistica_totales()`: Totales generales

## Seguridad
- Validación de parámetros en backend
- Sanitización de entradas
- Manejo de errores y logging

## Integración
- El frontend consume el endpoint `/api/execute` vía fetch/AJAX
- El backend enruta la acción al stored procedure correspondiente
- Los stored procedures devuelven los datos agregados para la vista

## Consideraciones
- El endpoint es unificado para facilitar integración y versionado
- El frontend es desacoplado y puede ser embebido en cualquier SPA
- Los stored procedures pueden ser reutilizados por otros módulos

# Esquema de Base de Datos (relevante)
- `ta_16_contratos`: contratos de aseo
- `ta_16_pagos`: pagos asociados a contratos
- `ta_16_operacion`: catálogo de operaciones (C=Cuota Normal, E=Excedente, D=Contenedor)
- `ta_16_tipo_aseo`: catálogo de tipos de aseo

# Ejemplo de Request/Response
**Request:**
```json
{
  "action": "get_estadistica_periodo",
  "params": {
    "cve_aseo": "O",
    "aso_in": 2023,
    "mes_in": 1,
    "aso_fin": 2023,
    "mes_fin": 6
  }
}
```
**Response:**
```json
{
  "success": true,
  "data": [
    {
      "tipo_aseo": "O",
      "total_contratos": 120,
      "importe_total": 123456.78,
      ...
    }
  ],
  "message": ""
}
```

# Despliegue
- Registrar el controlador en `routes/api.php`:
  ```php
  Route::post('/execute', [ContratosEstController::class, 'execute']);
  ```
- Registrar los stored procedures en la base de datos PostgreSQL
- Incluir el componente Vue en el router SPA

# Pruebas
- Probar con distintos tipos de aseo y periodos
- Validar que los totales coincidan con los datos históricos
- Verificar manejo de errores y mensajes


## Casos de Uso

# Casos de Uso - sQRptContratos_Est

**Categoría:** Form

## Caso de Uso 1: Consulta de Estadística General de Contratos (Todos los Tipos)

**Descripción:** El usuario desea ver la estadística general de contratos de aseo para todos los tipos y el periodo actual.

**Precondiciones:**
El usuario tiene acceso al sistema y existen contratos y pagos registrados.

**Pasos a seguir:**
1. El usuario accede a la página de Estadística de Contratos.
2. Selecciona 'Todos' en el filtro de Tipo de Aseo.
3. Selecciona el año y mes actual como inicio y fin.
4. Presiona 'Consultar Estadística'.

**Resultado esperado:**
Se muestra una tabla con los totales y desgloses de contratos, importes, cuotas normales, excedentes, contenedores, vigentes, cancelados, pagados y condonados para todos los tipos de aseo.

**Datos de prueba:**
Contratos de tipo O, H, C con pagos en el periodo actual.

---

## Caso de Uso 2: Consulta de Estadística por Tipo de Aseo y Periodo

**Descripción:** El usuario desea ver la estadística de contratos solo para el tipo 'O' (Ordinario) entre enero y junio de 2023.

**Precondiciones:**
Existen contratos y pagos de tipo 'O' en el periodo 2023-01 a 2023-06.

**Pasos a seguir:**
1. El usuario accede a la página de Estadística de Contratos.
2. Selecciona 'O' en el filtro de Tipo de Aseo.
3. Selecciona 2023/01 como inicio y 2023/06 como fin.
4. Presiona 'Consultar Estadística'.

**Resultado esperado:**
Se muestra la estadística solo para el tipo 'O' y el periodo seleccionado.

**Datos de prueba:**
Contratos y pagos de tipo 'O' en 2023-01 a 2023-06.

---

## Caso de Uso 3: Validación de Parámetros Inválidos

**Descripción:** El usuario intenta consultar la estadística con un año de inicio mayor al año de fin.

**Precondiciones:**
El sistema está en línea.

**Pasos a seguir:**
1. El usuario accede a la página de Estadística de Contratos.
2. Selecciona cualquier tipo de aseo.
3. Selecciona 2024/01 como inicio y 2023/12 como fin.
4. Presiona 'Consultar Estadística'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el periodo es inválido.

**Datos de prueba:**
No relevante (solo validación de parámetros).

---



## Casos de Prueba

# Casos de Prueba: Estadística General de Contratos

## Caso 1: Consulta General Todos los Tipos
- **Entrada:** cve_aseo='T', aso_in=2023, mes_in=1, aso_fin=2023, mes_fin=12
- **Esperado:** Respuesta success=true, data con al menos 3 filas (O, H, C), totales > 0

## Caso 2: Consulta Ordinarios Periodo Parcial
- **Entrada:** cve_aseo='O', aso_in=2023, mes_in=1, aso_fin=2023, mes_fin=6
- **Esperado:** Respuesta success=true, data con 1 fila tipo_aseo='O', totales > 0

## Caso 3: Periodo Inválido
- **Entrada:** cve_aseo='T', aso_in=2025, mes_in=1, aso_fin=2023, mes_fin=12
- **Esperado:** success=false, message='Acción no soportada' o mensaje de error de validación

## Caso 4: Sin Datos
- **Entrada:** cve_aseo='Z', aso_in=2020, mes_in=1, aso_fin=2020, mes_fin=1
- **Esperado:** success=true, data vacía o totales en cero

## Caso 5: SQL Injection
- **Entrada:** cve_aseo="O'; DROP TABLE ta_16_contratos; --", aso_in=2023, mes_in=1, aso_fin=2023, mes_fin=1
- **Esperado:** success=false, message de error, sin afectar la base de datos


