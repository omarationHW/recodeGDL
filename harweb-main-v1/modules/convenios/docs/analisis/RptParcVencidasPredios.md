# Documentación Técnica: Parcialidades Vencidas Predios

## Descripción General
Este módulo permite consultar y reportar las parcialidades vencidas de convenios de regularización de predios, agrupando por manzana y lote, mostrando pagos al corriente, pagos vencidos, recargos y adeudos. La lógica original proviene de un reporte Delphi y se ha migrado a una arquitectura Laravel + Vue.js + PostgreSQL.

## Arquitectura
- **Backend:** Laravel (PHP) con endpoint unificado `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js (SPA, página independiente)
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedure `sp_parcialidades_vencidas_predios`

## Flujo de Datos
1. El usuario accede a la página Vue.js y selecciona subtipo, fecha de corte y estado.
2. Al enviar el formulario, se realiza una petición POST a `/api/execute` con acción `getParcialidadesVencidasPredios` y los parámetros.
3. El controlador Laravel recibe la petición, valida los parámetros y ejecuta el stored procedure en PostgreSQL.
4. El resultado se retorna en formato JSON y se muestra en la tabla de resultados en el frontend.

## Endpoint API
- **POST** `/api/execute`
  - **Body:**
    ```json
    {
      "action": "getParcialidadesVencidasPredios",
      "params": {
        "subtipo": 1,
        "fechahst": "2024-06-30",
        "est": "A"
      }
    }
    ```
  - **Respuesta:**
    ```json
    {
      "status": "success",
      "data": [ ... ]
    }
    ```

## Stored Procedure
- **Nombre:** `sp_parcialidades_vencidas_predios`
- **Parámetros:**
  - `p_subtipo` (int): Subtipo de predio
  - `p_fechahst` (date): Fecha de corte
  - `p_est` (varchar): Estado ('A', 'B', 'P')
- **Retorna:** Tabla con los campos requeridos para el reporte

## Seguridad
- Validación de parámetros en backend
- El endpoint puede protegerse con middleware de autenticación si es necesario

## Consideraciones
- El frontend es una página independiente, no usa tabs ni componentes tabulares
- El reporte puede exportarse a Excel desde el frontend si se requiere (no incluido en este ejemplo)
- El stored procedure puede ser optimizado para grandes volúmenes de datos

## Mapeo de Campos
- `venc = 1`: Pagos al corriente
- `venc = 2`: Pagos vencidos
- `venc = 3`: Adeudos
- El campo `letracomp` es calculado: 'BIS' si letra='B', 'SUB' si letra='S', ' ' en otro caso

# Integración
- El componente Vue.js puede ser registrado en el router como `/parcialidades-vencidas-predios`
- El controlador Laravel debe estar registrado en las rutas API
- El stored procedure debe crearse en la base de datos PostgreSQL destino
