# Documentación Técnica: CatastroDM

## Análisis Técnico

# Documentación Técnica - Migración CatastroDM Delphi a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel 10+ (PHP 8.1+), PostgreSQL 13+
- **Frontend**: Vue.js 3 SPA (Single Page Application)
- **API**: Único endpoint `/api/execute` que recibe un objeto `eRequest` con acción y parámetros, y responde con `eResponse`.
- **Base de Datos**: Toda la lógica SQL compleja se implementa como stored procedures en PostgreSQL.

## API Unificada (eRequest/eResponse)
- **Endpoint**: `/api/execute` (POST)
- **Entrada**:
  ```json
  {
    "eRequest": {
      "action": "nombre_accion",
      "params": { ... }
    }
  }
  ```
- **Salida**:
  ```json
  {
    "eResponse": { ... }
  }
  ```
- **Acciones soportadas**: getDerechos2, calcFechaRes, checaInhabil, calcFechaLimitePago, calcFechaVisita, autorizaLicencia, autorizaAnuncio, refreshQuery, generarDictamenMicrogeneradores, imprimirDictamenMicrogeneradores, etc.

## Controlador Laravel
- Un solo controlador (`CatastroDMController`) maneja todas las acciones.
- Cada acción llama a un stored procedure correspondiente en PostgreSQL.
- El controlador valida parámetros y retorna errores amigables en `eResponse.error`.

## Componente Vue.js
- Página independiente, sin tabs.
- Permite seleccionar la acción y los parámetros requeridos.
- Muestra la respuesta o error de la API.
- Puede ser extendido fácilmente para cada formulario/página.

## Stored Procedures
- Toda la lógica de negocio y reglas de cálculo se implementa en funciones y procedimientos almacenados en PostgreSQL.
- Cada función/procedimiento tiene una firma clara y retorna datos en formato tabla.
- Ejemplo: `get_derechos2`, `calc_fecha_res`, `checa_inhabil`, etc.

## Seguridad
- Se recomienda proteger el endpoint `/api/execute` con autenticación JWT o Laravel Sanctum.
- Validar y sanear todos los parámetros recibidos.

## Extensibilidad
- Para agregar nuevas acciones, basta con:
  1. Crear el stored procedure en PostgreSQL.
  2. Agregar el case correspondiente en el controlador Laravel.
  3. (Opcional) Extender el componente Vue para exponer la nueva acción.

## Pruebas
- Se recomienda usar Postman o similar para pruebas de API.
- Los casos de uso y pruebas incluidas pueden ser automatizadas con PHPUnit y Cypress.

## Despliegue
- Backend: Docker o servidor PHP-FPM + Nginx/Apache.
- Frontend: SPA compilada y servida desde Nginx/Apache o como recurso estático.
- Base de datos: PostgreSQL 13+.

## Notas
- El endpoint es agnóstico de la acción, lo que permite desacoplar el frontend del backend y facilita la integración con otros sistemas.
- El frontend puede ser extendido para cada formulario como una página independiente.

## Casos de Prueba

*Casos de prueba no disponibles en la documentación fuente.*

## Casos de Uso

# Casos de Uso - CatastroDM

**Categoría:** Form

## Caso de Uso 1: Consulta de Derechos2 para Licencia

**Descripción:** El usuario desea consultar el valor de derechos2 para una licencia específica.

**Precondiciones:**
La licencia existe en la base de datos y tiene registros en detsal_lic.

**Pasos a seguir:**
1. El usuario ingresa el ID de la licencia en el formulario.
2. Selecciona la acción 'Consultar Derechos2'.
3. Presiona 'Ejecutar'.
4. El sistema envía la petición a /api/execute con action 'getDerechos2' y el parámetro id_licencia.

**Resultado esperado:**
El sistema retorna el valor de derechos2 correspondiente a la licencia.

**Datos de prueba:**
{ "id_licencia": 12345, "id_anuncio": 0 }

---

## Caso de Uso 2: Cálculo de Fecha de Resolución para Trámite Tipo B

**Descripción:** El usuario necesita saber la fecha de resolución considerando días no laborables para un trámite tipo B.

**Precondiciones:**
Existen registros de días no laborables en la tabla no_laboralesLic.

**Pasos a seguir:**
1. El usuario ingresa la fecha de trámite y selecciona tipo 'B'.
2. Selecciona la acción 'Calcular Fecha Resolución'.
3. Presiona 'Ejecutar'.
4. El sistema envía la petición a /api/execute con action 'calcFechaRes' y los parámetros correspondientes.

**Resultado esperado:**
El sistema retorna la fecha de resolución calculada correctamente.

**Datos de prueba:**
{ "fechaTram": "2024-06-01", "tipo": "B", "autoev": false }

---

## Caso de Uso 3: Autorización de Licencia para Trámite

**Descripción:** El usuario solicita la autorización de una licencia para un trámite específico.

**Precondiciones:**
El trámite existe y cumple con los requisitos para autorización.

**Pasos a seguir:**
1. El usuario ingresa el número de trámite.
2. Selecciona la acción 'Autorizar Licencia'.
3. Presiona 'Ejecutar'.
4. El sistema procesa la autorización y actualiza los registros necesarios.

**Resultado esperado:**
El sistema retorna 'OK' y la licencia queda autorizada.

**Datos de prueba:**
{ "noTramite": 98765 }

---

